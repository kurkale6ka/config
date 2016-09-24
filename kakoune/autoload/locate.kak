def locate -params 1.. %{ %sh{
   if [ -n "$TMUX" ]
   then
      locate -Ai -0 "$@" | grep -z -vE '~$' | fzf-tmux --read0 -0 -1 -m | while read -r
      do
         echo "edit '$REPLY'"
      done
   else
      echo 'echo -markup "{Error}locate can only be used inside tmux"'
   fi
}}
