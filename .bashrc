#
# ~/.bashrc
[[ $- != *i* ]] && return

export HISTSIZE=20000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups

export PATH=$PATH:$HOME/.bin

alias feh='feh --image-bg black'
alias calc='calc -p'

alias ls='ls --color=auto'
alias ll='ls -l'
alias lsc='clear; ls'
alias lsg='ls -GAhl'
alias cls='clear'

alias curll='curl -L -O -#'
alias sysu='systemctl --user'

# ww [delay or 2.0s] [command [args ...]]
ww() {
    case $1 in
        *[!0-9]*) watch -t -x sh -c "$(echo -n $@)";;
        *)  watch -n $1 -t -x sh -c "$(for i in ${@:2}; do i+=" "; echo -n "$i"; done)";;
        '') ;;
    esac
}

# q [command [args ...]]
# Quiet a command and suppress output
q() { $@ &>/dev/null; }

tocl() { xclip -selection clipboard $@; }
topr() { xclip -selection primary $@; }




alias logtrack='track.lua --format="%n" >> ~/.tracklist'

PS1='[\u@\h \W]\$ '

