#!/bin/bash -eux

if [ -x /usr/bin/dnf ] ; then
  dnf -y install cloud-init cloud-utils yum
else
  yum -y install cloud-init cloud-utils dracut-modules-growroot
fi
dracut -f

if [ -e /boot/grub/grub.conf ] ; then
  # No timeout for grub menu
  sed -i -e 's/^timeout=.*/timeout=0/' /boot/grub/grub.conf
  cd /boot
  ln -s boot .
elif [ -e /etc/default/grub ] ; then
  # No timeout for grub menu
  sed -i -e 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/' /etc/default/grub
  # No fancy boot screen
  grep -q rhgb /etc/default/grub && sed -e 's/rhgb //' /etc/default/grub
  # Write out the config
  grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# Ensure that cloud-init starts before sshd
if [ -e /usr/lib/systemd/system/cloud-init.service ] ; then
  FILE=/usr/lib/systemd/system/cloud-init.service
  sed -i '/^Wants/s/$/ sshd.service/' $FILE
  grep -q Before $FILE && sed -i '/Before/s/$/ sshd.service/' $FILE ||  sed -i '/\[Unit\]/aBefore=sshd.service' $FILE
  systemctl enable cloud-init
fi
