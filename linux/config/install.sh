#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ -d $HOME/.config/sway ]]; then
    rm -rf $HOME/.config/sway 
fi

ln -s $SCRIPT_DIR/sway $HOME/.config/sway
echo "Sway config installed"
