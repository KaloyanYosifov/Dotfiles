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

# Install vi mode for zsh
mkdir -p $HOME/.oh-my-zsh/plugins/vi-mode
curl -L https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/vi-mode/vi-mode.plugin.zsh > $HOME/.oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh

# find the line whener we include plugins git and add the vim plugin to the next line
LINE_NUMBER_TO_PUT_NEW_PLUGIN=$(($(cat $HOME/.zshrc | grep -n "plugins=(git)" | grep -Eo '^[^:]+')+1))
sed -i -e "$LINE_NUMBER_TO_PUT_NEW_PLUGIN i\\ 
plugins=(vi-mode)" $HOME/.zshrc
