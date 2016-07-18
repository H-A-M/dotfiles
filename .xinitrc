#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

[ -f $sysresources  ] && xrdb -merge $sysresources
[ -f $userresources ] && xrdb -merge $userresources
[ -f $sysmodmap  ] && xmodmap $sysmodmap
[ -f $usermodmap ] && xmodmap $usermodmap

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xset -b
xbindkeys

# todo: don't do this here
# exec xautolock -time 10 -locker /usr/bin/i3lock-fancy &

exec i3

