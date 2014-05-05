#!/bin/bash -eux

# Setup networking
echo '==> Setting up sysconfig networking'
sed -i "/^HWADDR/d" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "/^UUID/d" /etc/sysconfig/network-scripts/ifcfg-eth0

# Remove the udev persistent net rules file
echo '==> Removing dumb udev rules'
rm -rf /dev/.udev/
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules

# Speed up lookups
echo '==> Configuring network'
echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
/sbin/service network restart
