#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
  qemu) exit 0 ;;
esac

ZROOT="zroot/ROOT/default"

zfs set compression=off $ZROOT;
dd if=/dev/zero of=/EMPTY bs=1m || echo "dd(1) exits after taking over all the space"
sync
rm -f /EMPTY;
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync;
zfs set compression=lz4 $ZROOT;
