#!/bin/sh -eux

yum -y update;

# make sure we update the repo structure on Oracle Linux and then update again
if [ -f "/usr/bin/ol_yum_configure.sh" ]; then
  /usr/bin/ol_yum_configure.sh
  yum -y update
fi

reboot;
sleep 60;
