#! /bin/bash

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
exec $SHELL -l

ghcup install cabal 3.6.2.0
ghcup install hls 1.6.1.0
ghcup install ghc 8.10.7
