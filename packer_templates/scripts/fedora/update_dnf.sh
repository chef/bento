#!/bin/sh -eux

# update all packages
dnf -y upgrade

reboot;
sleep 60;
