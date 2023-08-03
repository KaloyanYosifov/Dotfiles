#! /usr/bin/env bash

echo "Installing zsh configuration"

function add_lead_zsh() {
    echo "#Load the lead sh" >> $HOME/.zshrc
    echo "source \$HOME/.zsh/lead.sh" >> $HOME/.zshrc
}

rm -rf $HOME/.zsh
git clone https://github.com/KaloyanYosifov/zsh-configs.git $HOME/.zsh

! [[ -f $HOME/.zshrc ]] && touch $HOME/.zshrc

cat $HOME/.zshrc | grep "source \$HOME/.zsh/lead.sh" || add_lead_zsh
