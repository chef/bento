#!/bin/bash -eux

rpm -Uvh http://epel.osuosl.org/6/x86_64/epel-release-6-8.noarch.rpm

# use our mirror
sed -i -e 's/^\(mirrorlist.*\)/#\1/g' /etc/yum.repos.d/epel.repo
sed -i -e 's/^#baseurl=.*pub\/epel\/6\/$basearch$/baseurl=http:\/\/epel.osuosl.org\/6\/$basearch\//' /etc/yum.repos.d/epel.repo
