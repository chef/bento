#!/bin/bash -eux

# Install growpart
apt-get -y install cloud-init
apt-get -y remove landscape-common

if [ "$(lsb_release -rs)" == "12.04" ] ; then
    apt-get -y install denyhosts cloud-utils
else
  apt-get -y install cloud-guest-utils
  # Install denyhosts from our local repo since its not included
  wget -q -O - \
    http://packages.osuosl.org/repositories/denyhosts/denyhosts_2.6-10_all.deb | \
    dpkg -y --install -
fi

#chkconfig denyhosts on
sed -i -e 's/^PURGE_DENY.*/PURGE_DENY = 5d/' /etc/denyhosts.conf

# No timeout for grub menu
sed -i -e 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/' /etc/default/grub
# Write out the config
update-grub
