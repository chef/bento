#!/bin/bash -eux
# Chef with Fedora >= 30 requires libxcrypt-compat to be installed
dnf -y install libxcrypt-compat
