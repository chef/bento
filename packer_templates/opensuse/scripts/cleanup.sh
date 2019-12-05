#!/bin/bash -eux

# These were only needed for building VMware/Virtualbox extensions:
zypper -n rm -u gcc make kernel-default-devel kernel-devel

# cleanup all the downloaded RPMs
zypper clean --all

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules;
touch /etc/udev/rules.d/75-persistent-net-generator.rules;

# truncate any logs that have built up during the install
find /var/log -type f -exec truncate --size=0 {} \;

# remove the contents of /tmp and /var/tmp
rm -rf /tmp/* /var/tmp/*

# Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
truncate -s 0 /etc/machine-id

# clear the history so our install isn't there
export HISTSIZE=0
rm -f /root/.wget-hsts