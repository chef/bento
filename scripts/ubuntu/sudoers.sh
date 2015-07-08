#!/bin/sh -eux

major_version="`lsb_release -r | awk '{print $2}' | awk -F. '{print $1}'`";

if [ ! -z "$major_version" -a "$major_version" -lt 12 ]; then
    sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers;
    sed -i -e 's/%admin\s*ALL=(ALL) ALL/%admin\tALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers;
else
    sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers;
    sed -i -e 's/%sudo\s*ALL=(ALL:ALL) ALL/%sudo\tALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers;
fi
