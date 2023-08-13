#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install_alacritty {
    ALACRITTY_PATH=$HOME/.config/alacritty 

    if [[ -d $ALACRITTY_PATH ]]; then
        rm -rf $ALACRITTY_PATH
    fi

    ln -s $SCRIPT_DIR/alacritty $ALACRITTY_PATH
    echo "Alacritty config installed"
}

function install_gitconfig {
    GITCONFIG_PATH=$HOME/.config/gitconfig 
    GITCONFIG_FILE=$HOME/.gitconfig 

    mkdir -p $GITCONFIG_PATH
    
    for file in $(ls -a $SCRIPT_DIR/gitconfig); do
        # do not use . and .. and .gitconfig is not part of gitconfig folder
        if [[ $file == "." ]] || [[ $file == ".." ]] || [[ $file == ".gitconfig" ]]; then
            continue
        fi

        # We only copy instead of symlinking as we might need to add other gitconfigs in init
        echo "Installing file: $file"
        cp $SCRIPT_DIR/gitconfig/$file $GITCONFIG_PATH/$file
    done

    echo "Installing file: .gitconfig"

    # on the otherhand we want gitconfig to be symlinked
    rm $HOME/.gitconfig
    ln -s $SCRIPT_DIR/gitconfig/.gitconfig $HOME/.gitconfig

    echo "Gitconfig installed"
}

function install_lf {
    echo "Installing lf configs"

    LF_PATH=$HOME/.config/lf

    if [[ -d $LF_PATH ]]; then
        rm -rf $LF_PATH
    fi

    ln -s $SCRIPT_DIR/lf $LF_PATH

    echo "LF config installed"
}

function install_tmux {
    echo "Installing tmux config"

   TMUX_PATH=$HOME/.config/tmux

    if [[ -d $TMUX_PATH ]]; then
        rm -rf $TMUX_PATH
    fi

    ln -s $SCRIPT_DIR/tmux $TMUX_PATH

    echo "Tmux config installed"
}

function install_zsh_config {
    echo "Installing zsh config"

   ZSH_FOLDER_PATH=$HOME/.config/zsh

    if [[ -d $ZSH_FOLDER_PATH ]]; then
        rm -rf $ZSH_FOLDER_PATH
    fi

    ln -s $SCRIPT_DIR/zsh $ZSH_FOLDER_PATH

    function add_lead_zsh {
        echo "#Load the lead sh" >> $HOME/.zshrc
        echo "source \$HOME/.config/zsh/lead.sh" >> $HOME/.zshrc
    }

    [[ -f $HOME/.zshrc ]] || touch $HOME/.zshrc

    cat $HOME/.zshrc | grep "source \$HOME/.config/zsh/lead.sh" || add_lead_zsh

    echo "ZSH config installed"
}

function install_neovim_config {
    echo "Installing neovim config"

   NVIM_FOLDER_PATH=$HOME/.config/nvim

    if [[ -d $NVIM_FOLDER_PATH ]]; then
        rm -rf $NVIM_FOLDER_PATH
    fi

    ln -s $SCRIPT_DIR/nvim $NVIM_FOLDER_PATH

    mkdir -p $HOME/.vim/projects

    echo "Installing Packer"
    git clone --depth 1 https://github.com/wbthomason/packer.nvim $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim || true

    # install packages
    nvim -c "PackerInstall"
    # install chad deps
    nvim -c "CHADdeps"

    echo "NeoVim config installed"
}

install_alacritty
install_gitconfig
install_lf
install_tmux
install_zsh_config
install_neovim_config
