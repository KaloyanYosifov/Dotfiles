#!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

source $HOME/.cargo/env

rustup default stable
rustup component add clippy
rustup component add rust-analyzer

# for arduino
cargo +stable install ravedude
cargo install cargo-generate
