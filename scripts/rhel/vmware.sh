#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
    yum install -y open-vm-tools;
    mkdir /mnt/hgfs;
    echo "platform specific vmware.sh executed";
esac
