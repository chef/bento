#!/bin/sh -eux

echo "updating all packages"
zypper update -y

reboot
