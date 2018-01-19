alias ll='ls -l'
alias lla='ls -lA'

# root
# PS1='[$USER@$(hostname|cut -d. -f1) $PWD]\$ '
PS1='[$USER@$(hostname|cut -d. -f1) $(pwd|sed "s:$HOME:~:")]\$ '
