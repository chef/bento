#!/usr/local/bin/bash -x

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
WITHOUT_X11="YES"
EOT

# help out by grabbing the matching sources from virtualbox.org's mirrors
cd /usr/ports/distfiles
ver=`cat /home/vagrant/.vbox_version`
fetch -am http://download.virtualbox.org/virtualbox/$ver/VirtualBox-$ver.tar.bz2

# build virtualbox OSE guest additions
cd /usr/ports/emulators/virtualbox-ose-additions
make -DBATCH package clean

# undo our customizations
sed -i '' -e '/^REFUSE /d' /etc/portsnap.conf
sed -i '' -e '/^WITHOUT_X11/d' /etc/make.conf

# enable the services
cat >> /etc/rc.conf << EOT
vboxguest_enable="YES"
vboxservice_enable="YES"
EOT

# install vagrant insecure ssh key
mkdir /home/vagrant/.ssh
fetch -o /home/vagrant/.ssh/authorized_keys \
    'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
