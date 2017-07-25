#! /usr/bin/env bash

shopt -s extglob

if [[ $1 == -@(h|-h)* ]]
then
cat << 'HELP'
Usage:
   lay
   lay host_prefix
   lay host_prefix number_of_hosts
   lay host_prefix range (default: 1-3)
   lay host1 host2 ... hostn
HELP
exit 0
fi

_bld="$(tput bold || tput md)"
_ylw="$_bld$(tput setaf 3 || tput AF 3)"
_res="$(tput sgr0 || tput me)"

nb_sessions="$(tmux ls -F#S 2>/dev/null | wc -l)"

#  lay              lay prefix num
#  lay prefix  OR   lay prefix range
if (($# <= 1)) || { (($# == 2)) && [[ $2 == [0-9]* || $2 == [0-9]*-[0-9]* ]]; }
then
   if (($# == 0))
   then
      read -p 'Common host prefix: ' prefix
      read -p 'Range or number of hosts (ex: [1-]3): ' range
   else
      if [[ $2 == [01] ]]
      then
         echo 'Abort. Number > 1 expected' 1>&2
         exit 1
      fi
      prefix="$1"
      range="${2:-1-3}"
   fi

   _prefix="$prefix"

   [[ $range != *-* ]] && range=1-"$range"

   range_start="${range%-*}"
   range_end="${range#*-}"

   nb_hosts="$((range_end - range_start + 1))"

   if ((nb_hosts < 2))
   then
      echo 'Invalid range. Number of hosts must be > 1' 1>&2; exit 2
   elif ((nb_hosts > 10))
   then
      read -p "Are you sure you want to create $nb_hosts panes? (y/n) " answer
      [[ $answer == n* ]] && exit 3
   fi

   # Create a new session named 'tiles'
   ((nb_sessions == 0)) && tmux new -s 'tiles' -d

   # Create a new window named $prefix within the first running session
   tmux new-window -n "$_prefix" "ssh ${_prefix}$range_start"

   for ((i = range_start + 1; i < range_end + 1; i++))
   do
      tmux split-window -t "$_prefix" -h "ssh ${_prefix}$i"

      # Start tiling from the 4th pane since 2 is ok and 3 is a special case
      ((i < range_start + 3)) && continue
      tmux select-layout -t "$_prefix" tiled
   done

# lay host1 host2 ... hostn
else

   # Create a new session named 'tiles'
   ((nb_sessions == 0)) && tmux new -s 'tiles' -d

   _prefix='multi'

   # Create a new window named 'multi' within the first running session
   tmux new-window -n "$_prefix" "ssh $1"

   j=2
   for h in "${@:2}"
   do
      tmux split-window -t "$_prefix" -h "ssh $h"

      # Start tiling from the 4th pane since 2 is ok and 3 is a special case
      ((j++ < 4)) && continue
      tmux select-layout -t "$_prefix" tiled
   done
fi

# 3 hosts case: split the screen vertically in 3 equal panes
if { [[ $nb_hosts ]] && ((nb_hosts == 3)); } || { [[ ! $nb_hosts ]] && (($# == 3)); }
then
   tmux select-layout -t "$_prefix" even-horizontal
fi

tmux select-pane -t "${_prefix}.1"
tmux set-window-option -t "$_prefix" synchronize-panes on

if ((nb_sessions == 0))
then
   tmux kill-window -t1
   tmux attach -t 'tiles'
else
   echo "${_ylw}Attached to the first session!$_res"
fi
