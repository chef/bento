#!/bin/bash -eux
# These were only needed for building VMware/Virtualbox extensions:

zypper -n rm -u gcc make kernel-default-devel kernel-devel

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;
