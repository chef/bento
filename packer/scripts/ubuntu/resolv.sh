#!/bin/bash -eux

echo $IP1  >> /etc/resolvconf/resolv.conf.d/base
echo $IP2 >> /etc/resolvconf/resolv.conf.d/base
resolvconf -u
