#! /bin/bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

mkdir -p $HOME/.local/bin || true
ln -s $PARENT_DIR/bin/* $HOME/.local/bin || true
