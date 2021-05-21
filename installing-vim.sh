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
vim -c "PlugInstall" -c "q!"

# Install coc extensions
mkdir -p ~/.config/coc/extensions
cd ~/.config/coc/extensions
if [ ! -f package.json ]
then
  echo '{"dependencies":{}}'> package.json
fi
# Change extension names to the extensions you need
npm install coc-phpls coc-prettier coc-vetur coc-json coc-eslint coc-tsserver --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod

# Install nerdfont
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
./nerd-fonts/install.sh JetBrainsMono

cd $ROOT_PATH
