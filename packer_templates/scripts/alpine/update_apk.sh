#!/bin/sh -eux

# update all packages
apk upgrade --available

reboot;
sleep 60;
