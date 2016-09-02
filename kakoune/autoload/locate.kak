def locate -params 1.. %{ %sh{
locate -Ai -0 "$@" | grep -z -vE '~$' | fzf-tmux --read0 -0 -1 -m | while read -r
do
   echo "edit '$REPLY'"
done
}}
