#! /usr/bin/env perl

# ClusterShell nodes for lay.pl
# faster than: nodeset -f @cluster | tr -d '[]' | tr , '\n'

use strict;
use warnings;
use feature 'say';
use List::Util 'none';

my $help = 'Usage: nodes cluster [[-exclude_pattern] ...]';

@ARGV == 0 and die "$help\n";

open my $clush, '<', "$ENV{XDG_CONFIG_HOME}/clustershell/groups.d/cluster.yaml"
   or die "$!\n";

my $stack;
my @exclusions;

foreach (@ARGV)
{
   unless (/^-/)
   {
      $stack = $_;
   } else {
      push @exclusions, substr $_, 1;
   }
}

$stack or die "$help\n";
$stack = qr/$stack/;

my @hosts;

while (<$clush>)
{
   next if /^\s*#/;

   if (/\b$stack:\s*'(.+)'/)
   {
      @hosts = map {
         if (/(.+)\[(\d+)-(\d+)\]/)
         {
            if ($2 == 1)
            {
               $3 == 2 ? "$1," : "$1-$3";
            } else {
               "$1$2-$3";
            }
         } else {
            $_;
         }
      } split /,/, $1;
      last;
   }
}

close $clush or die "$!\n";

unless (@exclusions)
{
   say foreach @hosts;
} else {
   say foreach grep {
      my $host = $_;
      none {$host =~ /$_/} @exclusions;
   } @hosts;
}
