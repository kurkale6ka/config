#! /usr/bin/env zsh

sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
if [[ -f $sysresources ]]
then
   xrdb -merge $sysresources
fi

if [[ -f $sysmodmap ]]
then
   xmodmap $sysmodmap
fi

xrdb -merge ~/.Xresources

# start some programs
if [[ -d /etc/X11/xinit/xinitrc.d ]]
then
   for f in /etc/X11/xinit/xinitrc.d/*.sh
   do
      [[ -x $f ]] && . $f
   done
fi

exec startxfce4
