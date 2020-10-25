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
        dnf install -y --skip-broken perl cpp gcc make bzip2 tar kernel-headers kernel-devel kernel-uek-devel || true # not all these packages are on every system
    elif [ -f "/bin/yum" ] || [ -f "/usr/bin/yum" ]; then
        yum install -y --skip-broken perl cpp gcc make bzip2 tar kernel-headers kernel-devel kernel-uek-devel || true # not all these packages are on every system
    elif [ -f "/usr/bin/apt-get" ]; then
        apt-get install -y build-essential dkms bzip2 tar linux-headers-`uname -r`
    elif [ -f "/usr/bin/zypper" ]; then
        zypper install -y perl cpp gcc make bzip2 tar kernel-default-devel
    fi

    echo "installing the vbox additions"
    # this install script fails with non-zero exit codes for no apparent reason so we need better ways to know if it worked
    /tmp/vbox/VBoxLinuxAdditions.run --nox11 || true

    if ! modinfo vboxsf >/dev/null 2>&1; then
         echo "Cannot find vbox kernel module. Installation of guest additions unsuccessful!"
         exit 1
    fi

    echo "unmounting and removing the vbox ISO"
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;

    echo "removing kernel dev packages and compilers we no longer need"
    if [ -f "/bin/dnf" ]; then
        dnf remove -y gcc cpp kernel-headers kernel-devel kernel-uek-devel
    elif [ -f "/bin/yum" ] || [ -f "/usr/bin/yum" ]; then
        yum remove -y gcc cpp kernel-headers kernel-devel kernel-uek-devel
    elif [ -f "/usr/bin/apt-get" ]; then
        apt-get remove -y build-essential gcc g++ make libc6-dev dkms linux-headers-`uname -r`
    elif [ -f "/usr/bin/zypper" ]; then
        zypper -n rm -u kernel-default-devel gcc make
    fi

    echo "removing leftover logs"
    rm -rf /var/log/vboxadd*
    ;;
esac
