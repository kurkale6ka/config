#! /usr/bin/env zsh

sysmodmap=/etc/X11/xinit/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources

# Merge in system .Xmodmap
if [[ -f $sysmodmap ]]
then
   xmodmap $sysmodmap
fi

# Merge in system .Xresources
if [[ -f $sysresources ]]
then
   xrdb -merge $sysresources
fi

xrdb -merge ~/.Xresources

# Source other xinitrc files
if [[ -d /etc/X11/xinit/xinitrc.d ]]
then
   for f in /etc/X11/xinit/xinitrc.d/*
   do
      [[ -x $f ]] && . $f
   done
fi

exec startxfce4
# compton -b
# exec i3
