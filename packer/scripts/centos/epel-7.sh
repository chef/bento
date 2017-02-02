#!/bin/bash -eux

rpm -Uvh http://epel.osuosl.org/epel-release-latest-7.noarch.rpm

# use our mirror
sed -i -e 's/^\(mirrorlist.*\)/#\1/g' /etc/yum.repos.d/epel.repo
sed -i -e 's/^#baseurl=.*pub\/epel\/7\/$basearch$/baseurl=http:\/\/epel.osuosl.org\/7\/$basearch\//' /etc/yum.repos.d/epel.repo
