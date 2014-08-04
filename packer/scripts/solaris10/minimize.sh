#!/bin/sh -ux

dd if=/dev/zero of=/EMPTY bs=344064
rm -f /EMPTY
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync
