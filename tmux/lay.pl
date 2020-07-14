#! /usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Getopt::Long qw/GetOptions :config bundling/;
use Term::ANSIColor qw/color :constants/;

my $PINK = color('ansi205');
my $RED = color('red');
my $S = color('bold');
my $R = color('reset');

# Help
sub help() {
   print <<MSG;
${S}SYNOPSIS${R}
lay host[range] ...

${S}RANGES${R}
   3,5,9 : unchanged
     3-6 : 3..6
      -3 : 1..3
  - or , : 1..2

example:
lay host- host3,5 hostY host4-6
    host1 host2 host3 host5 hostY host4 host5 host6

${S}DESCRIPTION${R}
open ssh connections in tiles for simultaneous operation
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
$win .= join '-', sort @singles;

if (@hosts > 10)
{
   print RED, scalar @hosts, RESET, ' panes will be created. continue? (y/n) ';
   exit unless <STDIN> =~ /y(?:es)?/i;
}

# todo: bm- failed ssh, // for parallel vs SYNC
system ("tmux has-session -t '$session:$win' 2>/dev/null") == 0
   and die RED."$session:$win exists".RESET, "\n";

# New Session/Window
unless (system ("tmux has-session -t '$session' 2>/dev/null") == 0)
{
   system qw/tmux new-session -s/, $session, '-d', '-n', $win, "ssh $hosts[0]";
} else {
   system qw/tmux new-window -n/, $win, '-t', "$session:", "ssh $hosts[0]";
}

# Split
foreach my $host (@hosts[1..$#hosts])
{
   system qw/tmux split-window -t/, "$session:$win", '-h', '-l', '100%', "ssh $host";
}

# Layout
if (@hosts <= 3)
{
   # vertical split for 2/3 panes
   system qw/tmux select-layout -t/, "$session:$win", 'even-horizontal';
} else {
   # tiles
   system qw/tmux select-layout -t/, "$session:$win", 'tiled';
}

system qw/tmux select-pane -t/, "$session:$win.1";

# Options
system qw/tmux set-window-option -t/, "$session:$win", 'synchronize-panes', 'on';

# Attach
system qw/tmux attach-session -t/, $session unless $ENV{TMUX};
