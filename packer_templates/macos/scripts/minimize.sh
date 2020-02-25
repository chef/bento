#!/bin/sh -eux

# Remove any sleepimage--a file the same size as the RAM footprint
rm -f /private/var/vm/sleepimage;

# Stop the pager process and drop swap files. These will be re-created on boot
launchctl unload /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist;
sleep 5;
rm -rf /private/var/vm/swap*;

dd if=/dev/zero of=/EMPTY bs=1000000 || echo "dd exit code $? is suppressed";
rm -f /EMPTY;
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync;


case "$PACKER_BUILDER_TYPE" in

vmware-iso|vmware-vmx)
    sudo /Library/Application\ Support/VMware\ Tools/vmware-tools-cli disk shrink /;
    ;;

esac

# re-enable swap
launchctl load -wF /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist;
