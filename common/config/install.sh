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

install_alacritty
install_gitconfig
install_lf
install_tmux
