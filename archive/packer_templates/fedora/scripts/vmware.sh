#!/bin/bash -eux

# the proprietary vm tools don't work on Fedora 30 so we'll install the open-vm-tools
case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
  dnf install -y open-vm-tools
  mkdir /mnt/hgfs;
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
esac