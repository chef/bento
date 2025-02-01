#!/bin/bash -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}"

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
  dnf install -y open-vm-tools

  systemctl enable vmtoolsd
  systemctl start vmtoolsd
esac
