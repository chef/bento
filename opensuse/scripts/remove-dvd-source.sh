#!/bin/sh -eux

version=`grep VERSION= /etc/os-release | cut -f2 -d\" | cut -f1 -d\ `

zypper removerepo "openSUSE-${version}-0"

zypper ar http://download.opensuse.org/distribution/leap/${version}/repo/oss/ openSUSE-Leap-${version}-Oss
zypper ar http://download.opensuse.org/distribution/leap/${version}/repo/non-oss/ openSUSE-Leap-${version}-Non-Oss
zypper ar http://download.opensuse.org/update/leap/${version}/oss/ openSUSE-Leap-${version}-Update
zypper ar http://download.opensuse.org/update/leap/${version}/non-oss/ openSUSE-Leap-${version}-Update-Non-Oss

zypper refresh
