#!/bin/bash

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    mkdir /tmp/vbox
    VER=$(cat /home/vagrant/.vbox_version)
    mount -o loop /home/vagrant/VBoxGuestAdditions_$VER.iso /tmp/vbox
    sh /tmp/vbox/VBoxLinuxAdditions.run
    umount /tmp/vbox
    rmdir /tmp/vbox
    rm /home/vagrant/*.iso
    ;;

vmware-iso|vmware-vmx)
    PLATFORM=$(grep -e "^ID=" /etc/os-release 2> /dev/null | cut -d= -f2)
    VERSION=$(grep -e "^VERSION_ID=" /etc/os-release 2> /dev/null | cut -d= -f2)
    if [[ "$PLATFORM" != "" ]]; then
        if [[ "$PLATFORM" == "ubuntu" ]] && [[ "$VERSION" == "14.04" ]]; then
            apt-get install -y open-vm-tools-lts-trusty
        else
            apt-get install -y open-vm-tools
        fi
    else
        mkdir /tmp/vmfusion
        mkdir /tmp/vmfusion-archive
        mount -o loop /home/vagrant/linux.iso /tmp/vmfusion
        tar xzf /tmp/vmfusion/VMwareTools-*.tar.gz -C /tmp/vmfusion-archive
        /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default
        umount /tmp/vmfusion
        rm -rf  /tmp/vmfusion
        rm -rf  /tmp/vmfusion-archive
        rm /home/vagrant/*.iso
    fi
    ;;

parallels-iso|parallels-pvm)
    mkdir /tmp/parallels
    mount -o loop /home/vagrant/prl-tools-lin.iso /tmp/parallels
    /tmp/parallels/install --install-unattended-with-deps
    umount /tmp/parallels
    rmdir /tmp/parallels
    rm /home/vagrant/*.iso
    ;;

*)
    echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm."
    ;;

esac
