#!/bin/bash -eux
yum -y erase gtk2 libX11 hicolor-icon-theme freetype
yum -y clean all
rm -f /tmp/chef*rpm
