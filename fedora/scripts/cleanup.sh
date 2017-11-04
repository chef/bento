#!/bin/bash -eux
echo "Removing development packages and cleaning up DNF data"
dnf -y remove gcc cpp gc kernel-devel kernel-headers glibc-devel glibc-headers kernel-devel kernel-headers make perl
dnf -y autoremove
dnf -y clean all --enablerepo=\*

# Avoid 150 meg firmware package we don't need
echo "Removing extra packages"
dnf -y remove linux-firmware

rm -f /tmp/chef*rpm

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;
