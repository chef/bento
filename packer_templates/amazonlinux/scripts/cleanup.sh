#!/bin/sh -eux

# should output one of 'redhat' 'centos' 'oraclelinux'
distro="`rpm -qf --queryformat '%{NAME}' /etc/redhat-release | cut -f 1 -d '-'`"

# Remove development and kernel source packages
yum -y remove gcc cpp kernel-devel kernel-headers;

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


# truncate any logs that have built up during the install
find /var/log -type f -exec truncate --size=0 {} \;

# remove previous kernels that yum preserved for rollback
yum install -y yum-utils
package-cleanup --oldkernels --count=1 -y

# remove the contents of /tmp and /var/tmp
rm -rf /tmp/* /var/tmp/*

# force a new random seed to be generated
rm -f /var/lib/systemd/random-seed

# clear the history so our install isn't there
rm -f /root/.wget-hsts
export HISTSIZE=0