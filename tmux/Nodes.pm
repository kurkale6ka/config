#! /usr/bin/env perl

# ClusterShell nodes for lay.pl
# faster than: nodeset -f @cluster | tr -d '[]' | tr , '\n'

package Nodes;

# use strict;
# use warnings;
use feature 'say';

require Exporter;
our @ISA = ('Exporter');
our @EXPORT = ('nodes');

my $called = caller;

sub abort
{
   $called ? warn @_ : die @_;
}

# Help
sub help()
{
   my $h_nodes = << 'MSG';
Expand nodes with ranges

nodes @cluster ... node[range] ... [-exclude] ...
-xa would remove any line matching this litteral (xa)

MSG

   my $h_ranges = << 'MSG';
Ranges:
  - or , : 1 and 2
      -3 : 1 to 3
     3-6 : 3 to 6
   3,5,9 : unchanged
      =2 : 2 instances
       4 : 4 'empty' nodes (for shell tiles with 'lay')

 In: node- node,3,7 node=2 node4-6 3
Out: node1 node1    node   node4   +- shell tiles
     node2 node3    node   node5
           node7           node6
MSG

   return $called ? $h_ranges : $h_nodes.$h_ranges;
}

if (@ARGV == 0)
{
   die help unless $called;
}

my $config = "$ENV{XDG_CONFIG_HOME}/clustershell/groups.d/cluster.yaml";

my (%clusters, @hosts, @exclusions);

foreach (-t STDIN ? @ARGV : <STDIN>)
{
   chomp;
   unless (/^-./)
   {
      if (/^@\w/)
      {
         my $cluster = substr $_, 1;
         # cluster -> [regex, ranges]
         $clusters{$cluster} = [qr/\Q$cluster\E/];
      }
      elsif (/^\w/)
      {
         push @hosts, $_;
      }
   } else {
      my $exclusion = substr $_, 1;
      push @exclusions, qr/\Q$exclusion\E/;
   }
}

unless (%clusters or @hosts)
{
   die help unless $called;
}

if (%clusters)
{
   open my $clush, '<', $config or abort "$config: $!\n";

   my $cluster_count = keys %clusters;
   my %cluster_found;

   while (<$clush>)
   {
      next if /^\s*#/;

      foreach my $key (keys %clusters)
      {
         # config example
         # web: 'wa[1-3],wb[1-2]'
         if (/\b$clusters{$key}->[0]:\s*'(.+)'/)
         {
            push $clusters{$key}->@*, map {
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

            $cluster_found{$key} = 1;
         }
      }

      goto RANGES if $cluster_count == keys %cluster_found;
   }

   unless (keys %cluster_found)
   {
      my $s = $cluster_count > 1 ? 's' : '';
      unless (@hosts)
      {
         abort join (', ', keys %clusters), " cluster$s not found\n";
      } else {
         warn join (', ', keys %clusters), " cluster$s not found\n";
      }
   } else {
      foreach (keys %clusters)
      {
         warn "$_ cluster not found\n" unless exists $cluster_found{$_};
      }
   }
}

# Calculate Ranges
RANGES:
my %hosts;

foreach (@hosts, map {@$_[1..$#$_]} values %clusters)
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

# List of hosts, clusters first
my (@clusters, @singles);

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

# Public interface
sub nodes()
{
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
