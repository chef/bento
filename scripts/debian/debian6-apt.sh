#!/bin/sh -eux

sed -i 's/mirrors.kernel.org/archive.debian.org/g' /etc/apt/sources.list
