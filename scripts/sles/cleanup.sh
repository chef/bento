#!/bin/sh
# These were only needed for building VMware/Virtualbox extensions:
zypper --non-interactive rm --clean-deps kernel-default-devel
zypper clean
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
rm -f /tmp/chef*rpm
