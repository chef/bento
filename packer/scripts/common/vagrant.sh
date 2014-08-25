#!/bin/bash

mkdir /home/vagrant/.ssh
wget --no-check-certificate \
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys

# Guard for empty authorized_keys file, wget with error creates an empty file
if [ ! -s $file ]; then
    echo "Unable to download Vagrant public key"
    exit 1
fi
    
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
