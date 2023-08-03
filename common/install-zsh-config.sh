#! /usr/bin/env bash

echo "Installing zsh configuration"

rm -rf $HOME/.zsh
git clone https://github.com/KaloyanYosifov/zsh-configs.git $HOME/.zsh

if ! [[ -f $HOME/.zshrc ]]; then
    touch $HOME/.zshrc
fi

cat $HOME/.zshrc | grep "source \$HOME/.zsh/lead.sh"

if [ $? != 0 ]; then
    echo "#Load the lead sh" >> $HOME/.zshrc
    echo "source \$HOME/.zsh/lead.sh" >> $HOME/.zshrc
fi
