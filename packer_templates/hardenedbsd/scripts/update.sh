#!/bin/sh -eux

# Unset these as if they're empty
[ -z "$no_proxy" ] && unset no_proxy
[ -z "$http_proxy" ] && unset http_proxy
[ -z "$https_proxy" ] && unset https_proxy

hbsd_update="/usr/sbin/hbsd-update";

# Update HardenedBSD
# NOTE: the install action fails if there are no updates so || true it
env PAGER=/bin/cat $hbsd_update fetch || true;
env PAGER=/bin/cat $hbsd_update install || true;

env ASSUME_ALWAYS_YES=true pkg update;
