#MIT License
#
#Copyright (c) 2017 Rui Lopes
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

if ('VirtualBox' -ne (Get-CimInstance -ClassName WIN32_BIOS -Property SMBIOSBIOSVersion).SMBIOSBIOSVersion) {
    Exit 0
}

# to prevent long delays while resolving the vboxsrv (used by c:\vagrant)
# NetBIOS name, hard-code its address in the lmhosts file.
# see 12.3.9. Long delays when accessing shared folders
#     at https://www.virtualbox.org/manual/ch12.html#idm10219
Write-Output @'
255.255.255.255 VBOXSVR #PRE
255.255.255.255 VBOXSRV #PRE
'@ | Out-File -Encoding ASCII -Append 'c:\windows\system32\drivers\etc\lmhosts'
