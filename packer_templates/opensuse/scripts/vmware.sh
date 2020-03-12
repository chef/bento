#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
    zypper install -y open-vm-tools
    mkdir /mnt/hgfs
    systemctl enable vmtoolsd
    systemctl start vmtoolsd
    echo "platform specific vmware.sh executed"
esac
