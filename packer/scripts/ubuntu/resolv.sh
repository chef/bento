#!/bin/bash -eux

echo $dnsserver1  >> /etc/resolvconf/resolv.conf.d/base
echo $dnsserver2 >> /etc/resolvconf/resolv.conf.d/base
resolvconf -u
