#!/bin/sh

set -eux

#echo "Don't use the tmpfs based /tmp dir that is limited to 50% of RAM"
#systemctl mask tmp.mount


# One can modify their /etc/fstab with, e.g.:
# /tmp /tmp tmpfs defaults,size=8G 0 0
