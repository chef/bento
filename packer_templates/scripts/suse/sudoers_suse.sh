#!/bin/sh -eux

# update sudoers - can't do this in autoinst.xml
echo "\nupdate sudoers ..."
echo "vagrant ALL=(ALL) NOPASSWD: ALL\n" >> /etc/sudoers
