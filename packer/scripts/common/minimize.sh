#!/bin/bash -eux

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# /EMPTY file. Wait up to 20 seconds before returning so later scripts don't
# fail with "write error: No space left on device".
for i in `seq 20` ; do
  DevicePercent=$(df / | tail -n 1 | awk 'BEGIN { FS="[ \t]+" } {print $5}')
  if [ "$DevicePercent" != '100%' ]; then
    break
  fi
  sleep 1
done