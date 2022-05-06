#! /bin/bash

export BOOTSTRAP_HASKELL_NONINTERACTIVE=true
export BOOTSTRAP_HASKELL_CABAL_VERSION=3.6.2.0
export BOOTSTRAP_HASKELL_GHC_VERSION=8.10.7

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

ghcup install hls 1.6.1.0
ghcup set hls 1.6.1.0
