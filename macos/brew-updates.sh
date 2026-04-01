#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we're using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew's installed location.
BREW_PREFIX=$(brew --prefix)

# do not update on installing
export HOMEBREW_NO_AUTO_UPDATE=1

# ==============================================================================
# TAPS
# ==============================================================================

# Zathura
brew tap zegervdv/zathura

# Arduino/AVR tools
brew tap osx-cross/avr

# AeroSpace window manager
brew tap nikitabobko/tap

# ==============================================================================
# CORE UTILITIES
# Install GNU core utilities (those that come with macOS are outdated).
# Don't forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
# ==============================================================================
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# ==============================================================================
# SYSTEM UTILITIES
# ==============================================================================

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed

# Install `wget` with IRI support.
brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# ImageMagick for image manipulation
brew install imagemagick

# ==============================================================================
# ARDUINO/AVR DEVELOPMENT
# ==============================================================================
brew install avr-binutils avr-gcc avrdude

# ==============================================================================
# DESKTOP APPLICATIONS (CASKS)
# ==============================================================================
brew install --cask sf-symbols font-sf-mono font-sf-pro

# Terminal & productivity apps
brew install --cask alacritty

# Security & privacy apps
brew install --cask mullvad-vpn bitwarden

# File sharing & sync
brew install --cask localsend

# Music & media
brew install --cask spotify

# ==============================================================================
# WINDOW MANAGER & BAR
# ==============================================================================
brew install --cask nikitabobko/tap/aerospace
brew install FelixKratz/formulae/sketchybar

# ==============================================================================
# SYSTEM UTILITIES & TOOLS
# ==============================================================================

# Docker and Kubernetes
brew install docker

# Terminal utilities
brew install fzf tmux tree

# File management
brew install copyq

# Audio controls
brew install switchaudio-osx

# Security tools
brew install lulu

# ==============================================================================
# DEVELOPMENT TOOLS
# ==============================================================================

# Languages
brew install go lua php

# Package managers
brew install cmake composer

# Version control
brew install git git-crypt git-lfs

# Database tools
brew install mysql-client

# ==============================================================================
# NETWORKING & SECURITY
# ==============================================================================
brew install curl dns2tcp dnsmasq openssh openssl

# ==============================================================================
# MEDIA & IMAGE PROCESSING
# ==============================================================================
brew install ffmpeg flac freetype giflib jpeg jpeg-turbo jpeg-xl \
    libavif libpng libsndfile libvorbis libvpx libwebp \
    mpv

# ==============================================================================
# DEPENDENCIES & LIBRARIES
# ==============================================================================
brew install argon2 augeas autoconf automake bdw-gc berkeley-db \
    binutils boost cjson cmake cmocka cscope dbus docutils dos2unix \
    double-conversion ffmpeg fontconfig freetds freetype \
    frei0r fribidi gcc gd gdbm gettext gflags giflib glib glog \
    gmp gnu-getopt gnutls graphite2 harfbuzz hexedit htop \
    hwloc icu4c imath jemalloc jpeg-turbo jsonnet jq kubernetes-cli \
    lame libarchive libassuan libb2 libdnet libev libevent \
    libffi libfido2 libgcrypt libgpg-error libiconv libidn \
    libidn2 libimagequant libksba libmaxminddb libmetalink \
    libmpc libnghttp2 libogg libpq libproxy libpthread-stubs \
    libraqm librist libsamplerate libslirp libsmi libsndfile \
    libsodium libsoxr libssh2 libtasn1 libtiff libtool \
    libunistring libusb libuv libvidstab libvmaf libvorbis \
    libvpx libvterm libyaml libzip llvm luv lz4 md4c mpfr \
    msgpack nasm nginx npth openblas openexr openjpeg openldap \
    openssl openjdk pigz pinentry pkg-config sqlite tmux tree \
    tree-sitter unixodbc volta webp wimlib woff2 x264 x265

# ==============================================================================
# EDITORS & TERMINAL APPS
# ==============================================================================
brew install nvim neovim glow newsboat

# ==============================================================================
# FORMATTERS & LINTERS
# ==============================================================================
brew install yamlfmt jsonnetfmt isort ruff stylua sqruff taplo

# ==============================================================================
# FONT PACKAGES
# ==============================================================================
brew install font-jetbrains-mono font-jetbrains-mono-nerd-font

# ==============================================================================
# INFRASTRUCTURE & CLOUD TOOLS
# ==============================================================================
brew install terraform terragrunt glab

# ==============================================================================
# AI & ML
# ==============================================================================
brew install llama.cpp rtk

# ==============================================================================
# ZATHURA PDF VIEWER
# Install mupdf and zathura plugin in another command, so we do not break the first one
# ==============================================================================
brew install mupdf zathura-pdf-mupdf || echo "Zathura plugins could not be installed :("

# Remove outdated versions from the cellar.
brew cleanup
