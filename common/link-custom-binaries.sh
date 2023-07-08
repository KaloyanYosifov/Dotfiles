#! /bin/bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

mkdir -p $HOME/.user_bin
ln -s $PARENT_DIR/bin/* $HOME/.user_bin
