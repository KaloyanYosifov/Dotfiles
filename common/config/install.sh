#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ALACRITTY_PATH=$HOME/.config/alacritty 

if [[ -d $ALACRITTY_PATH ]]; then
    rm -rf $ALACRITTY_PATH
fi

ln -s $SCRIPT_DIR/alacritty $ALACRITTY_PATH
echo "Alacritty config installed"
