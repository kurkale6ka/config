#! /usr/bin/env perl

# ClusterShell groups/nodes
# https://clustershell.readthedocs.io/en/latest/config.html#yaml-group-files
#
# faster than: nodeset -f @cluster | tr -d '[]' | tr , '\n'

package Nodes;

# use strict;
# use warnings;
use feature 'say';

require Exporter;
our @ISA = ('Exporter');
our @EXPORT = ('nodes');

# ClusterShell groups
my $config = "$ENV{XDG_CONFIG_HOME}/clustershell/groups.d/cluster.yaml";

my $called = caller;

# never die when including Nodes with 'use'!
sub abort($)
{
   $called ? warn @_ : die @_;
}

# Help
sub help()
{
   my $h_nodes = << 'MSG';
Expand nodes with ranges

nodes @cluster ... node[range] ... [-exclude] ...

MSG

   my $h_ranges = << 'MSG';
use ClusterShell @all cluster to get all nodes

Ranges:
  - or , : 1 and 2
      -3 : 1 to 3
     3-6 : 3 to 6
   3,5,9 : unchanged
      =2 : 2 instances
       4 : 4 'empty' nodes (for shell tiles with 'lay')

 In: node- node,3,7 node=2 node4-6 2
Out: node1 node1    node   node4   empty
     node2 node3    node   node5   empty
           node7           node6

Excludes:
-xa would remove any line matching the litteral 'xa'
MSG

   return $called ? $h_ranges : $h_nodes.$h_ranges;
}

if (@ARGV == 0)
{
   die help unless $called;
}

my (%clusters, @hosts, @exclusions);

# Sort arguments into clusters, hosts and exclusions
sub arguments()
{
   foreach (-t STDIN ? @ARGV : <STDIN>)
   {
      chomp;
      unless (/^-./)
      {
         if (/^@(\p{IsAlpha}|_)/n)
         {
            $clusters{substr $_, 1} = [];
         }
         elsif (/^(\p{IsAlpha}|_)|^\d+$/n)
         {
            push @hosts, $_;
         } else {
            abort "Wrong host $_\n";
         }
      } else {
         my $exclusion = substr $_, 1;
         push @exclusions, qr/\Q$exclusion\E/;
      }
   }

   abort help unless %clusters or @hosts;
}

# Calculate node ranges
sub groups()
{
   open my $clush, '<', $config or abort "$config: $!\n";

   my (%groups, $group, $nodes);

   # load groups from config
   while (<$clush>)
   {
      next unless /^\s+\w/;
      ($group, $nodes) = split /:/;
      $group =~ tr/ \t//d;
      $nodes =~ /'(.+)'/;
      $groups{$group} = [split /[[:blank:],]/, $1];
   }

   # expand nested groups
   foreach my $nodes (values %groups)
   {
      next unless grep /^@/, @$nodes;
      for (my $i = 0; $i < @$nodes; $i++)
      {
         if ($nodes->[$i] =~ /^@/)
         {
            if (exists $groups{substr $nodes->[$i], 1})
            {
               splice @$nodes, $i, 1, $groups{substr $nodes->[$i], 1}->@*;
            } else {
               abort "$config: $nodes->[$i] cluster not found. Typo?\n";
            }
         }
      }
   }

   # calculate ranges
   sub ranges(@)
   {
      my @ranges;
      foreach (@_)
      {
         # config example
         # web: 'wa[1-3],wb[1-2]'
         if (/(.+)\[(\d+)-(\d+)\]/)
         {
            if ($2 == 1)
            {
               push @ranges, $3 == 2 ?
               "$1," :
               "$1-$3";
            } else {
               push @ranges, "$1$2-$3";
            }
         } else {
            push @ranges, $_;
         }
      }
      return @ranges;
   }

   # @all
   if (exists $clusters{all})
   {
      while (my ($group, $nodes) = each %groups)
      {
         push $clusters{$group}->@*, ranges @$nodes;
      }
      return;
   }

   # add nodes with ranges
   my @unknown;

   foreach (keys %clusters)
   {
      if (exists $groups{$_})
      {
         push $clusters{$_}->@*, ranges $groups{$_}->@*;
      } else {
         push @unknown, "\@$_";
      }
   }

   return unless @unknown;

   # warn about unknown clusters
   my $s = @unknown > 1 ? 's' : '';

   unless (%clusters or @hosts)
   {
      abort join (', ', @unknown) . " cluster$s not found\n";
   } else {
      warn join (', ', @unknown) . " cluster$s not found\n";
   }
}

my (@clusters, @singles);

# Get hosts
sub hosts()
{
   my %hosts;

   # expand ranges
   foreach (@hosts, map {@$_} values %clusters)
   {
      my ($host, $first, $last, $range);

      # final -
      if (/(?<!\d)[-,]$/)
      {
         chop ($host = $_);
         $hosts{$host} = [1, 2];
      }
      # x,y,z
      elsif (/,\d+$/)
      {
         ($host, $range) = /(.+?)((?:\d+)?(?:,\d+)+)$/;

         $range = "1$range" if $range =~ /^,/;
         $hosts{$host} = [sort split /,/, $range];
      }
      # 1-n
      elsif (/-\d+$/)
      {
         ($host, $first, $last) = /(.+?)(\d+)?-(\d+)$/;

         $first //= 1;
         $first < $last or abort "non ascending range detected\n";
         $hosts{$host} = [$first..$last];
      }
      # no range
      else
      {
         abort "garbage range detected: $_\n" if /[,-]$/;

         # single digit
         if (/^\d+$/)
         {
            $hosts{empty} = [(0) x $&];
         }
         # host=count
         elsif (/.+=\d+$/)
         {
            my ($host, $count) = split /=/;
            $hosts{$host} = [(0) x $count];
         }
         # host
         else
         {
            unless (exists $hosts{$_})
            {
               $hosts{$_} = [0];
            } else {
               push $hosts{$_}->@*, 0;
            }
         }
      }
   }

   # hosts: clusters and single hosts
   foreach my $host (sort keys %hosts)
   {
      my $numbers = $hosts{$host};

      if (@$numbers > 1)
      {
         push @clusters, map {$_ != 0 ? $host.$_ : $host} @$numbers;
      } else {
         push @singles, $host;
      }
   }
}

# Public interface
sub nodes()
{
   arguments();
   groups() if %clusters;
   hosts();

   unless (@exclusions)
   {
      return @clusters, @singles;
   } else {
      my @nodes;
      foreach my $node (@clusters, @singles)
      {
         push @nodes, $node unless grep {$node =~ /$_/} @exclusions;
      }
      return @nodes;
   }
}

if (not $called and -t STDIN)
{
   say foreach nodes();
}

1;