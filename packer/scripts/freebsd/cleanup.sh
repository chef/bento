#!/bin/sh -x

# Purge files we don't need any longer
rm -rf /var/db/freebsd-update/files
mkdir /var/db/freebsd-update/files
rm -f /var/db/freebsd-update/*-rollback
rm -rf /var/db/freebsd-update/install.*
rm -rf /boot/kernel.old
rm -rf /usr/src/*
rm -f /*.core

# Temporary files
# ------------------------------
rm -rf /tmp/*

# Man pages
rm -rf /usr/share/man/*

# Remove anything in /usr/src
rm -rf /usr/src/*

# Remove any docs
rm -rf /usr/share/doc/*

# Remove caches
find /var/cache -type f -exec rm -rf {} \;

# Log files
# ------------------------------
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# Erase free space
# ------------------------------
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Wait (othwerise Packer will cry)
# ------------------------------
sync
