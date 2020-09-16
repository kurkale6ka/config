#! /usr/bin/env perl

# ClusterShell nodes for lay.pl
# faster than: nodeset -f @cluster | tr -d '[]' | tr , '\n'

use strict;
use warnings;
use feature 'say';
use List::Util 'none';

my $help = << 'MSG';
Usage: nodes cluster [[-exclude] ...]
-xa, would remove any line matching this litteral (xa,)
MSG

die $help if @ARGV == 0;

open my $clush, '<', "$ENV{XDG_CONFIG_HOME}/clustershell/groups.d/cluster.yaml"
   or die "$!\n";

my ($cluster, $cluster_reg);
my @exclusions;

foreach (@ARGV)
{
   unless (/^-./)
   {
      $cluster = $_;
   } else {
      push @exclusions, substr $_, 1;
   }
}

$cluster or die $help;

$cluster_reg = qr/\Q$cluster\E/;
@exclusions = map qr/\Q$_\E/, @exclusions;

my @hosts;

while (<$clush>)
{
   next if /^\s*#/;

   # config example
   # web: 'wa[1-3],wb[1-2]'
   if (/\b$cluster_reg:\s*'(.+)'/)
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

@hosts or die "$cluster cluster not found\n";

unless (@exclusions)
{
   say foreach @hosts;
} else {
   say foreach grep {
      my $host = $_;
      none {$host =~ /$_/} @exclusions;
   } @hosts;
}
