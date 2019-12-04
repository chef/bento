#!/bin/sh -eux

# determine the major EL version we're runninng
major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

# make sure we use dnf on EL 8+
if [ "$major_version" -ge 8 ]; then
  dnf -y update
else
  yum -y update
fi

# Updating the oracle release on at least OL 6 updates the repos and unlocks a whole
# new set of updates that need to be applied. If this script is there it should be run
if [ -f "/usr/bin/ol_yum_configure.sh" ]; then
  /usr/bin/ol_yum_configure.sh
  yum -y update
fi

reboot;
sleep 60;
