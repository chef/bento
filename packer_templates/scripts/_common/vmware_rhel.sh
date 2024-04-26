#!/bin/bash -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}"

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
  # determine the major EL version we're runninng
  major_version="$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')"

  # make sure we use dnf on EL 8+
  if [ "$major_version" -ge 8 ]; then
    dnf install -y open-vm-tools
  else
    yum install -y open-vm-tools
  fi

  systemctl enable vmtoolsd
  systemctl start vmtoolsd
esac
