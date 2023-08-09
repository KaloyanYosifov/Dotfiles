#! /usr/bin/env bash

set -eu

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

sudo dnf install -y gcc make pkgconf scdoc pam-devel wayland-devel gtk3-devel gtk-layer-shell-devel

cd $SCRIPT_DIR
git clone https://github.com/jovanlanik/gtklock.git
cd gtklock

make
sudo make install

cd ..
rm -rf gtklock
