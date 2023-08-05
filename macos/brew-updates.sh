#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Add font repo
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# do not update on installing
export HOMEBREW_NO_AUTO_UPDATE=1

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install `wget` with IRI support.
brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi

# Install font tools.
brew tap bramstein/webfonttools

# install for arduino
brew tap osx-cross/avr
brew install avr-binutils avr-gcc avrdude

# Install other useful binaries.
brew install imagemagick --with-webp

# install rectangle a new version of spectacles
brew install --cask docker
brew install insomnia \
    rectangle \
    alacritty \
    notion \
    slack \
    docker \
    mullvad \
    bitwarden


brew install pidof lua rg copyq irssi fzf abseil act adns \
    aom apr apr-util argon2 aspell assimp augeas autoconf automake aws-elasticbeanstalk \
    awscli bdw-gc berkeley-db bfg binutils blueutil boost c-ares ca-certificates cairo \
    cjson cmake cmocka composer coreutils cscope curl dbus dex2jar dialog \
    dns2tcp dnsmasq docutils dos2unix double-conversion edencommon fb303 fbthrift ffmpeg findutils \
    fizz flac fmt folly fontconfig freetds freetype frei0r fribidi gcc \
    gd gdbm gettext gflags ghostscript giflib git git-crypt git-flow-avh git-lfs \
    glib glog gmp gnu-getopt gnupg gnutls graphite2 harfbuzz hexedit htop \
    hwloc icu4c imath jemalloc jpeg jpeg-turbo jpeg-xl jq kubernetes-cli lame \
    libarchive libassuan libavif libb2 libdnet libev libevent libffi libfido2 libgcrypt \
    libgpg-error libiconv libidn libidn2 libimagequant libksba libmaxminddb libmetalink libmpc libnghttp2 \
    libogg libpng libpq libproxy libpthread-stubs libraqm librist libsamplerate libslirp libsmi \
    libsndfile libsodium libsoxr libssh2 libtasn1 libtiff libtool libunistring libusb libuv \
    libvidstab libvmaf libvorbis libvpx libvterm libyaml libzip llvm luv lz4 \
    macvim md4c minikube mpfr msgpack mysql-client nasm neovim nginx npth \
    openblas openexr openjdk openjpeg openldap openssh openssl php pigz pinentry \
    pkg-config pv qt rav1e re2 readline redis six sqlite sqlmap \
    srt theora tmux tree tree-sitter unixodbc utf8proc volta wangle watch \
    watchman webp wget wimlib wireshark woff2 x264 x265 lf

# Remove outdated versions from the cellar.
brew cleanup
