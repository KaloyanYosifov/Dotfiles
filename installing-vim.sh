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

cd $ROOT_PATH

if [ -d $HOME/.config/nvim ]; then
    rm -rf $HOME/.config/nvim/
fi

mkdir -p $HOME/.config/nvim/
ln -s $HOME/.vim/coc-settings.json $HOME/.config/nvim/coc-settings.json
ln -s $HOME/.vim/init.vim $HOME/.config/nvim/init.vim
ln -s $HOME/.vim/lua $HOME/.config/nvim/lua
