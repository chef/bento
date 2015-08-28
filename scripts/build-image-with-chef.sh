#!/bin/bash
DIR_NAME="packer-$(basename -s .json $1)"
IMAGE_NAME="$(grep vm_name $1 | awk '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//g')"
IP1="nameserver 140.211.166.130"
IP2="nameserver 140.211.166.131"
set -xe
cd packer
packer build -var 'chef_version=latest' $(basename $1)
qemu-img convert -o compat=0.10 -O qcow2 -c ${DIR_NAME}/${IMAGE_NAME}.qcow2 \
  ${DIR_NAME}/${IMAGE_NAME}-compressed.qcow2
