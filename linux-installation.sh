#! /bin/bash

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )

$SCRIPT_DIR/link-custom-binaries.sh
$SCRIPT_DIR/linux/install.sh

