#!/bin/sh -eux

echo "reduce the grub menu time to 1 second"
sed -i -e 's/^GRUB_TIMEOUT=[0-9]\+$/GRUB_TIMEOUT=1/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Remove development and kernel source packages"
dnf -y remove gcc cpp gc kernel-devel kernel-headers glibc-devel elfutils-libelf-devel glibc-headers kernel-devel kernel-headers

echo "remove orphaned packages"
dnf -y autoremove

echo "Remove previous kernels that preserved for rollbacks"
dnf -y remove "$(dnf repoquery --installonly --latest-limit=-1 -q)"

# Avoid ~200 meg firmware package we don't need
# this cannot be done in the KS file so we do it here
# Skip Oracle linux because it causes errors by removing kernel-uek-core
distro="$(rpm -qf --queryformat '%{NAME}' /etc/redhat-release | cut -f 1 -d '-')"
if [ "$distro" != 'oraclelinux' ]; then
  echo "Removing extra firmware packages"
  dnf -y remove linux-firmware
fi

echo "clean all package cache information"
dnf -y clean all --enablerepo=\*

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules;
mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules;
rm -rf /dev/.udev/;

for ndev in /etc/sysconfig/network-scripts/ifcfg-*; do
    if [ "$(basename "$ndev")" != "ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev";
        sed -i '/^UUID/d' "$ndev";
    fi
done

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "remove the install log"
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "Force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "Wipe netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id
if test -f /var/lib/dbus/machine-id
then
  truncate -s 0 /var/lib/dbus/machine-id  # if not symlinked to "/etc/machine-id"
fi

echo "Clear the history so our install commands aren't there"
rm -f /root/.wget-hsts
export HISTSIZE=0
