#!/bin/bash -eux

echo "nameserver 140.211.166.130" > /etc/resolvconf/resolv.conf.d/base
echo "nameserver 140.211.166.131" > /etc/resolvconf/resolv.conf.d/base
resolvconf -u
