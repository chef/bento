#!/bin/sh

# BE VERY CAREFUL IN HERE
# IF ANY COMMAND FAILS, IT WILL NOT REPORT, NOR WILL IT CONTINUE EXECUTION

# disable sshd so we wait for the rc script to aaaaaalmost finish before we
# try to connect via ssh
svcadm disable network/ssh

# setup a home directory
mkdir /home

# create user
groupadd vagrant
useradd -m -s /usr/bin/bash -d /home/vagrant -G vagrant vagrant

# set password - there is no way to set a password non-interactively
perl -pi -e 's/vagrant:UP/vagrant:VrvarmJYR3SHs/g' /etc/shadow

# set up ssh
mkdir /home/vagrant/.ssh
/usr/sfw/bin/wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# set up some ssh defaults
echo GSSAPIAuthentication no >> /etc/ssh/sshd_config
echo LookupClientHostnames no >> /etc/ssh/sshd_config

# install pkgutil because yay
/usr/sfw/bin/wget --no-check-certificate 'http://get.opencsw.org/now' -O /tmp/pkgutil.pkg
echo "mail=\ninstance=overwrite\npartial=nocheck\nrunlevel=nocheck\nidepend=nocheck\nrdepend=nocheck\nspace=nocheck\nsetuid=nocheck\nconflict=nocheck\naction=nocheck\nbasedir=default" > /tmp/noask
pkgadd -a /tmp/noask -d /tmp/pkgutil.pkg all
rm -f /tmp/pkgutil.pkg

# install sudo so that packer functions correctly
/opt/csw/bin/pkgutil -U
/opt/csw/bin/pkgutil -y -i sudo
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/opt/csw/sudoers
echo "Defaults secure_path=/opt/csw/bin:/usr/sfw/bin:/usr/bin:/usr/sbin:/bin:/sbin"
ln -s /opt/csw/bin/sudo /usr/bin/sudo

# install scp so packer can copy stuff
/opt/csw/bin/pkgutil -y -i openssh_client

# add the /opt/csw/lib libraries to the library path the nice way
crle -u -l /lib:/usr/lib:/opt/csw/lib

# reenable ssh because we should be good to go now
svcadm enable network/ssh

# delete ourself!
rm /etc/rc2.d/S99startup.sh
