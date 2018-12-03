#!/bin/sh -eux

# should output one of 'redhat' 'centos' 'oraclelinux'
distro="`rpm -qf --queryformat '%{NAME}' /etc/redhat-release | cut -f 1 -d '-'`"

# Remove development and kernel source packages
yum -y remove gcc cpp kernel-devel kernel-headers;

if [ "$distro" != 'redhat' ]; then
  yum -y clean all;
fi

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules;
mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules;
rm -rf /dev/.udev/;

for ndev in `ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "`basename $ndev`" != "ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev";
        sed -i '/^UUID/d' "$ndev";
    fi
done

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

# remove previous kernels that yum preserved for rollback
yum install -y yum-utils
package-cleanup --oldkernels --count=1 -y
