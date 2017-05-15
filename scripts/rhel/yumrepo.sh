#!/bin/sh -eux

# Configure local repository
cat >> /etc/yum.repos.d/local.repo << EOF
[mylocalrepo]
name="Local RHEL6 Repo"
baseurl=http://172.31.3.48
gpgcheck=0
EOF

