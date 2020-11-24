#! /usr/bin/env perl

# ClusterShell groups/nodes
# https://clustershell.readthedocs.io/en/latest/config.html#yaml-group-files
#
# faster than: nodeset -f @cluster | tr -d '[]' | tr , '\n'

package Nodes;

use v5.32.0;
no strict;
# use warnings;

require Exporter;
our @ISA = ('Exporter');
our @EXPORT = ('nodes');

# ClusterShell groups
# web: 'wa[1-3],wb[1-2]'
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

my (%clusters, %hosts, @exclusions);

# Sort arguments into clusters, hosts and exclusions
sub arguments()
{
   foreach (-t STDIN ? @ARGV : <STDIN>)
   {
      chomp;
      unless (/^-./)
      {
         if (/^@[\p{alpha}_]/)
         {
            $clusters{substr $_, 1} = [];
         }
         # host identifier, single digit, IP
         elsif (/^[\p{alpha}_]|^\d+((\.\d+){3})?$/n)
         {
            push $hosts{$_}->@*, $_;
         } else {
            abort "Wrong host $_\n";
         }
      } else {
         my $exclusion = substr $_, 1;
         push @exclusions, qr/\Q$exclusion\E/;
      }
   }

   abort help unless %clusters or %hosts;
}

my (%groups, @hosts);
sub expand_ranges(@);

# Calculate node ranges
sub groups()
{
   open my $clush, '<', $config or abort "$config: $!\n";

   my ($group, $nodes);

   # load groups from config
   while (<$clush>)
   {
      next unless /^\h+\w/;
      ($group, $nodes) = split /:/;
      $group =~ tr/ \t//d;
      $nodes =~ /'(.+)'/;
      $groups{$group} = [split /[\h,]/, $1];
   }

   # groups: skip duplicates, expand nested
   while (my ($group, $nodes) = each %groups)
   {
      next unless grep /^@/, @$nodes;

      my @updated_nodes;

      foreach (@$nodes)
      {
         unless (/^@/)
         {
            push @updated_nodes, $_;
         }
         elsif (exists $groups{substr $_, 1})
         {
            # skip duplicates
            unless (exists $clusters{$group} and exists $clusters{substr $_, 1} or exists $clusters{all})
            {
               # expand
               push @updated_nodes, $groups{substr $_, 1}->@*;
            }
         } else {
            abort "$config: $_ cluster not found. Typo?\n";
         }
      }
      $groups{$group} = \@updated_nodes;
   }

   # calculate ranges
   # wa[1-3],wb[1-2] -> wa-3 wb,
   sub ranges(@)
   {
      my @ranges;
      foreach (@_)
      {
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
      foreach my $group (sort keys %groups)
      {
         push @hosts, expand_ranges ranges sort $groups{$group}->@*;
      }
      return;
   }

   # add expanded nodes
   my @unknown;

   foreach (sort keys %clusters)
   {
      if (exists $groups{$_})
      {
         push @hosts, expand_ranges ranges sort $groups{$_}->@*;
      } else {
         push @unknown, "\@$_";
      }
   }

   return unless @unknown;

   # warn about unknown clusters
   my $s = @unknown > 1 ? 's' : '';

   unless (%clusters or %hosts)
   {
      abort join (', ', @unknown) . " cluster$s not found\n";
   } else {
      warn join (', ', @unknown) . " cluster$s not found\n";
   }
}

sub expand_ranges(@)
{
   my (@hosts, $host, $range, $first, $last);

   foreach (@_)
   {
      # final -
      if (/(?<!\d)[-,]$/)
      {
         chop;
         push @hosts, $_.1, $_.2;
      }
      # x,y,z
      elsif (/,\d+$/)
      {
         ($host, $range) = /(.+?)((?:\d+)?(?:,\d+)+)$/;

         $range = "1$range" if $range =~ /^,/;
         push @hosts, map {$host.$_} sort split /,/, $range;
      }
      # 1-n
      elsif (/-\d+$/)
      {
         ($host, $first, $last) = /(.+?)(\d+)?-(\d+)$/;

         $first //= 1;
         $first < $last or abort "non ascending range detected\n";
         push @hosts, map {$host.$_} $first..$last;
      }
      # no range
      else
      {
         abort "garbage range detected: $_\n" if /[,-]$/;

         # single digit
         if (/^\d+$/)
         {
            push @hosts, ('empty') x $&;
         }
         # host=count
         elsif (/.+=\d+$/)
         {
            my ($host, $count) = split /=/;
            push @hosts, ($host) x $count;
         }
         # host
         else
         {
            push @hosts, $_;
         }
      }
   }

   return @hosts;
}

# Public interface
sub nodes()
{
   arguments();
   groups() if %clusters;

   if (%hosts)
   {
      foreach my $group (sort keys %hosts)
      {
         push @hosts, expand_ranges $hosts{$group}->@*;
      }
   }

   unless (@exclusions)
   {
      return @hosts;
   } else {
      my @nodes;
      foreach my $node (@hosts)
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
