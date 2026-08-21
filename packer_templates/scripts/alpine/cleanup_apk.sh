#!/bin/sh

set -eux

echo "Remove older versions of packages the from cache directory"
apk cache clean || true

echo "clean whole package cache"
rm -rf /var/cache/apk/*

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec sh -c '> "$1"' _ {} \;

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "Force a new random seed to be generated"
# https://wiki.alpinelinux.org/wiki/Entropy_and_randomness
dd if=/dev/zero of=/var/tmp/tempfile bs=1M count=200 || true; find / -size +1k >/dev/null 2>&1 || true; ls -R / >/dev/null 2>&1 || true; rm -f /var/tmp/tempfile; sync

echo "Wipe machine-id so machines get unique ID generated on boot"
> /etc/machine-id || true
if test -f /var/lib/dbus/machine-id
then
  > /var/lib/dbus/machine-id || true # if not symlinked to "/etc/machine-id"
fi

echo "Clear the history so our install commands aren't there"
rm -f /root/.wget-hsts
export HISTSIZE=0
