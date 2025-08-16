#! /usr/bin/env bash

set -eu

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )
PARENT_DIR=$SCRIPT_DIR/..

sudo dnf install -y gcc meson pkgconf scdoc pam-devel wayland-devel gtk3-devel gtk-layer-shell-devel gobject-introspection-devel vapigen

cd $SCRIPT_DIR

rm -rf gtklock || true
rm -rf gtk-session-lock || true

# Install gtk-session-lock
git clone https://github.com/Cu3PO42/gtk-session-lock.git \
    && cd gtk-session-lock \
    && meson setup build \
    && ninja -C build \
    && sudo ninja -C build install \
    && sudo ldconfig \
    && echo "/usr/local/lib64" | sudo tee /etc/ld.so.conf.d/local-lib64.conf \
    && cd ..

# Install gtklock
git clone https://github.com/jovanlanik/gtklock.git \
    && cd gtklock \
    && meson setup builddir \
    && ninja -C builddir \
    && meson install -C builddir \
    && cd .. \
    && sudo mv /usr/local/etc/pam.d/gtklock /etc/pam.d/gtklock \

rm -rf gtklock
