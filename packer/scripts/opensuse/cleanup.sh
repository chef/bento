#!/bin/bash -eux
# These were only needed for building VMware/Virtualbox extensions:
zypper -n rm -u binutils gcc make site-config patterns-openSUSE-yast2_install_wf
# backlist i2c_piix4 - VirtualBox has no smbus
echo "blacklist i2c_piix4" > /etc/modprobe.d/100-blacklist-i2c_piix4.conf
# remove all kernels except current running
rpm -qa | grep kernel-default | grep -v `uname -r | awk -F"-" '{print $1"-"$2}'` | xargs rpm -ehv
