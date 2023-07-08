#! /usr/bin/env bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )

echo "Installing linux configuration!"
$SCRIPT_DIR/config/install.sh
