#! /usr/bin/env bash

set -eu

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

cd $SCRIPT_DIR
git clone https://github.com/mwh/dragon.git
cd dragon

make
sudo make install

cd ..
rm -rf dragon
