#!/bin/sh -eux
ubuntu_version="`lsb_release -r | awk '{print $2}'`";
major_version="`echo $ubuntu_version | awk -F. '{print $1}'`";

case "$PACKER_BUILDER_TYPE" in
hyperv-iso)
  echo "installing packaging for hyper-v"
  apt-get -y install linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual;
esac
