#!/bin/bash -eux
if [ -x /usr/bin/dnf ] ; then
  dnf -y remove gcc cpp kernel-devel kernel-headers perl
  dnf -y clean all
else
  yum -y remove gcc cpp kernel-devel kernel-headers perl
  yum -y clean all
fi
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
rm -f /tmp/chef*rpm
