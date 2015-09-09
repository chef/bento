#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    echo "VirtualBox not currently supported, sadface";
    ;;

vmware-iso|vmware-vmx)
    iso_name="/tmp/vmtools.iso";
    mount_point="`mktemp -d /tmp/vmware-tools.XXXX`";
    #Run install, unmount ISO and remove it
    hdiutil attach "$iso_name" -mountpoint "$mount_point";
    installer -pkg "$mount_point/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target /;
    # This usually fails
    hdiutil detach "$mount_point" || true;
    rm -f "$iso_name";
    rmdir "$mount_point";

    # Point Linux shared folder root to that used by OS X guests,
    # useful for the Hashicorp vmware_fusion Vagrant provider plugin
    mkdir /mnt;
    ln -sf /Volumes/VMware\ Shared\ Folders /mnt/hgfs;
    ;;

parallels-iso|parallels-pvm)
    TOOLS_PATH="$HOME_DIR/prl-tools-mac.iso";
    TMPMOUNT="`/usr/bin/mktemp -d /tmp/parallels-tools.XXXX`";

    #Run install, unmount ISO and remove it
    hdiutil attach "$TOOLS_PATH" -mountpoint "$TMPMOUNT";
    echo "Installing Parallels Tools..."
    installer -pkg "$TMPMOUNT/Install.app/Contents/Resources/Install.mpkg" -target /;

    # This usually fails
    hdiutil detach "$TMPMOUNT" || true;
    rmdir "$TMPMOUNT";
    rm -f "$TOOLS_PATH";
    ;;
*)
    echo "Unknown Packer Builder Type >>${PACKER_BUILDER_TYPE}<< selected.";
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm.";
    ;;

esac
