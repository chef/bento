#!/bin/sh

echo "Creating vagrant user"
useradd -m -k /etc/skel/ -b /export/home -s /usr/bin/bash vagrant
passwd -N vagrant

echo "Adding Vagrant user to sudoers"
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' >> /etc/sudoers
chmod 0440 /etc/sudoers

# add paths and other options to vagrant user's shell
echo "Setting Vagrant user's and root's environment"
echo "export PATH=\$PATH:/opt/omni/bin" >> /export/home/vagrant/.profile
echo "export PATH=\$PATH:/opt/omni/bin" >> /root/.profile

# move /usr/gnu/bin to end of PATH for root and vagrant, since its presence at
# the front breaks vagrant 1.1+
echo "Moving GNU path in Vagrant user's and root's environment"
sed -i -e 's/PATH=\/usr\/gnu\/bin:\(.*\)/PATH=\1:\/usr\/gnu\/bin/' \
    /export/home/vagrant/.profile
sed -i -e 's/PATH=\/usr\/gnu\/bin:\(.*\)/PATH=\1:\/usr\/gnu\/bin/' \
    /root/.profile

# setup the vagrant key
# you can replace this key-pair with your own generated ssh key-pair
echo "Setting the vagrant ssh pub key"
mkdir /export/home/vagrant/.ssh
chmod 700 /export/home/vagrant/.ssh
chown vagrant:root /export/home/vagrant/.ssh
touch /export/home/vagrant/.ssh/authorized_keys
curl -sL http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub > \
    /export/home/vagrant/.ssh/authorized_keys
chmod 600 /export/home/vagrant/.ssh/authorized_keys
chown vagrant:root /export/home/vagrant/.ssh/authorized_keys

# formally add omniti-ms publisher
echo "Adding omniti-ms publisher"
pkg set-publisher -g http://pkg.omniti.com/omniti-ms/ ms.omniti.com

# remove root login from sshd
echo "Removing root login over SSH"
sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
svcadm restart ssh

# update grub menu to lower timeout and remove unnecessary second entry
echo "Updating Grub boot menu"
sed -i -e 's/^timeout.*$/timeout 5/' -e "/^title omniosvar/,`wc -l /rpool/boot/grub/menu.lst | awk '{ print $1 }'` d" /rpool/boot/grub/menu.lst

# Reset resolv.conf
echo "Resetting resolv.conf"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo "Post-install done"
