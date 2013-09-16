#! /usr/bin/env bash

git config --global user.name 'Dimitar Dimitrov'
git config --global user.email mitkofr@yahoo.fr

git config --global core.excludesfile "$HOME"/.gitignore
git config --global core.editor "vim -u $HOME/.vimrc"
git config --global color.ui true

# make 'git pull' on master always use rebase
git config branch.master.rebase true
# setup rebase for every tracking branch
git config --global branch.autosetuprebase always

git config --global diff.tool vimdiff
git config --global difftool.prompt false

git config --global alias.d difftool
git config --global alias.df diff
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.hist "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
git config --global alias.type cat-file -t
git config --global alias.dump cat-file -p

# # Http tunneling
# # --------------

# 1. Download from http://www.agroman.net/corkscrew/
# 2. Install as explained in http://http://www..agroman.net/corkscrew/README
# 3. ssh-keygen -t rsa -C "mitkofr@yahoo.fr", then change the pub key in github

# 4.
# # ~/.ssh/proxy_cmd_for_github
# # 207.97.227.248 <=> ssh.github.com
# corkscrew <company proxy> <company port> 207.97.227.248 443

# 5.
# # ~/.ssh/config
# Host 207.97.227.248
# ProxyCommand corkscrew <company proxy> <company port> %h %p
# Port 443
# ServerAliveInterval 10
# IdentityFile ~/.ssh/id_rsa

# 6.
# # ~/.bashrc
# GIT_PROXY_COMMAND=~/.ssh/proxy_cmd_for_github
