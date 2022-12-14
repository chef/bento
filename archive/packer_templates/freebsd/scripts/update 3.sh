#!/bin/sh -eux

# Unset these as if they're empty it'll break freebsd-update
[ -z "$no_proxy" ] && unset no_proxy
[ -z "$http_proxy" ] && unset http_proxy
[ -z "$https_proxy" ] && unset https_proxy

freebsd_update="/usr/sbin/freebsd-update --not-running-from-cron";

# Update FreeBSD
# NOTE: the install action fails if there are no updates so || true it
env PAGER=/bin/cat $freebsd_update fetch || true;
env PAGER=/bin/cat $freebsd_update install || true;

if [ "$pkg_branch" != "quarterly" ]; then
  sed -i.bak -e "s,pkg+http://pkg.FreeBSD.org/\${ABI}/quarterly,pkg+http://pkg.FreeBSD.org/\${ABI}/${pkg_branch}," /etc/pkg/FreeBSD.conf
  rm -f /etc/pkg/FreeBSD.conf.bak
fi

env ASSUME_ALWAYS_YES=true pkg update;
