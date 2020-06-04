#!/bin/sh -eux

# Install missing packages
zypper install -y kernel-default-devel gcc

# make sure we have tools we need for the vm extensions
case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|virtualbox-ovf)
  zypper install -y bzip2;
  ;;
vmware-iso)
  zypper install -y insserv-compat;
  ;;
esac