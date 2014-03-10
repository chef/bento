#!/bin/bash -eux
yum -y remove gcc cpp kernel-devel kernel-headers perl
yum -y clean all
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
rm -f /tmp/chef*rpm
