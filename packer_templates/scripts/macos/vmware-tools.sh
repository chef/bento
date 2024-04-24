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

echo 'VMware Fusion specific items'
if [ -e .vmfusion_version ] || echo "$PACKER_BUILDER_TYPE" | grep -q '^vmware'; then
  # Globbing here: VMware Fusion >= 8.5.4 includes a second
  # 'darwinPre15.iso' for any OS X guests pre-10.11
  TOOLS_PATH=$(find "/Users/vagrant/" -name '*darwin*.iso' -print)
    if [ ! -e "$TOOLS_PATH" ]; then
        echo "Couldn't locate uploaded tools iso at $TOOLS_PATH!"
        exit 1
    fi

    TMPMOUNT=$(/usr/bin/mktemp -d /tmp/vmware-tools.XXXX)
    hdiutil attach "$TOOLS_PATH" -mountpoint "$TMPMOUNT"

    INSTALLER_PKG="$TMPMOUNT/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg"
    if [ ! -e "$INSTALLER_PKG" ]; then
        echo "Couldn't locate VMware installer pkg at $INSTALLER_PKG!"
        exit 1
    fi

    echo "Installing VMware tools.."
    installer -pkg "$TMPMOUNT/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target /

    # This usually fails
    hdiutil detach "$TMPMOUNT" || echo "exit code $? is suppressed";
    rm -rf "$TMPMOUNT"
    rm -f "$TOOLS_PATH"

    # Point Linux shared folder root to that used by OS X guests,
    # useful for the Hashicorp vmware_fusion Vagrant provider plugin
    mkdir /mnt
    ln -sf /Volumes/VMware\ Shared\ Folders /mnt/hgfs
fi
