#!/bin/bash -eux

aptitude update
aptitude -y full-upgrade

reboot
sleep 10

exit
