#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

echo "Installing tmux config"
rm $HOME/.tmux.conf 2>&1 >> /dev/null || true
ln -s $PARENT_DIR/.tmux.conf $HOME/.tmux.conf
