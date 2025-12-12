#!/bin/sh -eux

# shellcheck disable=SC2024,SC2260,SC3020
if ! sudo --version &>/dev/stdout | grep -q sudo-rs; then
  sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers;
fi

# Set up password-less sudo for the vagrant user
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/99_vagrant;
chmod 440 /etc/sudoers.d/99_vagrant;
