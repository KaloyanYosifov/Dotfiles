#! /bin/bash

sudo dnf update -y
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y neovim zsh g++ fzf apfs-fuse xclip

function install_brave() {
    echo "Installing brave"
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo dnf install -y brave-browser brave-keyring
}

install();
