#!/bin/bash
CHEF_VERSION="provisionerless"
TEMPLATE=

run_help() {
  echo " Usage: $0 [-c] [-v CHEF_VERSION] -t path/to/template.json"
  echo
  echo " Build packer build and compress the qcow2 file"
  echo
  echo "  -c          Build with Chef"
  echo "  -v VERSION  Build with specific version of Chef"
  echo "  -t FILE     Packer template to use"
  exit 0
}

while getopts "hcv:t:" opt ; do
  case $opt in
    c)
      CHEF_VERSION="latest"
      ;;
    v)
      CHEF_VERSION="$OPTARG"
      ;;
    t)
      TEMPLATE="$OPTARG"
      ;;
    h)
      run_help
      ;;
    *)
      ;;
  esac
done

[ -z "$TEMPLATE" ] && echo "Error: Template file not set" && exit 1

DIR_NAME="packer-$(basename -s .json $TEMPLATE)"
IMAGE_NAME=$(grep vm_name $TEMPLATE | awk '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//g')
set -xe
cd packer
packer build -var "chef_version=$CHEF_VERSION" $(basename $TEMPLATE)
qemu-img convert -o compat=0.10 -O qcow2 -c ${DIR_NAME}/${IMAGE_NAME}.qcow2 \
  ${DIR_NAME}/${IMAGE_NAME}-compressed.qcow2
