#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

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
brew install wget --with-iri

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi
brew install nvim
brew install grep
brew install openssh
brew install screen
brew install php
brew install gmp

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
brew install aircrack-ng
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hashpump
brew install hydra
brew install john
brew install knock
brew install netpbm
brew install nmap
brew install pngcheck
brew install socat
brew install sqlmap
brew install tcpflow
brew install tcpreplay
brew install tcptrace
brew install ucspi-tcp # `tcpserver` etc.
brew install xpdf
brew install xz

# Install other useful binaries.
brew install ack
#brew install exiv2
brew install git
brew install git-lfs
brew install gs
brew install git-crypt
brew install imagemagick --with-webp
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install tree
brew install vbindiff
brew install zopfli
brew install volta

# install rectangle a new version of spectacles
brew install --cask \
    rectangle \
    iterm2 \
    flycut \
    notion \
    slack \
    microsoft-edge \
    docker \
    expressvpn \
    karabiner-elements \
    bitwarden


brew install ngrok act aom apr apr-util argon2 aspell augeas autoconf automake awscli bash-completion brotli c-ares cairo certbot curl-openssl dialog dnsmasq ffmpeg flac fontconfig freetds freetype frei0r fribidi gdbm gettext giflib glib gmp gnu-getopt gnutls gradle graphite2 harfbuzz htop icu4c jansson jemalloc jpeg krb5 lame leptonica libass libbluray libev libevent libffi libidn libidn2 libmetalink libogg libpng libpq libsamplerate libsndfile libsodium libsoxr libssh2 libtasn1 libtiff libtool libunistring libvidstab libvorbis libvpx php libzip little-cms2 lz4 lzo mmv mysql nasm ncurses nettle nghttp2 nginx oniguruma opencore-amr openjdk openjpeg openldap openssl@1.1 opus p11-kit p7zip pcre pcre2 perl pigz pixman pkg-config protobuf python python@3.8 qt readline redis rtmpdump rubberband sdl2 snappy speex sqlite sqlmap srt subversion telnet tesseract the_silver_searcher theora tidy-html5 tmux unbound unixodbc utf8proc watch webp wimlib x264 x265 xvid xz



# Remove outdated versions from the cellar.
brew cleanup
