#! /usr/bin/env bash

[[ -r $HOME/.dir_colors ]] && eval "$(dircolors $HOME/.dir_colors)"

mkdir -p /tmp/dircolors
cd /tmp/dircolors || exit 1

touch                 \
README                \
Readme_plain.txt      \
file                  \
script.rb             \
script_config.yml     \
script_exe            \
script.patch          \
messages.log          \
messages.tar.gz       \
cacert.pem            \
caserver.csr          \
markup_index.html     \
markup_simulation.tex \
image.jpg             \
audio.midi            \
audio.axa             \
audio.axv             \
binary_doc.pdf        \
link.url              \
object.so             \
osys.dll              \
backup.bak            \
bdelete.old           \
setuid                \
setgid

chmod u+x script_exe
chmod u+s setuid
chmod g+s setgid

mkdir -p directory missing_dir setOW setsticky setstickyOW

chmod o+w setOW
chmod +t setsticky
chmod +t,o+w setstickyOW

[[ ! -h linksym     ]] && ln -sT directory   linksym
[[ ! -h link_broken ]] && ln -sT missing_dir link_broken
rmdir missing_dir

echo '/tmp/dircolors:'
command ls -FB --color=auto
echo

echo '/dev:'
command ls -FB --color=auto /dev
