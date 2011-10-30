#! /usr/bin/env perl

while (<>) {
   @record = split;
   $db{$record[0]}{$record[1]} += 1;
}

foreach $key (keys %db) {
   foreach $key2 (keys %{$db{$key}}) {
      print "$key: $db{$key}{$key2} $key2\n";
   }
}
