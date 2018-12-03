#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
  qemu) exit 0 ;;
esac

# Whiteout all spaces
spaces=(
    '/'
    '/usr/'
    '/tmp/'
    '/var/'
    '/home/'
    '/boot/'
);

for space in "${spaces[@]}"; do
    count=$(df --sync -kP ${space} | tail -n1 | awk -F ' ' '{print $4}')
    count=$(($count-1))
    dd if=/dev/zero of=${space}whitespace bs=1M count=${count} || echo "dd exit code $? is suppressed";
    rm -f ${space}whitespace
done

set +e
swapuuid="`/sbin/blkid -o value -l -s UUID -t TYPE=swap`";
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart="`readlink -f /dev/disk/by-uuid/$swapuuid`";
    /sbin/swapoff "$swappart";
    dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
    /sbin/mkswap -U "$swapuuid" "$swappart";
fi

sync;
