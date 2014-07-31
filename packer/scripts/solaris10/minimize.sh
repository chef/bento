#!/bin/sh -ux

/opt/csw/bin/sudo dd if=/dev/zero of=/EMPTY bs=1048576
/opt/csw/bin/sudo rm -f /EMPTY
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
/opt/csw/bin/sudo sync
