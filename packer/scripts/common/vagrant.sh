#!/bin/bash -eux

#
# Setup passwordless sudo for vagrant
#
tmpsudo=/tmp/sudo-vagrant
echo 'vagrant  ALL=(ALL) NOPASSWD:ALL' >  $tmpsudo
echo '%vagrant ALL=(ALL) NOPASSWD:ALL' >> $tmpsudo
echo 'Defaults:vagrant !requiretty'    >> $tmpsudo
echo ''                                >> $tmpsudo
chmod 0440 $tmpsudo
mv $tmpsudo /etc/sudoers.d/vagrant

# Remove the includedir for sudoers. On older Ubuntu's (10.04), the includedir
# occurs BEFORE some other definitions. So it is impossible to set passwordless
# sudo for a user that belongs in the admin group (since later rules take
# precedence). These two lines remove the existing includedir and appends it at
# the very end of the file.
sed -i '/#includedir\ \/etc\/sudoers\.d/d' /etc/sudoers
echo ''                           >> /etc/sudoers
echo '#includedir /etc/sudoers.d' >> /etc/sudoers
echo ''                           >> /etc/sudoers

#
# Setup the vagrant authorized key (the user is created as part of the preseed)
#
mkdir /home/vagrant/.ssh
wget --no-check-certificate \
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

#
# In order to keep SSH speedy even when your machine or the Vagrant machine is
# not connected to the internet, set the UseDNS configuration to no in the SSH
# server configuration.
#
# This avoids a reverse DNS lookup on the connecting SSH client which can take
# many seconds.
#
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
