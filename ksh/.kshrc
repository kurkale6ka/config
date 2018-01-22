alias ll='ls -lhF'
alias lla='ls -lhFA'

alias -- -='cd - >/dev/null'
alias v=vim

# root
# PS1='[$USER@$(hostname|cut -d. -f1) $PWD]\$ '
PS1='[$USER@$(hostname|cut -d. -f1) $(pwd|sed "s:$HOME:~:")]\$ '
