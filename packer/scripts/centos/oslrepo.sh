#!/bin/bash -eux

cat >> /etc/yum.repos.d/osl.repo << EOF
[osl]
name=OSL Repository \$releasever - \$basearch
failovermethod=priority
baseurl=http://packages.osuosl.org/repositories/centos-\$releasever/osl/\$basearch
enabled=1
gpgcheck=0
priority=10
EOF
