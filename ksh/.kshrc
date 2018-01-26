alias l='ls -hF'
alias ll='ls -lhF'
alias la='ls -hFA'
alias lla='ls -lhFA'
alias ld='ls -hFd'
alias lld='ls -lhFd'
alias lm='ls -hFtr'
alias llm='ls -lhFtr'

alias -- -='cd - >/dev/null'
alias 1='cd ..'
alias 2='cd ../..'
alias 3='cd ../../..'
alias 4='cd ../../../..'
alias 5='cd ../../../../..'
alias 6='cd ../../../../../..'
alias 7='cd ../../../../../../..'
alias 8='cd ../../../../../../../..'
alias 9='cd ../../../../../../../../..'

alias cp='cp -i'
alias mv='mv -i'

alias v=vim
alias m=man

bind -m '^L'=clear'^J'

# root
# PS1='[$USER@$(hostname|cut -d. -f1) $PWD]\$ '
PS1='[$USER@$(hostname|cut -d. -f1) $(pwd|sed "s:$HOME:~:")]\$ '
