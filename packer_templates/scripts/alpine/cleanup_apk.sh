#!/bin/sh

set -eux

echo "reduce the grub menu time to 1 second"
sed -i -e 's/^GRUB_TIMEOUT=[0-9]\+$/GRUB_TIMEOUT=1/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Remove development and kernel source packages"
apk del linux-headers libelf gcc make perl

echo "Remove older versions of packages the from cache directory"
apk cache clean

echo "clean whole package cache"
rm -rf /var/cache/apk/*

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "Remove any non-loopback network configs"
if test -d /etc/sysconfig/network-scripts
then
  find /etc/sysconfig/network-scripts -name "ifcfg-*" -not -name "ifcfg-lo" -exec rm -f {} \;
fi

echo "remove the install log"
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "Force a new random seed to be generated"
# https://wiki.alpinelinux.org/wiki/Entropy_and_randomness
dd if=/dev/zero of=/var/tmp/tempfile bs=1M count=200 && find / -size +1k && ls -R / && rm /var/tmp/tempfile && sync

echo "Wipe netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id
if test -f /var/lib/dbus/machine-id
then
  truncate -s 0 /var/lib/dbus/machine-id  # if not symlinked to "/etc/machine-id"
fi

echo "Clear the history so our install commands aren't there"
rm -f /root/.wget-hsts
export HISTSIZE=0
