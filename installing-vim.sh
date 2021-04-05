#! /usr/bin/env bash

echo "Installing Vim Configuration"
rm -rf $HOME/.vim
git clone https://github.com/KaloyanYosifov/vim-configurations.git $HOME/.vim

ROOT_PATH=$(pwd)

cd $HOME/.vim

# install submodules
git submodule update --init

# set config for vim
echo "source $HOME/.vim/lead.vim" > $HOME/.vimrc 
echo "source $HOME/.vim/ideavim.vim" > $HOME/.ideavimrc 

# install 
vim -c "PluginInstall" -c "q!"

cd $ROOT_PATH

