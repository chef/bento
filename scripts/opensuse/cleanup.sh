#!/bin/bash -eux
# These were only needed for building VMware/Virtualbox extensions:

version=`grep VERSION= /etc/os-release | cut -f2 -d\" | cut -f1 -d\ `

if [[ $version =~ "13" ]]; then
  zypper -n rm -u binutils gcc make ruby kernel-default-devel kernel-devel
fi

if [[ $version =~ "4" ]]; then
  zypper -n rm -u gcc make kernel-default-devel kernel-devel
fi
