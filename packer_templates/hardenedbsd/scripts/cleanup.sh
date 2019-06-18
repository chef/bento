#!/bin/sh -eux

# Purge files we don't need any longer
rm -rf /var/db/hbsd-update/files;
mkdir -p /var/db/hbsd-update/files;
rm -f /var/db/hbsd-update/*-rollback;
rm -rf /var/db/hbsd-update/install.*;
rm -rf /boot/kernel.old;
rm -f /boot/kernel*/*.symbols;
rm -f /*.core;
rm -rf /var/cache/pkg;
