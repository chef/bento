#!/bin/bash -eux
# These were only needed for building VMware/Virtualbox extensions:
zypper -n rm -u binutils gcc make perl ruby kernel-default-devel kernel-devel
