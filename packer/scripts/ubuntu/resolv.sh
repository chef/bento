#!/bin/bash -eux

echo $DNS_SERVER_1  >> /etc/resolvconf/resolv.conf.d/base
echo $DNS_SERVER_2 >> /etc/resolvconf/resolv.conf.d/base
resolvconf -u
