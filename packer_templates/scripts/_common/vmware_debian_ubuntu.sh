#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
    echo "install open-vm-tools"
    apt-get install -y open-vm-tools;
    mkdir /mnt/hgfs;
    systemctl enable open-vm-tools
    systemctl start open-vm-tools
    echo "platform specific vmware.sh executed";
esac
