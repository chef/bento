#!/bin/sh -eux

# determine the major EL version we're runninng
major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

# update all packages
dnf -y upgrade

reboot;
sleep 60;
