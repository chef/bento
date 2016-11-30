#!/bin/bash -eux
dnf -y remove gcc cpp kernel-devel kernel-headers
dnf -y clean all
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
rm -f /tmp/chef*rpm
