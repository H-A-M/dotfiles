#
# ~/.bashrc
[[ $- != *i* ]] && return

export HISTSIZE=20000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups

export PATH=$PATH:$HOME/.bin

alias ls='ls --color=auto'
alias ll='ls -l'
alias lsc='clear; ls --color=auto'
alias lsg='ls -GAhl'
alias cls='clear'
alias feh='feh --image-bg black'
alias curll='curl -L -O -#'
alias sysu='systemctl --user'

toclipboard() { xclip -selection clipboard $@; }
toprimary() { xclip -selection primary $@; }


# Quiet a command and suppress stdout
q() { $@ 1>/dev/null; }
alias logtrack='track.lua --format="%n" >> ~/.tracklist'

PS1='[\u@\h \W]\$ '

