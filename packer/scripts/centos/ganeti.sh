#!/bin/bash -eux

# Install growpart
yum -y install cloud-init cloud-utils-growpart
chkconfig cloud-init on

if -n "$(grep \'CentOS release 6\' /etc/redhat-release)" ; then
  yum -y install denyhosts
else
  # Install denyhosts from our local repo
  yum -y install http://packages.osuosl.org/repositories/centos-7/osl/x86_64/denyhosts-2.6-19.el7.centos.noarch.rpm
fi
chkconfig denyhosts on
sed -i -e 's/^PURGE_DENY.*/PURGE_DENY = 5d/' /etc/denyhosts.conf

# No timeout for grub menu
sed -i -e 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/' /etc/default/grub
# No fancy boot screen
grep -q rhgb /etc/default/grub && sed -e 's/rhgb //' /etc/default/grub
# Write out the config
grub2-mkconfig -o /boot/grub2/grub.cfg
