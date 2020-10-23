#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|virtualbox-ovf)
    VER="`cat $HOME_DIR/.vbox_version`";
    ISO="VBoxGuestAdditions_$VER.iso";

    # mount the ISO to /tmp/vbox
    mkdir -p /tmp/vbox;
    mount -o loop $HOME_DIR/$ISO /tmp/vbox;

    echo "installing deps necessary to compile kernel modules"
    # We install things like kernel-headers here vs. kickstart files so we make sure we install them for the updated kernel not the stock kernel
    if [ -f "/bin/dnf" ]; then
        dnf install cpp gcc make bzip2 tar kernel-headers kernel-devel kernel-uek-devel -y || true # not all these packages are on every system
    elif [ -f "/bin/yum" ] || [ -f "/usr/bin/yum" ]; then
        yum install cpp gcc make bzip2 tar kernel-headers kernel-devel kernel-uek-devel -y || true # not all these packages are on every system
    elif [ -f "/usr/bin/apt-get" ]; then
        apt-get install build-essential bzip2 tar -y
        # avoid warnings and failures
        apt-get remove cryptsetup-initramfs -y
    fi

    echo "installing the vbox additions"
    sh /tmp/vbox/VBoxLinuxAdditions.run --nox11

    echo "unmounting and removing the vbox ISO"
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;

    echo "removing kernel dev packages and compilers we no longer need"
    if [ -f "/bin/dnf" ]; then
        dnf remove gcc cpp kernel-headers kernel-devel kernel-uek-devel -y
    elif [ -f "/bin/yum" ] || [ -f "/usr/bin/yum" ]; then
        yum remove gcc cpp kernel-headers kernel-devel kernel-uek-devel -y
    elif [ -f "/usr/bin/apt-get" ]; then
        apt-get remove gcc g++ make libc6-dev -y
    fi

    echo "removing leftover logs"
    rm -rf /var/log/vboxadd*
    ;;
esac
