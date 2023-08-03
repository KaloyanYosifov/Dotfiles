#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

sudo dnf update -y
sudo dnf groupinstall -y "Development Tools"
sudo dnf config-manager --add-repo https://rpm.librewolf.net/librewolf-repo.repo # Add librewolf repo
sudo dnf install -y neovim zsh g++ fzf apfs-fuse xclip ripgrep irssi copyq sway alacritty \
    jetbrains-mono-fonts-all wlsunset bemenu mako htop librewolf feh qrencode ansible helm kubernetes-client \
    keepassxc

# Install bitwarden
sudo dnf install -y <<< curl https://github.com/bitwarden/clients/releases/download/desktop-v2023.7.1/Bitwarden-2023.7.1-x86_64.rpm

# install mullvad
sudo dnf install -y <<< https://mullvad.net/media/app/MullvadVPN-2023.4_x86_64.rpm

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

function install_syncthing() {
    echo "Do you want to install syncthing? y/n"
    read should_install_syncthing

    if [[ $install_additional == "y" ]] || [[ $install_additional == "yes" ]]; then
        $SCRIPT_DIR/install-syncthing.sh
    fi
}

install_volta
install_brave
install_syncthing

# configure global editor for vim
git config --global core.editor "vim"

echo "Installing linux configuration!"
$SCRIPT_DIR/config/install.sh
$PARENT_DIR/common/config/install.sh
$PARENT_DIR/common/link-custom-binaries.sh

echo "Do you want to install additional configuration? y/n"
read install_additional

if [[ $install_additional == "y" ]] || [[ $install_additional == "yes" ]]; then
    echo "Installing additional configuration"
    $PARENT_DIR/common/install-vim.sh
    $PARENT_DIR/common/install-ideavim.sh
    $PARENT_DIR/common/install-zsh-config.sh
    $PARENT_DIR/common/install-tmux-config.sh
    $PARENT_DIR/common/install-rust.sh

    # Not so into Haskell for now
    # $PARENT_DIR/common/install-haskell.sh
fi
