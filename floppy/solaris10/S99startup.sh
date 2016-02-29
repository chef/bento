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
# defaults to a locked account, unlock it
passwd -u vagrant

echo "vagrant user created" >> /tmp/s99log

# set up ssh
mkdir /home/vagrant/.ssh
/usr/sfw/bin/wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# set up some ssh defaults
echo GSSAPIAuthentication no >> /etc/ssh/sshd_config
echo LookupClientHostnames no >> /etc/ssh/sshd_config

echo "SSH Installed" >> /tmp/s99log

# install omnibus-build-essential package
cd /tmp
echo "mail=\ninstance=overwrite\npartial=nocheck\nrunlevel=nocheck\nidepend=nocheck\nrdepend=nocheck\nspace=nocheck\nsetuid=nocheck\nconflict=nocheck\naction=nocheck\nbasedir=default" > /tmp/noask

# install sudo so that packer functions correctly
# NOTE - LOOK HERE FIRST IF THE URL CHANGES!
/usr/sfw/bin/wget http://www.sudo.ws/sudo/dist/packages/Solaris/10/TCMsudo-1.8.15-i386.pkg.gz
gunzip TCMsudo-1.8.15-i386.pkg.gz
pkgadd -a /tmp/noask -d TCMsudo-1.8.15-i386.pkg all
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Defaults secure_path=/usr/local/bin:/usr/sfw/bin:/usr/ccs/bin:/usr/sbin:/usr/bin:/bin:/sbin" >> /etc/sudoers

echo "sudo Installed" >> /tmp/s99log

# reenable ssh because we should be good to go now
svcadm enable network/ssh

# delete ourself!
rm /etc/rc2.d/S99startup.sh

echo "Successfully Finished" >> /tmp/s99log
