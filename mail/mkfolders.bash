#! /usr/bin/env bash

folder="$HOME"/mail

accounts=()
accounts+=(google)
accounts+=(work)
accounts+=(yahoo)

for a in "${accounts[@]}"; do
   mkdir -p "$folder/$a"/{drafts,inbox,sent}/{cur,new,tmp}
   mkdir -p "$folder/$a"/inbox/archive/{cur,new,tmp}
done

mkdir -p "$folder"/google/inbox/vim_{dev,use}/{cur,new,tmp}
mkdir -p "$folder"/google/inbox/vim_{dev,use}/archive/{cur,new,tmp}

# "$HOME"/github/config/mail/work.bash
