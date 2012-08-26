#!/usr/local/bin/bash -x

pkg_add -r virtualbox-ose-additions

cat >> /etc/rc.conf << EOT
vboxguest_enable="YES"
vboxservice_enable="YES"
EOT

service vboxguest start
service vboxservice start

mkdir /home/vagrant/.ssh
fetch -o /home/vagrant/.ssh/authorized_keys \
    'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
