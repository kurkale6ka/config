#! /usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Getopt::Long qw/GetOptions :config bundling/;
use Term::ANSIColor qw/color :constants/;
use List::Util 'any';

my $PINK = color('ansi205');
my $RED = color('red');
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

GetOptions (
   'h|help' => \&help
) or die RED.'Error in command line arguments'.RESET, "\n";

@ARGV == 0 and help;

unless (system ('ssh-add -l >/dev/null') == 0)
{
   die RED.'Please add your ssh key to your agent'.RESET, "\n";
}

my $session = 'ssh';
my %hosts;

# Calculate Ranges
foreach (@ARGV)
{
   my ($host, $first, $last, $range, @numbers);

   # final -
   if (/(?<!\d)[-,]$/)
   {
      chop ($host = $_);
      $hosts{$host} = [1, 2];
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
      $hosts{$_} = [];
      next;
   }

   $hosts{$host} = \@numbers;
}

my (@clusters, @cl_names, @singles);

while (my ($host, $numbers) = each %hosts)
{
   if (@$numbers > 1)
   {
      push @clusters, map $host.$_, @$numbers;
      push @cl_names, $host;
   } else {
      push @singles, $host;
   }
}

my @hosts = sort @clusters;
push @hosts, sort @singles;

my $win = join '', map "($_)", sort @cl_names;
$win .= join '.', sort @singles;

if (@hosts > 10)
{
   print RED, scalar @hosts, RESET, ' panes will be created. continue? (y/n) ';
   exit unless <STDIN> =~ /y(?:es)?/i;
}

my $sessions = grep /^\d/, `tmux ls -F'#S' 2>/dev/null`;

unless ($sessions)
{
   system qw/tmux new-session -s/, $session, '-d', '-n', $win, "ssh $hosts[0]";
}
elsif (any {/$win/} `tmux lsw -F'#W'`)
{
   system qw/tmux attach/ unless $ENV{TMUX};
   $? == 0 and system qw/tmux select-window -t/, $win;
   die "A window named ${PINK}$win${R} already exists! Selecting it.\n";
}

foreach my $host (@hosts[1..$#hosts])
{
   system qw/tmux split-window -t/, $win, '-h', '-l', '100%', "ssh $host";
}

if (@hosts <= 2)
{
   system qw/tmux select-layout -t/, $win, 'even-horizontal';
} else {
   system qw/tmux select-layout -t/, $win, 'tiled';
}

system qw/tmux select-pane -t/, "$win.1";
system qw/tmux set-window-option -t/, $win, 'synchronize-panes', 'on';

system qw/tmux attach-session -t/, $session unless $ENV{TMUX};
