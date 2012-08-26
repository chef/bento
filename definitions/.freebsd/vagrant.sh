#!/usr/local/bin/bash -leux

sed 's/\[ ! -t 0 \]/true/' /usr/sbin/portsnap > /tmp/portsnap
chmod +x /tmp/portsnap
/tmp/portsnap fetch extract update

cd /usr/ports/emulators/virtualbox-ose-additions
make -DWITHOUT_X11 install clean

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
