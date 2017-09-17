#!/bin/sh -eux

# Set up eth0
echo "auto eth0\niface eth0 inet dhcp" >> /etc/network/interfaces.d/eth0.cfg

# Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" >>/etc/network/interfaces;

sed -ie 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub
update-grub
