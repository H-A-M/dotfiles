#
# ~/.bash_profile

# Why is this already running once?
# [[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

