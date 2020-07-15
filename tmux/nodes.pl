#! /usr/bin/env perl

# Get clustershell nodes for lay.pl
# faster than: nodeset -f @... | tr -d '[]' | tr , ' '

use strict;
use warnings;
use feature 'say';
use List::Util 'none';

@ARGV == 0 and die "Usage: nodes stack [[-exclude] ...]\n";

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

$stack = qr/$stack/;

my @hosts;

while (<$clush>)
{
   next if /^\s*#/;

   if (/$stack:\s*'(.+)'/)
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

# todo: separate with newlines for nodes ... | lay -
unless (@exclusions)
{
   say "@hosts";
} else {
   say join ' ', grep {
      my $host = $_;
      none {$host =~ /$_/} @exclusions;
   } @hosts;
}
