#! /bin/bash

WIKI_DIR="$HOME/vimwiki"

[ -d $WIKI_DIR ] && rm -rf $WIKI_DIR

git clone git@github.com:KaloyanYosifov/mywiki.git $WIKI_DIR
