#! /usr/bin/env bash

echo "Installing tmux config"
rm $HOME/.tmux.conf 2>&1 >> /dev/null
cp .tmux.conf $HOME
