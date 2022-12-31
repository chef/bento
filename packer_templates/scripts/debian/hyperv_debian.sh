#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
hyperv-iso)
  echo "installing packaging for hyper-v"
  apt-get -y install linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual;
esac
