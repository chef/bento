#!/bin/bash -eux
# These were only needed for building VMware/Virtualbox extensions:
yum -y remove gcc cpp kernel-devel kernel-headers
yum -y clean all
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
rm -f /tmp/chef*rpm

# Remove EPEL remove if it exists
yum -y remove epel-release

# clean up redhat interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules

for ndev in $(ls /etc/sysconfig/network-scripts/ifcfg-*); do
  if [ "$(basename ${ndev})" != "ifcfg-lo" ]; then
    sed -i '/^HWADDR/d' ${ndev}
    sed -i '/^UUID/d' ${ndev}
  fi
done
