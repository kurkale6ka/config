#! /usr/bin/env bash

awk '
{
   if (NF != 0) {
      db[$'"$1"'] += $'"$2"'
   }
}
END {
   for (i in db) {
      print i, db[i]
   }
}' "$3"
