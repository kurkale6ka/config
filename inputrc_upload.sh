#! /usr/bin/env bash
#
# Push .inputrc file to hosts

shopt -s extglob

# Help
if [[ $1 == -@(h|-h)* ]] || (($# == 0)); then
read -r -d '' info << 'HELP'
Usage: inputrc_upload {user} {host}...
       inputrc_upload {file}
       ---
       user1 host1
       user2 host2
HELP
if (($#))
then echo "$info"    ; exit 0
else echo "$info" >&2; exit 1
fi
fi

# associative array:
#    hosts[host1]=user1
#    hosts[host2]=user2
declare -A hosts

# read hosts on the command line
if (($# > 1)); then
   for host in "${@:2}"
   do hosts["$host"]="$1"
   done
# read hosts from file
else
   while read -r user host _; do
      if [[ $user != \#* ]]
      then hosts["$host"]="$user"
      fi
   done < "$1"
fi

# Green, Blue, Reset
lg=$(printf %s "$Bold"; tput setaf 2)
lb=$(printf %s "$Bold"; tput setaf 4)
r=$(tput sgr0)

for host in ${!hosts[@]}; do

   if [[ ${hosts[$host]} == 'root' ]]
   then home=/root
   else home=/home/"${hosts[$host]}"
   fi

   echo "$lg${hosts[$host]} $lb@ $lg$host$r"
   rsync -vL --recursive --links --stats --progress "$HOME"/.inputrc "$host":"$home"/.inputrc
done
