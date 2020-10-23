#! /usr/bin/env perl

# Split multiple ssh connections in separate tmux panes,
# for simultaneous operation
#
# check nodes.pl for ClusterShell nodes

use strict;
use warnings;
use feature 'say';
use Term::ANSIColor qw/color :constants/;

# Colors
my $GREEN  = color('green');
my $PINK   = color('ansi205');
my $YELLOW = color('yellow');
my $S = color('bold');
my $R = color('reset');

# Help
my $help = <<MSG;
${S}SYNOPSIS${R}
Split multiple ssh connections in separate tiles

lay host[${PINK}range${R}] ...

${S}RANGES${R}
   3,5,9 : unchanged
     3-6 : 3 ${GREEN}to${R} 6
      -3 : 1 ${GREEN}to${R} 3
  - or , : 1 ${GREEN}and${R} 2

${YELLOW}example${R}:
lay host${PINK}-${R} host${PINK},3,7${R} host host${PINK}=2${R} host${PINK}4-6${R} ${PINK}3${R}
    host${GREEN}1${R} host${GREEN}1${R}    host host   host${GREEN}4${R}   +- shell tiles
    host${GREEN}2${R} host${GREEN}3${R}         host   host${GREEN}5${R}
          host${GREEN}7${R}                host${GREEN}6${R}
MSG

die $help if @ARGV == 0;

# Check if ssh keys have been registered with the agent
unless (system ('ssh-add -l >/dev/null') == 0)
{
   die RED.'Please add your ssh key to your agent'.RESET, "\n";
}

die $help if @ARGV == 1 and $ARGV[0] eq '-h';

my (@cl_names, @singles);

foreach (@ARGV)
{
   die $help if /--help/;

   if (/^@/)
   {
      push @cl_names, substr $_, 1;
   } else {
      push @singles, $_ unless /^-./;
   }
}

# Calculate hosts
# call nodes.pl, todo: turn into a module
my @hosts;

if (-t STDIN)
{
   @hosts = `./nodes.pl @ARGV`;
} else {
   # read hosts, UNIX-filter style
   chomp (my @nodes = <STDIN>);

   @hosts = `./nodes.pl @nodes`;
}

# $@ ?
exit unless @hosts;

# Main window name
my $win = join '', map "($_)", sort @cl_names;
$win .= join '-', sort @singles;

# Extra checks
if (@hosts > 12)
{
   print RED, scalar @hosts, RESET, ' panes will be created. continue? (y/n) ';
   exit unless <STDIN> =~ /y(?:es)?/i;
}

my $session = 'ssh';

# todo: notify about failed ssh panes
die RED."$session:$win exists".RESET, "\n"
if system ("tmux has-session -t '$session:$win' 2>/dev/null") == 0;

# New Session/Window
my $cmd = $hosts[0] ne 'empty' ? "ssh $hosts[0]" : $ENV{SHELL};

unless (system ("tmux has-session -t '$session' 2>/dev/null") == 0)
{
   system qw/tmux new-session -d -s/, $session, '-n', $win, $cmd;
} else {
   system qw/tmux new-window -n/, $win, '-t', "$session:", $cmd;
}

# Split
foreach my $host (@hosts[1..$#hosts])
{
   # without -l 100%, splitting errs after a few hosts:
   # create pane failed: pane too small
   unless ($host eq 'empty')
   {
      system qw/tmux split-window -h -t/, "$session:$win", '-l100%', "ssh $host";
   } else {
      system qw/tmux split-window -h -t/, "$session:$win", '-l100%', $ENV{SHELL};
   }
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
