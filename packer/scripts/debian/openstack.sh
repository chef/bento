#!/bin/bash -eux

apt-get -y remove isc-dhcp-client
apt-get -y install pump cloud-utils cloud-init cloud-initramfs-growroot \
  bash-completion

# use our specific config
#mv -f /tmp/cloud.cfg /etc/cloud/cloud.cfg
# remove distro installed package to ensure Ec2 is only enabled
#rm -f /etc/cloud/cloud.cfg.d/90_*

# change GRUB so log tab and console tab in openstack work
if [ -e /etc/default/grub ] ; then
  sed -i -e 's/quiet/console=ttyS0,115200n8 console=tty0 quiet/' \
    /etc/default/grub
  update-grub
fi

# Only add the secure path line if it is not already present - Debian 7
# includes it by default.
grep -q 'secure_path' /etc/sudoers || sed -i -e '/Defaults\s\+env_reset/a Defaults\tsecure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' /etc/sudoers

# Set up password-less sudo for the centos user
echo 'centos ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99_centos
chmod 440 /etc/sudoers.d/99_centos

# Fix networking to auto bring up eth0 and work correctly with cloud-init
sed -i 's/allow-hotplug eth0/auto eth0/' /etc/network/interfaces
