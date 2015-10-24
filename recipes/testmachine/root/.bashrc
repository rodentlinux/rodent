# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PS1='\[\e[1;31m\]\u\[\e[00m\]@\[\e[0;31m\]\h\[\e[1;34m\]\w\[\e[00m\]\$ '

# Directory listing
[[ ! -x /usr/bin/dircolors ]] || eval "$(dircolors -b)"
alias ls='ls --color=auto -F'
alias ll='ls -Ahl'

# Some more alias to avoid making mistakes:
alias rm='rm -ri'
alias cp='cp -rid'
alias mv='mv -i'

# My editor
export EDITOR='vim'
alias vi='vim'

# Network
alias ip6='ip -6'

# SystemD
alias start='systemctl start'
alias stop='systemctl stop'
alias restart='systemctl restart'
alias status='systemctl status'
alias cgls='systemd-cgls'
alias cgtop='systemd-cgtop'
alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'

cd
