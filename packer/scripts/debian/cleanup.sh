#!/bin/bash -eux

apt-get -y autoremove
apt-get -y clean
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
rm -f /tmp/chef*deb

# Remove cdrom apt source
sed -i -e '/^deb cdrom:/d' /etc/apt/sources.list
