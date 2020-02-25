#!/bin/sh -eux

zypper removerepo `zypper repos | grep 'SLES' | awk '{ print $3 }' | grep "^SLES"`;
exit 0
