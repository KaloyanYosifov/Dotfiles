#! /usr/bin/env bash

echo "Installing Fonts"

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

mkdir -p $SCRIPT_DIR/jet-brains-fonts
cd $SCRIPT_DIR/jet-brains-fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
unzip JetBrainsMono.zip -x "*.txt" -x "*.md"
mkdir -p $HOME/.local/share/fonts
mv ./*.ttf $HOME/.local/share/fonts
cd ..
rm -rf $SCRIPT_DIR/jet-brains-fonts
fc-cache -fv
