#!/bin/sh
# These were only needed for building VMware/Virtualbox extensions:
zypper --non-interactive rm --clean-deps gcc kernel-default-devel
zypper clean

rm -f /tmp/chef*rpm

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;
