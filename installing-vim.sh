#! /usr/bin/env bash

NVIM_DIR=$HOME/.config/nvim

echo "Installing NVim Configuration"
rm -rf $HOME/.vim || true

if [ -d $NVIM_DIR ]; then
    rm -rf $NVIM_DIR
fi
mkdir -p $NVIM_DIR

git clone https://github.com/KaloyanYosifov/neovim-config $NVIM_DIR

echo "Installing Packer for NVIM"
git clone --depth 1 https://github.com/wbthomason/packer.nvim $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim || true

# set config for vim
# echo "source $HOME/.vim/ideavim.vim" > $HOME/.ideavimrc

# install
vim -c "PackerInstall" -c "q!"

echo "Successfully installed NVim"
