#! /bin/bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

function command_exists {
    command -v $1 2>&1 > /dev/null
}

alias ll="ls -laGh"

#github
alias gs="git status"
alias delLGB="git branch --merged | egrep -v \"(^\*|master|main)\" | xargs git branch -d"

#Laravel
alias sail="[ -f ./vendor/bin/sail ] && ./vendor/bin/sail"
alias art="[ -f ./artisan ] && php artisan"

# php
alias phpstan="XDEBUG_MODE=off ./vendor/bin/phpstan analyse"
alias csfix="XDEBUG_MODE=off ./vendor/bin/php-cs-fixer fix"
alias phpunit="XDEBUG_MODE=off ./vendor/bin/phpunit"
alias pest="XDEBUG_MODE=off ./vendor/bin/pest"
alias pf="XDEBUG_MODE=off phpunit --filter"
alias DEBUG_LINE="export XDEBUG_CONFIG=\"idekey=PHPSTORM\";export XDEBUG_SESSION=\"PHPSTORM\""
alias STOP_DEBUG_LINE="unset XDEBUG_CONFIG;unset XDEBUG_SESSION"
alias flushdns="sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache"
alias checkports="sudo lsof -iTCP -sTCP:LISTEN -n -P"
alias clearlocalbranches="git branch | grep -v "master" | xargs git branch -D"
# fixes a bug on M1 mac where ghci has a strange behaviour when you use the arrow keys
alias ghci="TERM=dumb ghci"
alias stack="TERM=dumb stack"
alias tmux="tmux"
alias k="kubectl"
alias hls="haskell-language-server-wrapper"
alias gc="git commit -m"
alias arc="arduino-cli"
alias rust-arduino="cargo generate --git https://github.com/Rahix/avr-hal-template.git"
alias unquarantine="sudo xattr -rd com.apple.quarantine"

# K8s
#k config get-contexts | tr -s ' '  | cut -d ' ' -f2 | tail -n +2
alias kubeExec="function __kube_exec { [ \$# -ne 2 ] && echo 'Usage: kubeExec {namespace} {pod_name}' || k exec -it -n \$1 \$(k get pods -n \$1 | grep \$2 | head -n1 | cut -d' ' -f 1) -- bash }; __kube_exec"
alias kubeContext="function __kube_context { kubectl config get-contexts | tr -s ' ' | tail -n +2 | cut -d ' ' -f2 | fzf | xargs kubectl config use-context }; __kube_context"

# cordova
localCordova="./node_modules/.bin/cordova"
alias cordova="$(if [ -f "$localCordova" ]; then echo "$localCordova"; else echo "cordova"; fi)"

command_exists nvim
if [ $? -eq 0 ]; then
    alias vim="nvim"
fi

# Git aliases
git config --global alias.co checkout
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias nope="git reset --hard"

if [ $machine = "Mac" ]; then
    alias dappv="sudo spctl --master-disable"
    alias eappv="sudo spctl --master-enable"
fi

# use tldr if we have it and run man command
command_exists tldr
if [ $? -eq 0 ]; then
    alias man="tldr"
fi

export EDITOR="$(which vim)"
export VISUAL="$(which vim)"

# use rg if we have it
command_exists rg
if [ $? -eq 0 ]; then
    alias grep="rg"
fi

COPYQ_INITIALIZED=0
command_exists copyq
if [ $? -eq 0 ]; then
    alias pbcopy="tee >( copyq add - ) | copyq copy -"
    alias pbpaste="copyq read 0"
    alias clear_clipboard="seq 0 100 | xargs copyq remove"
    COPYQ_INITIALIZED=1
fi

command_exists xclip
if [ $? -eq 0 ] && [ $COPYQ_INITIALIZED -ne 1 ]; then
    alias xclip="xclip -selection clipboard"
    alias pbcopy="xclip"
fi

if [ $machine = "Linux" ]; then
    alias check-temp='head -n 1 /sys/class/thermal/thermal_zone0/temp | xargs -I{} awk "BEGIN {printf \"%.2f\n\", {}/1000}"'
    alias check-cpus="watch -n 1 'grep \"^[c]pu MHz\" /proc/cpuinfo'"
    alias run-ansible="function run_ansible { ansible --ask-become-pass --become -m \"ansible.builtin.command\" -a \"\$1\" \$2}; run_ansible"
    command_exists qalc && alias calc="qalc"
fi
