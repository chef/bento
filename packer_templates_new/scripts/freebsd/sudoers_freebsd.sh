#!/bin/sh -eux

pkg install -y sudo;
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >>/usr/local/etc/sudoers;
