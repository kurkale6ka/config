# Only Emacs mode lets you make use of arrow keys
set -o emacs

# Go back in command history (up arrow)
alias __A=$(echo "\020")

# Go back in command history (down arrow)
alias __B=$(echo "\016")

alias ll='ls -l'
alias lla='ls -lA'

# root
# PS1='[$USER@$(hostname|cut -d. -f1) $PWD]\$ '
PS1='[$USER@$(hostname|cut -d. -f1) $(pwd|sed "s:$HOME:~:")]\$ '
