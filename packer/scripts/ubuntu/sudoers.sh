#!/bin/bash -eux

# https://help.ubuntu.com/community/CheckingYourUbuntuVersion
if [ lsb_release > /dev/null 2>&1 ]
then
  # Get the major version (like "12" from the version string (like "12.04")
  major_version=$(lsb_release -r | cut -f 2 | cut -d . -f 1)
fi

if [ ! -z "$major_version" -a "$major_version" -lt 12 ]
then
  exempt_group="admin"
else
  exempt_group="sudo"
fi

sed -i -e "/Defaults\s\+env_reset/a Defaults\texempt_group=${exempt_group}" /etc/sudoers
sed -i -e "s/%${exempt_group}  ALL=(ALL:ALL) ALL/%${exempt_group}  ALL=NOPASSWD:ALL/g" /etc/sudoers
