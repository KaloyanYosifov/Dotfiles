#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
dry=0

while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--dry" ]]; then
        dry=1
    fi

    shift
done

log() {
    [[ $dry == 1 ]] && echo "[DRY_RUN]: $@" ||echo "$@"
}

execute() {
    log "Executing: $@"

    [[ $dry == 1 ]] && return || "$@"
}

function delete_folder {
    [ -d $1 ] && execute rm -rf $1
}

function install {
    local package=$1
    delete_folder "$HOME/.config/$package"
    execute ln -s "$SCRIPT_DIR/$package" "$HOME/.config/$package"
    log "$package config installed"
}

install yabai
install skhd
install sketchybar
