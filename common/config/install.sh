#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install_alacritty {
    echo "Installing alacritty"

    ALACRITTY_PATH=$HOME/.config/alacritty

    [ -d $ALACRITTY_PATH ] && rm -rf $ALACRITTY_PATH

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

    [ -d $LF_PATH ] && rm -rf $LF_PATH

    ln -s $SCRIPT_DIR/lf $LF_PATH

    echo "LF config installed"
}

function install_tmux {
    echo "Installing tmux config"

    TMUX_PATH=$HOME/.config/tmux

    [ -d $TMUX_PATH ] && rm -rf $TMUX_PATH

    ln -s $SCRIPT_DIR/tmux $TMUX_PATH

    echo "Tmux config installed"
}

function install_zsh_config {
    echo "Installing zsh config"

    ZSH_FOLDER_PATH=$HOME/.config/zsh

    [ -d $ZSH_FOLDER_PATH ] && rm -rf $ZSH_FOLDER_PATH

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

    [ -d $NVIM_FOLDER_PATH ] && rm -rf $NVIM_FOLDER_PATH

    ln -s $SCRIPT_DIR/nvim $NVIM_FOLDER_PATH

    mkdir -p $HOME/.vim/projects

    echo "NeoVim config installed"
}

function install_newsboat {
    echo "Installing newsboat config"

   NEWSBOAT_FOLDER_PATH=$HOME/.config/newsboat

   [ -d $NEWSBOAT_FOLDER_PATH ] && rm -rf $NEWSBOAT_FOLDER_PATH

    ln -s $SCRIPT_DIR/newsboat $NEWSBOAT_FOLDER_PATH

    echo "Newsboat config installed"
}

function install_mpv {
    echo "Installing mpv config"

   MPV_FOLDER_PATH=$HOME/.config/mpv

   [ -d $MPV_FOLDER_PATH ] && rm -rf $MPV_FOLDER_PATH

    ln -s $SCRIPT_DIR/mpv $MPV_FOLDER_PATH

    echo "MPV config installed"
}

install_alacritty
install_gitconfig
install_lf
install_tmux
install_zsh_config
install_neovim_config
install_newsboat
install_mpv
