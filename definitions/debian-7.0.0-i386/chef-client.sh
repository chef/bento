#!/bin/bash -eux

wget -O /tmp/chef.deb 'http://www.opscode.com/chef/download?v=&prerelease=false&p=debian&pv=6&m=i686'
dpkg -i /tmp/chef.deb
