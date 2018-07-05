#!/bin/sh
# These were only needed for building VMware/Virtualbox extensions:
zypper --non-interactive rm --clean-deps gcc kernel-default-devel
zypper clean

rm -f /tmp/chef*rpm

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules;
touch /etc/udev/rules.d/75-persistent-net-generator.rules;

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;
