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

# Install font tools.
brew tap bramstein/webfonttools

# install for arduino
brew tap osx-cross/avr
brew install avr-binutils avr-gcc avrdude

# Install other useful binaries.
brew install imagemagick --with-webp

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


brew install abseil ag act adns aom apr apr-util arduino-cli argon2 aspell assimp augeas autoconf automake aws-elasticbeanstalk awscli bash-completion bdw-gc berkeley-db bfg binutils blueutil boost brotli c-ares ca-certificates cairo ccls certbot choose-gui cjson cmake cmocka composer coreutils cscope curl dav1d dbus dex2jar dialog dns2tcp dnsmasq docutils dos2unix double-conversion edencommon fb303 fbthrift ffmpeg findutils fizz flac fmt folly fontconfig freetds freetype frei0r fribidi gcc gd gdbm gettext gflags ghostscript giflib git git-crypt git-flow-avh git-lfs glfw glib glog gmp gnu-getopt gnupg gnutls go gobject-introspection gradle graphite2 grep grpc guile harfbuzz hexedit highway htop hunspell hwloc icu4c imath isl jansson jasper jbig2dec jemalloc jpeg jpeg-turbo jpeg-xl jq krb5 kubernetes-cli lame ldns leptonica libarchive libass libassuan libavif libb2 libbluray libcbor libdnet libev libevent libffi libfido2 libgcrypt libgpg-error libiconv libidn libidn2 libimagequant libksba libmaxminddb libmetalink libmpc libnghttp2 libogg libpng libpq libproxy libpthread-stubs libraqm librist libsamplerate libslirp libsmi libsndfile libsodium libsoxr libssh libssh2 libtasn1 libtermkey libtiff libtool libunistring libusb libuv libvidstab libvmaf libvorbis libvpx libvterm libx11 libxau libxcb libxdmcp libxext libxrender libyaml libzip little-cms2 llvm lotus lua luajit-openresty luv lynx lz4 lzo m4 macvim mailhog mbedtls md4c minikube mmv moreutils mpdecimal mpfr msgpack mysql mysql-client nasm ncurses neovim nettle nghttp2 nginx npth numpy oniguruma openblas opencore-amr openexr openjdk openjpeg openldap openssh openssl@1.1 openssl@3 opus p11-kit p7zip pcre pcre2 perl php php@7.4 pigz pillow pinentry pixman pkg-config protobuf pv pygments python@3.10 python@3.11 python@3.8 python@3.9 qt qt@5 rav1e re2 readline redis rename rtmpdump rubberband ruby sdl2 sfml sfnt2woff sfnt2woff-zopfli six snappy speex sphinx-doc sqlite sqlmap srt ssdeep subversion tcl-tk telnet tesseract the_silver_searcher theora tidy-html5 tmux tree tree-sitter unbound unibilium unixodbc utf8proc vde volta wangle watch watchman webp wget wimlib wireshark woff2 wp-cli x264 x265 xorgproto xpdf xvid z3 zeromq zimg zlib zookeeper zopfli zstd

# Remove outdated versions from the cellar.
brew cleanup
