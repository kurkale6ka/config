#! /usr/bin/env bash

# ssh remote.system.somewhere "tail -n 10 .irssi/fnotify ; : > .irssi/fnotify ; tail -f .irssi/fnotify " | sed -u 's/[<@&]//g' | while read heading message  do  notify-send -i gtk-dialog-info -t 300000 -- "${heading}" "${message}"; done # the sed -u 's/[<@&]//g' is needed as those characters might confuse  notify-send (FIXME: is that a bug or a feature?)

> "$HOME"/.irssi/fnotify
tailf "$HOME"/.irssi/fnotify | sed -u 's/[<@&]//g' |\
while read heading message
do
   notify-send -i gtk-dialog-info -t 30000 -- "$heading" "$message"
done
