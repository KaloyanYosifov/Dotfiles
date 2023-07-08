#! /bin/bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

echo "Installing IDEAVim config"

rm $HOME/.ideavimrc || true
ln -s $PARENT_DIR/.ideavimrc $HOME/.ideavimrc

echo "Config installed"

