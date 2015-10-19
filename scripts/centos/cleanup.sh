#!/bin/sh -eux

if [ -s /etc/oracle-release ]; then
  distro = 'oracle'
elif [ -s /etc/enterprise-release ]; then
  distro = 'oracle'
elif [ -s /etc/redhat-release ]; then
  # should ouput 'centos' OR 'red hat'
  distro=`cat /etc/redhat-release | sed 's/^\(CentOS\|Red Hat\).*/\1/i' | tr '[:upper:]' '[:lower:]'`
fi


# Remove development and kernel source packages
yum -y remove gcc cpp kernel-devel kernel-headers perl;

if [ "$distro" != 'red hat' ]; then
  yum -y clean all;
fi

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules;

for ndev in `ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "`basename $ndev`" != "ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev";
        sed -i '/^UUID/d' "$ndev";
    fi
done

rm -f VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?;
