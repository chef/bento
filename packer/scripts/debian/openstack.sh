#!/bin/bash -eux

apt-get -y remove isc-dhcp-client
apt-get -y install pump cloud-utils cloud-init cloud-initramfs-growroot \
  bash-completion

# Speed up cloud-init by only using Ec2 and a specific metadata url
cat >> /etc/cloud/cloud.cfg << EOF

# Force only Ec2 being enabled
datasource_list: ['Ec2']
datasource:
   Ec2:
     metadata_urls: [ 'http://169.254.169.254' ]
     timeout: 5 # (defaults to 50 seconds)
     max_wait: 10 # (defaults to 120 seconds)
EOF

# Remove default datasource_list
rm -f /etc/cloud/cloud.cfg.d/90_dpkg.cfg

# change GRUB so log tab and console tab in openstack work
if [ -e /etc/default/grub ] ; then
  sed -i -e 's/quiet/console=tty0 console=ttyS0,115200n8 quiet/' \
    /etc/default/grub
  sed -i -e 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
  update-grub
fi

# Only add the secure path line if it is not already present - Debian 7
# includes it by default.
grep -q 'secure_path' /etc/sudoers || sed -i -e '/Defaults\s\+env_reset/a Defaults\tsecure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' /etc/sudoers

# Set up password-less sudo for the debian user
echo 'debian ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99_debian
chmod 440 /etc/sudoers.d/99_debian

# Fix networking to auto bring up eth0 and work correctly with cloud-init
sed -i 's/allow-hotplug eth0/auto eth0/' /etc/network/interfaces
