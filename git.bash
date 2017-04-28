#! /usr/bin/env bash

git config --global user.name 'Dimitar Dimitrov'
git config --global user.email mitkofr@yahoo.fr

git config --global core.excludesfile "$REPOS_BASE"/config/dotfile/.gitignore
git config --global core.editor "vim -u $REPOS_BASE/vim/.vimrc"
git config --global color.ui true

# make 'git pull' on master always use rebase
# git config branch.master.rebase true

# setup rebase for every tracking branch
git config --global branch.autosetuprebase always

git config --global diff.tool vimdiff
git config --global difftool.prompt false

git config --global alias.d difftool
git config --global alias.df diff
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.msg 'log -1 --pretty=\%B'
git config --global pager.msg false
git config --global alias.sha "rev-parse HEAD"
git config --global alias.st status
git config --global alias.br branch
git config --global alias.l "log --date=short --pretty=format:'%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%an%C(reset) | %s %C(red)%d%C(reset)'"
git config --global alias.lg "log --graph --date=short --pretty=format:'%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%an%C(reset) | %s %C(red)%d%C(reset)'"
git config --global alias.type cat-file -t
git config --global alias.dump cat-file -p
