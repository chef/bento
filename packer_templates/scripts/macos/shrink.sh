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

echo 'Remove Screensaver video files'
rm -rf /Library/Application Support/com.apple.idleassetsd/Customer/* || echo "rm screensaver videos exit code $? is suppressed"

echo 'Remove user files'
rm -rf /Users/vagrant/* || echo "rm vagrant user files exit code $? is suppressed"
rm -rf /var/root/* || echo "rm root user files exit code $? is suppressed"

echo 'Remove system caches'
rm -rf /Library/Caches/* || echo "rm library caches exit code $? is suppressed"
rm -rf /System/Library/Caches/* || echo "rm system library caches exit code $? is suppressed"

echo 'Remove logs'
rm -rf /Library/Logs/* || echo "rm library logs exit code $? is suppressed"

echo 'Remove swap file'
rm -rf /System/Volumes/VM/swapfile* || echo "rm swapfile exit code $? is suppressed"

#echo 'Whiteout root'
#dd if=/dev/zero of=/tmp/whitespace bs=1M || echo "dd root exit code $? is suppressed"
#sync
#rm /tmp/whitespace || echo "rm tmp/whitespace exit code $? is suppressed"

echo 'VMware Fusion specific items'
if [ -e .vmfusion_version ] || [[ "$PACKER_BUILDER_TYPE" == vmware* ]]; then
  echo 'Shrink the disk'
  /Library/Application\ Support/VMware\ Tools/vmware-tools-cli disk shrink /
fi
