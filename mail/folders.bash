#! /usr/bin/env bash

folder="$HOME"/bla

accounts=()
accounts+=(google)
accounts+=(work)
accounts+=(yahoo)

for a in "${accounts[@]}"; do
   mkdir -p "$folder/$a"/{archive,drafts,inbox,sent}/{cur,new,tmp}
done

mkdir -p "$folder"/google/inbox/vim_{dev,use}/{cur,new,tmp}

# "$HOME"/github/config/mail/work.bash
