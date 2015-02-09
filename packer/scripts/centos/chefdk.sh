#!/bin/bash -eux

rpm -Uvh https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chefdk-0.4.0-1.x86_64.rpm
yum -y install gcc gcc-c++
su -c "chef gem install kitchen-openstack" - centos
