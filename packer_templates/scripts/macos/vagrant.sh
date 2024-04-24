#!/bin/sh
# The MIT License (MIT)
# Copyright (c) 2013-2017 Timothy Sutton
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

date > /etc/box_build_time
OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $1}')

# Set computer/hostname
COMPNAME=macos-${OSX_VERS}
scutil --set ComputerName "${COMPNAME}"
scutil --set HostName "${COMPNAME}".vagrantup.com

echo "Installing vagrant keys for vagrant user"
mkdir "/Users/vagrant/.ssh"
chmod 700 "/Users/vagrant/.ssh"
curl -L 'https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub' > "/Users/vagrant/.ssh/authorized_keys"
chmod 600 "/Users/vagrant/.ssh/authorized_keys"
chown -R "vagrant" "/Users/vagrant/.ssh"
