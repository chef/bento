#!/bin/sh -eux

ubuntu_version="`lsb_release -r | awk '{print $2}'`";
ubuntu_major_version="`echo $ubuntu_version | awk -F. '{print $1}'`";

# Work around bad cached lists on Ubuntu 12.04
if [ "$ubuntu_version" = "12.04" ]; then
    apt-get clean;
    rm -rf /var/lib/apt/lists;
fi

# Update the package list
apt-get update;

# Upgrade all installed packages incl. kernel and kernel headers
if [ "$ubuntu_major_version" -lt 14 ]; then
    apt-get -y upgrade linux-server linux-headers-server;
else
    apt-get -y upgrade linux-generic;
fi

# ensure the correct kernel headers are installed
apt-get -y install linux-headers-`uname -r`;

# update package index on boot
cat <<EOF >/etc/init/refresh-apt.conf;
description "update package index"
start on networking
task
exec /usr/bin/apt-get update
EOF

# Manage broken indexes on distro disc 12.04.5
if [ "$ubuntu_version" = "12.04" ]; then
    apt-get -y install libreadline-dev dpkg;
fi
