#!/bin/sh -eux
ubuntu_version="`lsb_release -r | awk '{print $2}'`";

if [ "$ubuntu_version" = '17.10' ]; then
echo "Create netplan config for eth0"
cat <<EOF >/etc/netplan/01-netcfg.yaml;
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
EOF
else
  # Set up eth0 for pre-17.10
  echo "auto eth0\niface eth0 inet dhcp" >> /etc/network/interfaces.d/eth0.cfg
  # Adding a 2 sec delay to the interface up, to make the dhclient happy
  echo "pre-up sleep 2" >>/etc/network/interfaces;
fi

# Seriously though eth0
sed -ie 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub
update-grub
