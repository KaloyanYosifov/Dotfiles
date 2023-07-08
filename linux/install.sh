#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )

sudo dnf update -y
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y neovim zsh g++ fzf apfs-fuse xclip ripgrep irssi copyq sway

function install_brave() {
    echo "Installing brave"
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo dnf install -y brave-browser brave-keyring
}

function install_volta() {
    echo "Installing volta"
    curl https://get.volta.sh | bash

    volta install node@16
}

install_volta
install_brave

# configure global editor for vim
git config --global core.editor "vim"

echo "Installing linux configuration!"
$SCRIPT_DIR/config/install.sh
