#!/bin/sh -eux

# Purge files we don't need any longer
rm -rf /var/db/freebsd-update/files;
mkdir -p /var/db/freebsd-update/files;
rm -f /var/db/freebsd-update/*-rollback;
rm -rf /var/db/freebsd-update/install.*;
rm -rf /boot/kernel.old;
rm -rf /usr/src/*;
rm -f /*.core;
