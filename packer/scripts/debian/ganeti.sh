#!/bin/bash -eux

apt-get -y remove isc-dhcp-client
apt-get -y install pump cloud-utils cloud-init cloud-initramfs-growroot

if [ "$(lsb_release -cs)" == "jessie" ] ; then
  wget -q -O denyhosts.deb \
    http://packages.osuosl.org/repositories/denyhosts/denyhosts_2.6-10_all.deb
  dpkg -i denyhosts.deb
  rm -f denyhosts.deb
else
  apt-get -y install denyhosts
fi

#chkconfig denyhosts on
sed -i -e 's/^PURGE_DENY.*/PURGE_DENY = 5d/' /etc/denyhosts.conf

if [ -e /etc/default/grub ] ; then
  # No timeout for grub menu
  sed -i -e 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/' /etc/default/grub
  # Write out the config
  update-grub
fi

# Only add the secure path line if it is not already present - Debian 7
# includes it by default.
grep -q 'secure_path' /etc/sudoers || \
  sed -i -e '/Defaults\s\+env_reset/a Defaults\tsecure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' /etc/sudoers

# Set up password-less sudo for the osuadmin user
echo 'osuadmin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99_osuadmin
chmod 440 /etc/sudoers.d/99_osuadmin

# Fix networking to auto bring up eth0 and work correctly with cloud-init
sed -i 's/allow-hotplug eth0/auto eth0/' /etc/network/interfaces
