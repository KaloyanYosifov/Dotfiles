#! /usr/bin/env bash

set -eu

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

function add_repos {
    repos="https://rpm.librewolf.net/librewolf-repo.repo"
    repos+=" https://download.opensuse.org/repositories/network:im:signal/Fedora_38/network:im:signal.repo"
    repos+=" https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"

    for repo in $repos; do
        sudo dnf config-manager --add-repo $repo
    done
}

function ask_install {
    echo "$1 y/n"
    read should_install

    if [ $should_install = "y" ] || [ $should_install = "yes" ]; then
            return 0
    else
            return 1
    fi
}

function install_packages {
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

    sudo dnf update -y
    sudo dnf groupinstall -y "Development Tools"
    sudo dnf install -y neovim zsh g++ fzf apfs-fuse xclip ripgrep irssi copyq sway waybar alacritty \
        jetbrains-mono-fonts-all wlsunset bemenu mako htop librewolf feh qrencode ansible helm kubernetes-client \
        keepassxc signal-desktop brave-browser brave-keyring zathura mpv git-crypt perl-Image-ExifTool \
        util-linux-user tar tmux alsa-utils mupdf zathura-pdf-mupdf rsync pinentry bind-utils tcpdump qalculate \
        newsboat clang yubikey-manager yubikey-manager-qt parallel slurp imv grim

    echo "Installing additional packages that are not in official repos"
    echo "-----------------------------------------------------------"
    echo ""

    non_repo_packages=(
        "https://github.com/bitwarden/clients/releases/download/desktop-v2023.7.1/Bitwarden-2023.7.1-x86_64.rpm"
        "https://mullvad.net/media/app/MullvadVPN-2023.6_x86_64.rpm"
        "https://github.com/charmbracelet/glow/releases/download/v1.5.1/glow-1.5.1.x86_64.rpm"
    )
    package_names=()

    printf '%s\n' "${non_repo_packages[@]}" | parallel -u curl -O -L

    for package in "${non_repo_packages[@]}"; do
        package_names+=("$SCRIPT_DIR/$(basename $package)")
    done

    sudo dnf install -y ${package_names[@]}

    rm ${package_names[@]}
}

function init_virtualization {
    sudo dnf install -y @virtualization
    sudo usermod -a -G libvirt,kvm "$(whoami)"
}

function install_volta {
    echo "Installing volta"
    curl https://get.volta.sh | bash

    ~/.volta/bin/volta install node@16
}

function install_syncthing {
    $SCRIPT_DIR/install-syncthing.sh
}

function install_lf {
    echo "Installing lf"
    cd $SCRIPT_DIR
    curl -L https://github.com/gokcehan/lf/releases/download/r30/lf-linux-amd64.tar.gz | tar -xzf -
    sudo mv $SCRIPT_DIR/lf /usr/local/bin
    cd -
}

function install_fonts {
    $SCRIPT_DIR/install-fonts.sh
}

function install_common_configuration {
    echo "Installing linux configuration!"
    $SCRIPT_DIR/config/install.sh
    $PARENT_DIR/common/config/install.sh
    $PARENT_DIR/common/link-custom-binaries.sh
}

function install_common_binaries {
    echo "Installing common binaries!"
    $PARENT_DIR/common/install-common-binaries.sh
}

function init_common_binaries {
    echo "Initializing Vimwiki!"
    $PARENT_DIR/common/initialize-vimwiki.sh
}

function install_additional_configuration {
    echo "Installing additional configuration"
    $PARENT_DIR/common/install-ideavim.sh
    $PARENT_DIR/common/install-rust.sh

    # Not so into Haskell for now
    # $PARENT_DIR/common/install-haskell.sh
}

function install_gtklock {
    $SCRIPT_DIR/install-gtklock.sh
}

function install_dragon {
    $SCRIPT_DIR/install-dragon.sh
}

function change_to_zsh_shell {
    echo "Changing to zsh shell for user"
    sudo chsh -s /bin/zsh $(whoami)
    echo "Done! You will have to logout for it to take effect"
}

function install_sway_login {
    echo "Installing sway login"
    echo '[ "$(tty)" = "/dev/tty1" ] && exec sway' >> $HOME/.zlogin
}

function cleanup {
    echo "Running cleanup"
    sudo dnf -y group remove gnome
    sudo dnf -y remove firefox
    sudo systemctl disable gdm
    sudo systemctl stop gdm
    echo "Cleanup done"
}

sudo dnf install -y dnf-plugins-core
add_repos
install_packages
ask_install "Do you want to install virtualization packages?" && init_virtualization
install_volta
ask_install "Do you want to install syncthing?" && install_syncthing
install_lf
install_fonts
install_common_binaries
init_common_binaries
install_common_configuration
install_gtklock
install_dragon
ask_install "Do you want to install additional configuration?" && install_additional_configuration
change_to_zsh_shell
install_sway_login
cleanup
reboot

echo "Installation done! :)"
