#! /usr/bin/env bash

_red="$(tput setaf 1 || tput AF 1)"
_res="$(tput sgr0 || tput me)"

if ! command -v git >/dev/null 2>&1
then
   echo "${_red}git not found. abort.${_res}" 1>&2
   exit 1
fi

git config --global user.name 'Dimitar Dimitrov'

git config --global color.ui true
git config --global core.excludesfile "$REPOS_BASE"/config/dotfiles/.gitignore

# mitigate issues when pulling force-pushed commits
git config --global pull.rebase true

# diff
# diftool will use mergetool by default
git config --global merge.tool vimdiff
git config --global difftool.prompt false
git config --global diff.colormoved zebra

if command -v nvim >/dev/null 2>&1
then
   git config --global core.editor nvim
   git config --global mergetool.vimdiff.path nvim
elif command -v vim >/dev/null 2>&1
then
   git config --global core.editor vim
   git config --global mergetool.vimdiff.path vim
fi

# Aliases
git config --global alias.a add
git config --global alias.b 'branch -avv'
git config --global alias.bd '!git fetch --all --prune && git for-each-ref --format "%(refname) %(upstream:track)" refs/heads | perl -l0ne "print s#refs/heads/(.+) \[gone\]#\$1#r if /gone\]$/" | xargs -0 -n1 git branch -D'
git config --global alias.c 'commit -v'
git config --global alias.d 'diff -w'
git config --global alias.l 'log --graph --pretty="%C(auto)%h %C(242)%<(10,trunc)%ar %Cgreen%<(13,trunc)%an%C(auto)%d %s" -n11'
git config --global alias.ll 'log -pw'
# git config --global alias.o checkout
git config --global alias.f 'fetch --all --prune'
git config --global alias.g 'pull --all --prune'
git config --global alias.p push
git config --global alias.pu 'push -u origin HEAD'
git config --global alias.s 'status -sb'
git config --global alias.h help
git config --global alias.o browse
git config --global alias.st status
git config --global alias.cm commit
git config --global alias.co checkout
git config --global alias.bu '!fd --strip-cwd-prefix -FH -td .git | parallel --no-notice --tag --tagstring {//} git -C {//}'
git config --global alias.br '!git -P branch'
git config --global alias.sha '!git -P show --oneline --quiet'
git config --global alias.last '!git -P log -1'
git config --global alias.sw '!git -P show -w'
git config --global alias.di diff
git config --global alias.dt difftool
git config --global alias.mt mergetool

git config --global blame.date format:'%d/%b/%Y %R'
