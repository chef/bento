#!/bin/sh -eux

version=`grep VERSION= /etc/os-release | cut -f2 -d\" | cut -f1 -d\ `

zypper removerepo "openSUSE-${version}-0"

if [[ $version =~ "13" ]]; then
  zypper ar http://download.opensuse.org/distribution/${version}/repo/oss/ openSUSE-${version}-Oss
  zypper ar http://download.opensuse.org/distribution/${version}/repo/non-oss/ openSUSE-${version}-Non-Oss
  zypper ar http://download.opensuse.org/update/${version}/ openSUSE-${version}-Update
  zypper ar http://download.opensuse.org/update/${version}-non-oss/ openSUSE-${version}-Update-Non-Oss
fi

if [[ $version =~ "4" ]]; then
  if [ "$(uname -m)" == "ppc64le" ] ; then
    zypper ar http://download.opensuse.org/ports/ppc/distribution/leap/${version}/repo/oss/ openSUSE-Leap-${version}-Oss
    zypper ar http://download.opensuse.org/ports/update/leap/${version}/oss/ openSUSE-Leap-${version}-Update
  else
    zypper ar http://download.opensuse.org/distribution/leap/${version}/repo/oss/ openSUSE-Leap-${version}-Oss
    zypper ar http://download.opensuse.org/distribution/leap/${version}/repo/non-oss/ openSUSE-Leap-${version}-Non-Oss
    zypper ar http://download.opensuse.org/update/leap/${version}/oss/ openSUSE-Leap-${version}-Update
    zypper ar http://download.opensuse.org/update/leap/${version}/non-oss/ openSUSE-Leap-${version}-Update-Non-Oss
  fi
fi

zypper refresh
