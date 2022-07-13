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

# aliases
git config --global alias.h help
git config --global alias.o browse
git config --global alias.st status
git config --global alias.cm commit
git config --global alias.co checkout
git config --global alias.sw switch
git config --global alias.br '!git -P branch'
git config --global alias.sha '!git -P show --quiet --oneline'
git config --global alias.last '!git -P log -1'

# mitigate issues when pulling force-pushed commits
git config --global pull.rebase true

# diff
# diftool will use mergetool by default
git config --global merge.tool vimdiff
if command -v nvim >/dev/null 2>&1
then
   git config --global core.editor nvim
   git config --global mergetool.vimdiff.path nvim
elif command -v vim >/dev/null 2>&1
then
   git config --global core.editor vim
   git config --global mergetool.vimdiff.path vim
fi

git config --global difftool.prompt false
git config --global alias.di diff
