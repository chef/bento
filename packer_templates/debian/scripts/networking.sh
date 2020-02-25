#!/bin/sh -eux

debian_version="`lsb_release -r | awk '{print $2}'`";
major_version="`echo $debian_version | awk -F. '{print $1}'`";


if [ "$major_version" -le "8" ]; then
  echo "Disabling automatic udev rules for network interfaces in Debian"
  # Disable automatic udev rules for network interfaces in Ubuntu,
  # source: http://6.ptmc.org/164/
  rm -f /etc/udev/rules.d/70-persistent-net.rules;
  mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
  rm -f /lib/udev/rules.d/75-persistent-net-generator.rules;
  rm -rf /dev/.udev/ /var/lib/dhcp/*;
fi

if [ "$major_version" -ge "9" ]; then
  # Disable Predictable Network Interface names and use eth0
  sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces;
  sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub;
  update-grub;
fi

# Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" >> /etc/network/interfaces
