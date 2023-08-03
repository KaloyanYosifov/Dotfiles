#! /usr/bin/env bash

echo "Installing syncthing version 1.23.6"

case $(arch) in
    x86_64)
        arch="amd64"
        ;;
    aarch64)
        arch="arm64"
        ;;
    *)
        arch="$ARCH"
        ;;
esac

echo "Arch is: $arch"
sleep 2

directory="syncthing-linux-$arch-v1.23.6"
curl -L "https://github.com/syncthing/syncthing/releases/download/v1.23.6/$directory.tar.gz" | tar -xzf -

cd $directory

sudo mv ./syncthing /usr/bin/
sudo mv ./etc/linux-sysctl/30-syncthing.conf /etc/sysctl.d/
sudo mv ./etc/linux-systemd/user/syncthing.service /etc/systemd/user/

sudo sysctl -q --system

echo "Deleting syncting temp directory"
cd ..
rm -rf $directory
