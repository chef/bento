#!/bin/bash -eux

mkdir /tmp/vbox
VER=$(cat /home/vagrant/.vbox_version)
wget http://download.virtualbox.org/virtualbox/$VER/VBoxGuestAdditions_$VER.iso
mount -o loop VBoxGuestAdditions_$VER.iso /tmp/vbox
sh /tmp/vbox/VBoxLinuxAdditions.run
umount /tmp/vbox
rmdir /tmp/vbox
rm *.iso

mkdir /home/vagrant/.ssh
wget --no-check-certificate \
    'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
