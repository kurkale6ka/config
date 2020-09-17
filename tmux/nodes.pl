#! /usr/bin/env perl

# ClusterShell nodes for lay.pl
# faster than: nodeset -f @cluster | tr -d '[]' | tr , '\n'

# use strict;
# use warnings;

my $help = << 'MSG';
Usage: nodes cluster [[-exclude] ...]
-xa, would remove any line matching this litteral (xa,)
MSG

die $help if @ARGV == 0;

my $config = "$ENV{XDG_CONFIG_HOME}/clustershell/groups.d/cluster.yaml";
open my $clush, '<', $config or die "$config: $!\n";

my ($cluster, $cluster_reg, @exclusions, @hosts);

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
   print "$_\n" foreach @hosts;
} else {
   print "$_\n" foreach grep {
      my $host = $_;
      not grep {$host =~ /$_/} @exclusions;
   } @hosts;
}
