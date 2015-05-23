#!/bin/bash -eux

UBUNTU_VERSION=`lsb_release -r | awk '{print $2}'`
# on 12.04 work around bad cached lists
if [[ "$UBUNTU_VERSION" == '12.04' ]]; then
  apt-get clean
  rm -rf /var/lib/apt/lists
fi

# Update the package list
apt-get update

# Upgrade all installed packages incl. kernel and kernel headers
apt-get -y upgrade linux-server linux-headers-server

# ensure the correct kernel headers are installed
apt-get -y install linux-headers-$(uname -r)

# update package index on boot
cat <<EOF > /etc/init/refresh-apt.conf
description "update package index"
start on networking
task
exec /usr/bin/apt-get update
EOF

# on 12.04 manage broken indexes on distro disc 12.04.5
if [[ $UBUNTU_VERSION == '12.04' ]]; then
  apt-get -y install libreadline-dev dpkg
fi
