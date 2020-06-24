#! /usr/bin/env bash

_red="$(tput setaf 1 || tput AF 1)"
_res="$(tput sgr0 || tput me)"

if ! command -v git >/dev/null 2>&1
then
   echo "${_red}git not found. abort.${_res}" 1>&2
   exit 1
fi

git config --global user.name 'Dimitar Dimitrov'
git config --global user.email mitkofr@yahoo.fr

git config --global color.ui true
git config --global core.excludesfile "$REPOS_BASE"/config/dotfiles/.gitignore
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.co checkout

# branch
git config --global alias.br branch

# setup rebase for every tracking branch
git config --global branch.autosetuprebase always

# make 'git pull' on master always use rebase
# git config branch.master.rebase true

# diff
# diftool will use mergetool by default
git config --global merge.tool vimdiff
if command -v nvim >/dev/null 2>&1
then
   git config --global mergetool.vimdiff.path nvim
fi

git config --global difftool.prompt false
git config --global alias.d difftool

git config --global alias.df diff

# log
git config --global alias.l "log --date=short --pretty=format:'%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%an%C(reset) | %s %C(red)%d%C(reset)'"
git config --global alias.lg "log --graph --date=short --pretty=format:'%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%an%C(reset) | %s %C(red)%d%C(reset)'"

git config --global alias.msg 'log -1 --pretty=\%B'
git config --global pager.msg false

git config --global alias.sha "rev-parse HEAD"

# cat
git config --global alias.type cat-file -t
git config --global alias.dump cat-file -p
