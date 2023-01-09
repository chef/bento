#!/bin/sh -eux

# update sudoers - can't do this in autoinst.xml
printf "\nupdate sudoers ..."
printf "vagrant ALL=(ALL) NOPASSWD: ALL\n" >> /etc/sudoers
