#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
  qemu) exit 0 ;;
esac

COMPRESSION=$(zfs get -H compression zroot/ROOT/default | cut -f3);

zfs set compression=off zroot/ROOT/default;
dd if=/dev/zero of=/EMPTY bs=1M || echo "dd exit code $? is suppressed";
rm -f /EMPTY;
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync;
zfs set compression=$COMPRESSION zroot/ROOT/default;
