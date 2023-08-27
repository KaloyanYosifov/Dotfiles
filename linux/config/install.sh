#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function delete_folder {
    [ -d $1 ] && rm -rf $1
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

function install_gtk {
    delete_folder $HOME/.config/gtk-3.0 
    ln -s $SCRIPT_DIR/gtk-3.0 $HOME/.config/gtk-3.0
    echo "GTK 3.0 config installed"
}

install_sway
install_mako
install_waybar
install_gtk
