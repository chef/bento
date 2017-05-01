#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|virtualbox-ovf)
    VER="`cat /home/vagrant/.vbox_version`";
    ISO="VBoxGuestAdditions.iso";

    echo "Working around regression in 5.1.20 guest additions";
    echo "So we're using an updated test build";
    echo "It's probably fine";
    echo "Virtualbox Tools Version: 5.1.21";

    mkdir -p /tmp/vbox;
    mount -o loop $HOME_DIR/$ISO /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;
    ;;
esac
