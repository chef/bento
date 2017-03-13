#!/bin/bash -eux
# These were only needed for building VMware/Virtualbox extensions:

zypper -n rm -u gcc make kernel-default-devel kernel-devel
