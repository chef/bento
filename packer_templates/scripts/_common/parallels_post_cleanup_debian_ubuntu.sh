#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
parallels-iso|parallels-pvm)
    # This runs in a special script after cleanup_{ubuntu|debian}.sh, which cleans up the kernel headers
    # in general (we want to keep them for Parallels Desktop only).

    echo "Installing linux-kernel-headers for the current kernel version, to allow re-compilation of Parallels Tools upon boot"

    if [ -f "/usr/bin/apt-get" ]; then
        apt-get install -y linux-headers-"$(uname -r)"
    fi
    ;;
esac
