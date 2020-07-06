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
${S}OPTIONS${R}
${S}DESCRIPTION${R}
MSG
   exit;
}

# Arguments
GetOptions(
   'h|help' => \&help
) or die RED.'Error in command line arguments'.RESET, "\n";

my @nb_sessions = `tmux ls -F#S`;
say grep (/^\d/, @nb_sessions);
