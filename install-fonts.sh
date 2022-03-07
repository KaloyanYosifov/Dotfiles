#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR
mkdir jetbrains-font
cd jetbrains-font

JETBRAINS_FONT="JetBrainsMono-2.242.zip"

echo "Installing JetBrains font"
curl -LO "https://download.jetbrains.com/fonts/$JETBRAINS_FONT"

unzip "$JETBRAINS_FONT"

mv ./fonts/ttf/JetBrainsMono* $HOME/Library/Fonts/

cd ..

rm -rf jetbrains-font
