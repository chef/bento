#!/bin/bash
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

echo 'Disable spotlight...'
mdutil -a -i off

echo 'Turn off hibernation and get rid of the sleepimage'
pmset hibernatemode 0
rm -f /var/vm/sleepimage

echo 'Stop the pager process and drop swap files. These will be re-created on boot.'
# Starting with El Cap we can only stop the dynamic pager if SIP is disabled.
if csrutil status | grep -q disabled; then
  launchctl unload /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
  sleep 5
fi
rm -rf /private/var/vm/swap*

echo 'VMware Fusion specific items'
if [ -e .vmfusion_version ] || [[ "$PACKER_BUILDER_TYPE" == vmware* ]]; then
  echo 'Shrink the disk'
  /Library/Application\ Support/VMware\ Tools/vmware-tools-cli disk shrink /
fi
