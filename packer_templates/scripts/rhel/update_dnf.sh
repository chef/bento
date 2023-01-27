#!/bin/sh -eux

# update all packages
dnf -y upgrade --skip-broken

reboot;
sleep 60;
