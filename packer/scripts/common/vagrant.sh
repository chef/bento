#!/bin/bash

mkdir /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys -L \
    'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
