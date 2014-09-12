#!/bin/bash

mkdir /export/home/vagrant/.ssh
wget --no-check-certificate \
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O /export/home/vagrant/.ssh/authorized_keys
chown -R vagrant /export/home/vagrant/.ssh
chmod -R go-rwsx /export/home/vagrant/.ssh
