#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
  qemu) exit 0 ;;
esac

OS_NAME=$(uname -s)

if [ "$OS_NAME" = "FreeBSD" ]; then
  ZROOT="zroot/ROOT/default"

  zfs set compression=off $ZROOT;
  dd if=/dev/zero of=/EMPTY bs=1m || echo "dd(1) exits after taking over all the space"
  sync
  rm -f /EMPTY;
  # Block until the empty file has been removed, otherwise, Packer
  # will try to kill the box while the disk is still full and that's bad
  sync;
  zfs set compression=lz4 $ZROOT;
elif [ "$OS_NAME" = "Darwin" ]; then
  echo 'Disable spotlight...'
  mdutil -a -i off

  echo 'Turn off hibernation and get rid of the sleepimage'
  pmset hibernatemode 0
  rm -f /var/vm/sleepimage

  echo 'Remove Screensaver video files'
  rm -rf /Library/Application Support/com.apple.idleassetsd/Customer/* || echo "rm screensaver videos exit code $? is suppressed"

  echo 'Remove logs'
  rm -rf /Library/Logs/* || echo "rm library logs exit code $? is suppressed"

  echo 'Remove swap file'
  rm -rf /System/Volumes/VM/swapfile* || echo "rm swapfile exit code $? is suppressed"

  if [ -e .vmfusion_version ] || [[ "$PACKER_BUILDER_TYPE" == vmware* ]]; then
    echo 'VMware Fusion specific items'
    echo 'Shrink the disk'
    /Library/Application\ Support/VMware\ Tools/vmware-tools-cli disk shrink /
  fi
else
  # Whiteout root
  count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
  count=$((count - 1))
  dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
  rm /tmp/whitespace

  # Whiteout /boot
  count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
  count=$((count - 1))
  dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
  rm /boot/whitespace

  set +e
  swapuuid="$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)";
  case "$?" in
      2|0) ;;
      *) exit 1 ;;
  esac
  set -e

  if [ "x${swapuuid}" != "x" ]; then
      # Whiteout the swap partition to reduce box size
      # Swap is disabled till reboot
      swappart="$(readlink -f /dev/disk/by-uuid/"$swapuuid")";
      /sbin/swapoff "$swappart" || true;
      dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
      /sbin/mkswap -U "$swapuuid" "$swappart";
  fi

  sync;
fi
