#!/bin/bash -eux

# https://help.ubuntu.com/community/CheckingYourUbuntuVersion
if [ lsb_release > /dev/null 2>&1 ]
then
  # Get the major version (like "12" from the version string (like "12.04")
  major_version=$(lsb_release -r | cut -f 2 | cut -d . -f 1)
fi

if [ ! -z "$major_version" -a "$major_version" -lt 12 ]
then
  sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
  sed -i -e 's/%admin\s*ALL=(ALL) ALL/%admin\tALL=NOPASSWD:ALL/g' /etc/sudoers
else
  sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
  sed -i -e 's/%sudo\s*ALL=(ALL:ALL) ALL/%sudo\tALL=NOPASSWD:ALL/g' /etc/sudoers
fi
