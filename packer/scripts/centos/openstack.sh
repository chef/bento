#!/bin/bash -eux

yum -y install cloud-init cloud-utils dracut-modules-growroot
dracut -f

if [ -e /boot/grub/grub.conf ] ; then
  sed -i -e 's/rhgb.*/console=ttyS0,115200n8 console=tty0 quiet/' /boot/grub/grub.conf
  sed -i -e 's/^timeout=.*/timeout=0/' /boot/grub/grub.conf
  cd /boot
  ln -s boot .
elif [ -e /etc/default/grub ] ; then
  sed -i -e \
    's/GRUB_CMDLINE_LINUX=\"\(.*\)/GRUB_CMDLINE_LINUX=\"console=ttyS0,115200n8 console=tty0 quiet \1/g' \
    /etc/default/grub
  sed -i -e 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/' /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
fi
