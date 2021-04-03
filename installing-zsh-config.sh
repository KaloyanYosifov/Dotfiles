#! /usr/bin/env bash

echo "Installing zsh configuration"

sed -i -e 's/ZSH_THEME=".*"/ZSH_THEME="gentoo"/' $HOME/.zshrc

rm -rf $HOME/.zsh
git clone git@github.com:KaloyanYosifov/zsh-configs.git $HOME/.zsh

cat $HOME/.zshrc | grep "source \$HOME/.zsh/lead.sh"

if [ $? != 0 ]; then
    echo "#Load the lead sh" >> $HOME/.zshrc
    echo "source \$HOME/.zsh/lead.sh" >> $HOME/.zshrc
fi
