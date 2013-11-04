#!/bin/sh -eux

# Purge files we don't need any longer
rm -rf /tmp/chef*
rm -rf /home/vagrant/VBox*.iso
find /usr/ports -not -path '/usr/ports/packages*' -and -not -path '/usr/ports/distfiles*' -depth -exec rm -rf '{}' \;
rm -rf /usr/ports/distfiles/*
rm -rf /var/db/freebsd-update/files
mkdir /var/db/freebsd-update/files
rm -rf /var/db/freebsd-update/*-rollback
rm -rf /var/db/freebsd-update/install.*
rm -rf /boot/kernel.old
rm -rf /usr/src/*
rm -rf /*.core

exit
