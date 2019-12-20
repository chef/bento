#!/bin/sh -eux

# Install missing packages
zypper install -y kernel-default-devel gcc

# this is needed for the vmware tools install to complete
if [[ "$PACKER_BUILDER_TYPE" == vmware-iso ]]; then
  zypper install -y insserv-compat
fi