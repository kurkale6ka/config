#! /usr/bin/env perl

@ARGV > 0 or die "Usage: $0 <FILE with hosts|ips>\n";

while (<>) {

   next if /^\s*(?:#|$)/;

   @host = split;
   $host = $host[0] =~ /^\D/ ? $host[0] : $host[1];

   local $/ = '';

   next unless @nics = `ssh -T $host[0] /sbin/ifconfig`;

   print ++$c, ". $host\n---------------------------------------------------\n";

   foreach (@nics) {

      next if /^lo\b/;

      my %nic;

      $nic{'name'} = $1 if /^(\S+)/g;
      $nic{'mac'}  = $1 if /\G.*HWaddr\s+(\S+)/g;
      $nic{'ipv4'} = $1 if /\G.*inet\s+addr:\s*(\S+)/sgc;
      $nic{'ipv6'} = $1 if /\G.*inet6\s+addr:\s*(\S+)/s;

      my @nic;

      print "$nic{'name'} -> " if exists $nic{'name'};

      push @nic,   "MAC: $nic{'mac'}" if exists $nic{'mac'};
      push @nic, "IPv4: $nic{'ipv4'}" if exists $nic{'ipv4'};
      push @nic, "IPv6: $nic{'ipv6'}" if exists $nic{'ipv6'};

      print join ', ', @nic;

      print "\n"
   }
   print "\n"
}
