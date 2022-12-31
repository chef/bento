#!/bin/bash -eux

# Add pkgadd auto-answer file
sudo mkdir -p /tmp
sudo chmod 777 /tmp
{
  echo "mail="
  echo "instance=overwrite"
  echo "partial=nocheck"
  echo "runlevel=nocheck"
  echo "idepend=nocheck"
  echo "rdepend=nocheck"
  echo "space=nocheck"
  echo "setuid=nocheck"
  echo "conflict=nocheck"
  echo "action=nocheck"
  echo "basedir=default"
} > /tmp/nocheck

if [ -f /home/vagrant/.vbox_version ]; then
    mkdir /tmp/vbox
    ls
    echo "all" | sudo -i pkgadd -a /tmp/nocheck -d /media/VBOXADDITIONS_*/VBoxSolarisAdditions.pkg
fi
