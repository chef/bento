#!/bin/sh -eux

# Disable Predictable Network Interface names and use eth0
sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces;
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub;
update-grub;

# Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" >> /etc/network/interfaces
