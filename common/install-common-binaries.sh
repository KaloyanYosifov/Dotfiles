#! /usr/bin/env bash

function install_glow {
    echo "Installing glow (this might take a while 5-10 minutes)"
    go install github.com/charmbracelet/glow@v1.5.1
}

install_glow
