#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function delete_folder {
    if [ -d $1 ]; then
        rm -rf $1
    fi
}

function install_sway {
    delete_folder $HOME/.config/sway 
    ln -s $SCRIPT_DIR/sway $HOME/.config/sway
    echo "Sway config installed"
}

function install_mako {
    delete_folder $HOME/.config/mako 
    ln -s $SCRIPT_DIR/mako $HOME/.config/mako
    echo "Mako config installed"
}

function install_waybar {
    delete_folder $HOME/.config/waybar 
    ln -s $SCRIPT_DIR/waybar $HOME/.config/waybar
    echo "Waybar config installed"
}


install_sway
install_mako
install_waybar
