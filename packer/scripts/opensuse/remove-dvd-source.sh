#!/bin/sh -eux

zypper removerepo "openSUSE-13.1-1.10"
rpm --import http://download.opensuse.org/distribution/13.1/repo/oss/gpg-pubkey-3dbdc284-4be1884d.asc
rpm --import http://download.opensuse.org/distribution/13.1/repo/oss/gpg-pubkey-307e3d54-4be01a65.asc
zypper ar http://download.opensuse.org/distribution/13.1/repo/oss/ opensuse-13.1-oss
zypper ar http://download.opensuse.org/distribution/13.1/repo/non-oss/ opensuse-13.1-non-oss
zypper ar http://download.opensuse.org/update/13.1/ opensuse-13.1-update
zypper ar http://download.opensuse.org/update/13.1-non-oss/ opensuse-13.1-update-non-oss
zypper refresh
zypper update -y
