#!/bin/bash -eux
# Installing yum for compatibility, especially for chef/kitchen tests
# https://github.com/chef/chef/issues/5492
dnf -y install yum
