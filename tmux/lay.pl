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

# Arguments
my @hosts;

foreach (@ARGV)
{
   my ($host, $first, $last, $range, @numbers);

   # get host and range
   if (/(?<!\d)[-,]$/)
   {
      chop ($host = $_);
      push @hosts, $host.1, $host.2;
      next;
   }
   elsif (/,\d+$/)
   {
      ($host, $range) = /(.+?)((?:\d+)?(?:,\d+)+)$/;

      $range = "1$range" if $range =~ /^,/;
      @numbers = split /,/, $range;
   }
   elsif (/-\d+$/)
   {
      ($host, $first, $last) = /(.+?)(\d+)?-(\d+)$/;

      $first //= 1;
      $first < $last or die RED.'non ascending range detected'.RESET, "\n";

      @numbers = $first..$last;
   }
   else
   {
      /[,-]$/ and warn RED."garbage range detected: $_".RESET, "\n";
      push @hosts, $_;
      next;
   }

   push @hosts, map $host.$_, @numbers;
}

my @nb_sessions = `tmux ls -F#S`;
say grep (/^\d/, @nb_sessions);

system qw/tmux new-session -s tiles -d -n init/, 'ssh '. shift @hosts;

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
