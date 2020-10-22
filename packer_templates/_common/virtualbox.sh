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

    # OS specific packages we need
    if [ -f "/bin/dnf" ]; then
        dnf install gcc make bzip2 tar kernel-headers kernel-devel -y
    elif [ -f "/bin/yum" ]; then
        yum install gcc make bzip2 tar kernel-headers kernel-devel -y
    elif [ -f "/usr/bin/apt-get" ]; then
        apt-get install build-essential bzip2 tar -y
        # avoid warnings and failures
        apt-get remove cryptsetup-initramfs -y
    fi

    # install the vbox additions
    sh /tmp/vbox/VBoxLinuxAdditions.run --nox11

    # unmount and nuke the ISO
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;

    # OS specific packages we don't need
    if [ -f "/bin/dnf" ]; then
        dnf remove gcc cpp kernel-headers kernel-devel -y
    elif [ -f "/bin/yum" ]; then
        yum remove gcc cpp kernel-headers kernel-devel -y
    elif [ -f "/usr/bin/apt-get" ]; then
        apt-get remove gcc g++ make libc6-dev -y
    fi

    # cleanup leftover logs
    rm -rf /var/log/vboxadd*
    ;;
esac
