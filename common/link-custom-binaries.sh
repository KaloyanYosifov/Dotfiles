#! /bin/bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )

mkdir -p $HOME/.local/bin || true
ln -s $SCRIPT_DIR/bin/* $HOME/.local/bin || true

echo "Installed custom binaries"
