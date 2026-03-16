#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Add repos
brew tap zegervdv/zathura

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
brew install gnu-sed

# Install `wget` with IRI support.
brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# install for arduino
brew tap osx-cross/avr
brew install avr-binutils avr-gcc avrdude

# Install other useful binaries.
brew install imagemagick

brew install docker alacritty mullvad-vpn bitwarden localsend

# install yabai, sketchybar and skhd
brew install koekeishiya/formulae/yabai \
    koekeishiya/formulae/skhd \
    FelixKratz/formulae/sketchybar

brew install --cask sf-symbols font-sf-mono font-sf-pro

brew install go lua rg copyq irssi fzf \
    argon2 augeas autoconf automake \
    awscli bdw-gc berkeley-db binutils boost \
    cjson cmake cmocka composer coreutils cscope curl dbus dex2jar dialog \
    dns2tcp dnsmasq docutils dos2unix double-conversion edencommon fb303 fbthrift ffmpeg findutils \
    fizz flac fmt folly fontconfig freetds freetype frei0r fribidi gcc \
    gd gdbm gettext gflags giflib git git-crypt git-lfs \
    glib glog gmp gnu-getopt gnupg gnutls graphite2 harfbuzz hexedit htop \
    hwloc icu4c imath jemalloc jpeg jpeg-turbo jpeg-xl jq kubernetes-cli lame \
    libarchive libassuan libavif libb2 libdnet libev libevent libffi libfido2 libgcrypt \
    libgpg-error libiconv libidn libidn2 libimagequant libksba libmaxminddb libmetalink libmpc libnghttp2 \
    libogg libpng libpq libproxy libpthread-stubs libraqm librist libsamplerate libslirp libsmi \
    libsndfile libsodium libsoxr libssh2 libtasn1 libtiff libtool libunistring libusb libuv \
    libvidstab libvmaf libvorbis libvpx libvterm libyaml libzip llvm luv lz4 \
    md4c minikube mpfr msgpack mysql-client nasm nvim nginx npth \
    openblas openexr openjdk openjpeg openldap openssh openssl php pigz pinentry \
    pkg-config sqlite tmux tree tree-sitter unixodbc volta \
    webp wget wimlib woff2 x264 x265 font-jetbrains-mono font-jetbrains-mono-nerd-font \
    mpv glow newsboat switchaudio-osx lulu terraform terragrunt glab llama.cpp spotify
 
# formatters and linters
brew install yamlfmt jsonnetfmt isort ruff stylua sqruff taplo

# Install mupdf and zathura plugin in another command, so we do not break the first one
brew install mupdf zathura-pdf-mupdf || echo "Zathura plugins could not be installed :("

# Remove outdated versions from the cellar.
brew cleanup
