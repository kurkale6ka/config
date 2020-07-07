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
   # get host and range
   my ($host, $first, $last) = /(.+?)(?:(\d+)?-(\d+))?$/;

   unless (defined $last)
   {
      # trailing range
      if ($host =~ /(\d+)?-$/)
      {
         unless (defined $1)
         {
            chop $host;
            push @hosts, $host.1, $host.2;
         } else {
            warn RED.'dash forbidden at end'.RESET, "\n";
         }
      } else {
         push @hosts, $host;
      }

      next;
   }

   $first //= 1;
   $last  //= 1;

   $last > $first or die RED.'non ascending range detected'.RESET, "\n";

   push @hosts, map $host.$_, $first..$last;
}

my @nb_sessions = `tmux ls -F#S`;
say grep (/^\d/, @nb_sessions);
