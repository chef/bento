#!/bin/bash -eux

wget -O /tmp/chef.deb 'http://www.opscode.com/chef/download?v=&prerelease=false&p=debian&pv=6&m=x86_64'
dpkg -i /tmp/chef.deb
