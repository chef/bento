#!/bin/sh -eux

if [ 'x86_64' == `uname -m` ]; then
  arch_suffix=x64
else
  arch_suffix=x86
fi

oslevel=`grep VERSION /etc/SuSE-release | awk '{ print $3 }'`
patchlevel=`grep PATCHLEVEL /etc/SuSE-release | awk '{ print $3 }'`

if [ $oslevel == '11' ]; then
  if [ $patchlevel == '2' ]; then
    repo_ver="11.2.2-1.234"
  elif [ $patchlevel == '3' ]; then
    repo_ver="11.3.3-1.138"
  elif [ $patchlevel == '4' ]; then
    repo_ver="11.4.4-1.109"
  else
    echo "Failed to remove DVD source; don't know how to deal with patchlevel $patchlevel"
    exit 1
  fi
  zypper removerepo "SUSE-Linux-Enterprise-Server-11-SP$patchlevel $repo_ver"

elif [ $oslevel == '12' ]; then
  zypper removerepo "SLES12-12-$patchlevel";
fi

zypper refresh
