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

my ($cluster, $cluster_clean);
my @exclusions;

foreach (@ARGV)
{
   unless (/^-/)
   {
      $cluster = $_;
   } else {
      push @exclusions, substr $_, 1;
   }
}

$cluster or die "$help\n";

$cluster_clean = $cluster; # non compiled string
$cluster = qr/$cluster_clean/;

@exclusions = map qr/$_/, @exclusions;

my @hosts;

while (<$clush>)
{
   next if /^\s*#/;

   # test: 'ha[1-3],hb[1-2]' # cluster test with hosts - ha1 ha2 ha3 hb1 hb2
   if (/\b$cluster:\s*'(.+)'/)
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

@hosts or die "No cluster $cluster_clean found\n";

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
