#!/bin/sh -eux

if [ 'x86_64' == `uname -m` ]; then
  arch_suffix=x64
else
  arch_suffix=x86
fi

patchlevel=`grep PATCHLEVEL /etc/SuSE-release | awk '{ print $3 }'`
if [ $patchlevel == '2' ]; then
  repo_ver="11.2.2-1.234"
elif [ $patchlevel == '3' ]; then
  repo_ver="11.3.3-1.138"
else
  echo "Failed to remove DVD source; don't know how to deal with patchlevel $patchlevel"
  exit 1
fi

zypper removerepo "SUSE-Linux-Enterprise-Server-11-SP$patchlevel $repo_ver"
zypper addrepo "http://demeter.uni-regensburg.de/SLES11SP$patchlevel-$arch_suffix/DVD1/" "SLES11SP$patchlevel-$arch_suffix DVD1 Online"
zypper refresh
