#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
    zypper install -y open-vm-tools insserv-compat
    mkdir /mnt/hgfs
    systemctl enable vmtoolsd
    systemctl start vmtoolsd
    echo "platform specific vmware.sh executed"
esac
