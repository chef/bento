#!/bin/bash -eux

yum -y install cloud-init cloud-utils dracut-modules-growroot
dracut -f

sed -i -e \
  's/GRUB_CMDLINE_LINUX=\"\(.*\)/GRUB_CMDLINE_LINUX=\"console=ttyS0,115200n8 console=tty0 quiet \1/g' \
  /etc/default/grub

grub2-mkconfig -o /boot/grub2/grub.cfg
