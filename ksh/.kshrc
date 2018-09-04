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

if command -v vim >/dev/null 2>&1
then
  alias v=vim
  alias vd=vimdiff
else
  alias v=vi
fi
alias m=man

bind -m '^L'=clear'^J'

if [[ $USER == root ]]
then
  PS1='[$USER@$(hostname) $PWD]\$ '
else
  PS1='[$USER@$(hostname) $(pwd|sed "s:$HOME:~:")]\$ '
fi
