#!/bin/sh -eux

major_version="`uname -r | awk -F. '{print $1}'`";

# Allow freebsd-update to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update >/tmp/freebsd-update;
chmod +x /tmp/freebsd-update;

# Update FreeBSD
env PAGER=/bin/cat /tmp/freebsd-update fetch;
env PAGER=/bin/cat /tmp/freebsd-update install;

# Always use pkgng - pkg_add is EOL as of 1 September 2014
env ASSUME_ALWAYS_YES=true pkg bootstrap;
if [ "$major_version" -lt 10 ]; then
    echo "WITH_PKGNG=yes" >>/etc/make.conf;
fi

pkg update;
