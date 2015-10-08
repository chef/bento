#!/bin/bash

# The ISO install doesn't set a timeout or default
mount /dev/sda1 /boot
chmod +w /boot/boot/grub/grub.cfg
sed -i '1i timeout=1' /boot/boot/grub/grub.cfg
chmod -w /boot/boot/grub/grub.cfg

# Add vagrant
groupadd vagrant
useradd -g vagrant vagrant
passwd -d vagrant

echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# Vagrant detects windriver as being redhat so it attempts to update networking.
# Unless we patch vagrant we'll just have to rely on this hackery
mkdir -p /etc/sysconfig/network-scripts || true
touch /etc/sysconfig/network-scripts/ifcfg-fake
touch /etc/sysconfig/network
ln -s /etc/init.d/networking /etc/init.d/network

# Setup SSH
mkdir -p /home/vagrant/.ssh
wget --no-check-certificate "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub" -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
echo 'AuthorizedKeysFile /home/%u/.ssh/authorized_keys' >> /etc/ssh/sshd_config

# Until install.sh supports cisco we gotta bundle it in
rpm -Uvh /tmp/chef-12.4.0.dev.x86_64.rpm
rm /tmp/chef-12.4.0.dev.x86_64.rpm
