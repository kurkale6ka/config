#! /usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Getopt::Long qw/GetOptions :config bundling/;
use File::Basename 'basename';
use File::Path 'make_path';
use Term::ANSIColor qw/color :constants/;
use List::Util 'any';

my $B = color('ansi69');
my $C = color('ansi45');
my $S = color('bold');
my $R = color('reset');

# Help
sub help() {
   print <<MSG;
${S}SYNOPSIS${R}
lay host[n-z]
${S}RANGES${R}
  - : 1..2
 -3 : 1..3
3-6 : 3..6
${S}DESCRIPTION${R}
MSG
exit;
}

GetOptions(
   'h|help' => \&help
) or die RED.'Error in command line arguments'.RESET, "\n";

@ARGV == 0 and help;

unless (system qw/ssh-add -ql/ == 0)
{
   die RED.'Please add your ssh key to your agent'.RESET, "\n";
}

my @hosts;

# Calculate Ranges
foreach (@ARGV)
{
   my ($host, $first, $last, $range, @numbers);

   # final -
   if (/(?<!\d)[-,]$/)
   {
      chop ($host = $_);
      push @hosts, $host.1, $host.2;
      next;
   }
   # x,y,z
   elsif (/,\d+$/)
   {
      ($host, $range) = /(.+?)((?:\d+)?(?:,\d+)+)$/;

      $range = "1$range" if $range =~ /^,/;
      @numbers = split /,/, $range;
   }
   # 1-n
   elsif (/-\d+$/)
   {
      ($host, $first, $last) = /(.+?)(\d+)?-(\d+)$/;

      $first //= 1;
      $first < $last or die RED.'non ascending range detected'.RESET, "\n";

      @numbers = $first..$last;
   }
   else
   {
      /[,-]$/ and die RED."garbage range detected: $_".RESET, "\n";
      push @hosts, $_;
      next;
   }

   push @hosts, map $host.$_, @numbers;
}

my $nb_sessions = grep /^\d/, `tmux ls -F'#S' 2>/dev/null`;

# window name
my $win = join '-', @hosts;

if (any {/$win/} `tmux lsw -F'#W'`)
{
   system qw/tmux attach/ unless $ENV{TMUX};
   $? == 0 and system qw/tmux select-window -t/, $win;
   die RED."A window named %F{205}$win%f already exists! Selecting it.".RESET, "\n";
}

if (@hosts > 10)
{
   warn RED."Are you sure you want to create %F{red}\$nb_hosts%f panes? (y/n) ".RESET, "\n";
   exit unless <STDIN> =~ /y(?:es)?/i;
}

system qw/tmux new-session -s ssh -d -n init/, 'ssh '. shift @hosts;

my @children;

foreach my $host (@hosts)
{
   # parent
   my $pid = fork // die "failed to fork: $!";
   if ($pid)
   {
      push @children, $pid;
      next;
   }

   # kid
   system qw/tmux split-window -t init -h -l 100%/, "ssh $host";
   exit;
}

waitpid $_, 0 foreach @children;

if (@hosts <= 2)
{
   system qw/tmux select-layout -t init even-horizontal/;
} else {
   system qw/tmux select-layout -t init tiled/;
}

system qw/tmux select-pane -t init.1/;
system qw/tmux set-window-option -t init synchronize-panes on/;

system qw/tmux attach-session -t tiles/;
