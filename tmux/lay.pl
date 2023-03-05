#! /usr/bin/env perl

# Split multiple ssh connections in separate tmux panes,
# for simultaneous operation
#
# The Nodes module is used to calculate ranges and ClusterShell nodes

# use strict;
# use warnings;
use feature 'say';
use Term::ANSIColor qw/color :constants/;
use lib "$ENV{REPOS_BASE}/github/config/tmux";
use Nodes;

# Colors
my $PINK = color('ansi205');
my $S = color('bold');
my $R = color('reset');

# Help
sub help()
{
   my $msg = <<MSG;
${S}Split multiple ssh connections in separate tiles${R}

  lay ${PINK}\@${R}cluster ... host[${PINK}range${R}] ... [${PINK}-${R}exclude] ... or
nodes ${PINK}\@${R}cluster ... host[${PINK}range${R}] ... [${PINK}-${R}exclude] ... | lay -

MSG
   die $msg.Nodes::help();
}

# A lone - won't trigger help() or set any hosts
help() if @ARGV == 0;
help() if @ARGV == 1 and $ARGV[0] eq '-h';

my (@clusters, @singles);

foreach (@ARGV)
{
   help() if /--help/;

   if (/^@/)
   {
      push @clusters, substr $_, 1;
   } else {
      push @singles, $_ unless /^-./;
   }
}

# Calculate hosts
exit unless my @hosts = nodes();

# Extra checks
if (@hosts > 12)
{
   print RED, scalar @hosts, RESET, ' panes will be created. continue? (y/n) ';
   exit unless <STDIN> =~ /y(?:es)?/i;
}

# Check if ssh keys have been registered with the agent
unless (system ('ssh-add -l >/dev/null') == 0)
{
   die RED.'Please add your ssh key to your agent'.RESET, "\n";
}

my $session = 'ssh';

# Main window name
my $win = join ('', map {"(\@$_)"} sort @clusters) . join ',', sort @singles;

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
