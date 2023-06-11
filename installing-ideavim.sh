#! /bin/bash

echo "Installing IDEAVim config"

rm $HOME/.ideavimrc || true
ln -s $(pwd)/.ideavimrc $HOME/.ideavimrc

echo "Config installed"

