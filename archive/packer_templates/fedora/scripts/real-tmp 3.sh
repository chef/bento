#!/bin/bash -eux
echo "Don't use the tmpfs based /tmp dir that is limited to 50% of RAM"
systemctl mask tmp.mount
umount /tmp | true