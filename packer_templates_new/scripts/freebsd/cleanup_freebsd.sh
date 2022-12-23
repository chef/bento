#!/bin/sh -eux

# cleanup orphaned packages and cache
pkg autoremove --yes
pkg clean --yes --all
rm -f /var/db/pkg/repo-FreeBSD.sqlite

# Purge files we don't need any longer
rm -rf /var/db/freebsd-update/files;
mkdir -p /var/db/freebsd-update/files;
rm -f /var/db/freebsd-update/*-rollback;
rm -rf /var/db/freebsd-update/install.*;
rm -rf /boot/kernel.old;
rm -f /boot/kernel*/*.symbols;
rm -f /*.core;
rm -rf /var/cache/pkg;
rm -f /usr/home/vagrant/*.iso;
