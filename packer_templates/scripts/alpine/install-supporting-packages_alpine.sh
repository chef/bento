#!/bin/sh

set -eux

# Chef with Fedora >= 30 requires libxcrypt-compat to be installed
# dnf -y install libxcrypt-compat
# https://gitlab.alpinelinux.org/alpine/aports/-/issues/13251
# not yet^
