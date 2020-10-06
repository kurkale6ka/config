#! /usr/bin/env perl

# Split multiple ssh connections in separate tmux panes,
# for simultaneous operation
#
# check nodes.pl for ClusterShell nodes

use strict;
use warnings;
use feature 'say';
use Getopt::Long qw/GetOptions :config bundling/;
use Term::ANSIColor qw/color :constants/;

# Colors
my $GREEN  = color('green');
my $PINK   = color('ansi205');
my $YELLOW = color('yellow');
my $S = color('bold');
my $R = color('reset');

# Help
sub help() {
   print <<MSG;
${S}SYNOPSIS${R}
Split multiple ssh connections in separate tiles

lay host[${PINK}range${R}] ...

${S}RANGES${R}
   3,5,9 : unchanged
     3-6 : 3 ${GREEN}to${R} 6
      -3 : 1 ${GREEN}to${R} 3
  - or , : 1 ${GREEN}and${R} 2

${YELLOW}example${R}:
lay host${PINK}-${R} host${PINK}3,7${R} host host${PINK}4-6${R}
    host${GREEN}1${R} host${GREEN}3${R}   host host${GREEN}4${R}
    host${GREEN}2${R} host${GREEN}7${R}        host${GREEN}5${R}
                       host${GREEN}6${R}
MSG
exit;
}

GetOptions (
   'h|help' => \&help
) or die RED.'Error in command line arguments'.RESET, "\n";

# Check if ssh keys have been registered with the agent
unless (system ('ssh-add -l >/dev/null') == 0)
{
   die RED.'Please add your ssh key to your agent'.RESET, "\n";
}

# read hosts, UNIX-filter style
chomp (my @nodes = <STDIN>) unless -t STDIN;

my $session = 'ssh';
my %hosts;

# Calculate Ranges
foreach (-t STDIN ? @ARGV : @nodes)
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
      if (/[,-]$/)
      {
         die RED."garbage range detected: $_".RESET, "\n";
      }

      # single hosts
      unless (exists $hosts{$_})
      {
         $hosts{$_} = [0];
      } else {
         push $hosts{$_}->@*, 0;
      }

      next;
   }

   # x,y,z and 1-n cases
   $hosts{$host} = \@numbers;
}

help unless %hosts;

# List of hosts, clusters first
my (@clusters, @cl_names, @singles);

while (my ($host, $numbers) = each %hosts)
{
   if (@$numbers > 1)
   {
      push @clusters, map {$_ != 0 ? $host.$_ : $host} @$numbers;
      push @cl_names, $host;
   } else {
      push @singles, $host;
   }
}

my @hosts = sort @clusters;
push @hosts, sort @singles;

# Main window name
my $win = join '', map "($_)", sort @cl_names;
$win .= join '-', sort @singles;

# Extra checks
if (@hosts > 12)
{
   print RED, scalar @hosts, RESET, ' panes will be created. continue? (y/n) ';
   exit unless <STDIN> =~ /y(?:es)?/i;
}

# todo: notify about failed ssh panes
die RED."$session:$win exists".RESET, "\n"
if system ("tmux has-session -t '$session:$win' 2>/dev/null") == 0;

# New Session/Window
unless (system ("tmux has-session -t '$session' 2>/dev/null") == 0)
{
   system qw/tmux new-session -d -s/, $session, '-n', $win, "ssh $hosts[0]";
} else {
   system qw/tmux new-window -n/, $win, '-t', "$session:", "ssh $hosts[0]";
}

# Split
foreach my $host (@hosts[1..$#hosts])
{
   # without -l 100%, splitting errs after a few hosts:
   # create pane failed: pane too small
   system qw/tmux split-window -h -t/, "$session:$win", '-l100%', "ssh $host";
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

# Options: sync on
system qw/tmux set-window-option -t/, "$session:$win", 'synchronize-panes', 'on';

# Attach
if (-t STDIN)
{
   exec qw/tmux attach-session -t/, $session unless $ENV{TMUX};
} else {
   say "Use ${PINK}tmux attach-session -t$session${R} to attach to the running session";
}
