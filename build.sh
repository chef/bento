#!/usr/local/bin/bash

set -eo pipefail

env

source ~/.bashrc

function inline_image {
  printf '\033]1338;url='"$1"';alt='"$2"'\a\n'
}

inline_image 'https://oaxacaborn.files.wordpress.com/2012/02/clean-all-the-things-via-hyperbole-and-a-half.png' 'Clean All The Things'


echo "--- Cleaning up after VirtualBox"

for i in `vboxmanage list runningvms | awk '{print $1}' | sed 's/"//g'`
do
  echo "Powering off $i"
  vboxmanage controlvm $i poweroff
done

for i in `vboxmanage list vms | awk '{print $1}' | sed 's/"//g'`
do
  echo "Unregistering $i"
  sleep 10
  vboxmanage unregistervm $i
done

for i in `ls ~/VirtualBox\ VMs/`
do
  echo "Removing $i"
  rm -rf ~/VirtualBox\ VMs/$i
done

echo "--- Cleaning up after Parallels"

for i in `prlctl list --no-header --output name`
do
  echo "Powering off $i"
  prlctl stop $i --kill
  sleep 10
done

for i in `prlctl list --all --no-header --output uuid`
do
  echo "Unregistering $i"
  prlctl unregister $i
done

echo "--- Cleaning up after Fusion"

for i in `vmrun list | grep -v "Total"`
do
  echo "Stopping $i"
  vmrun stop $i
  sleep 10

  echo "Deleting $i"
  vmrun deleteVM $i
done

echo "--- Cleaning up after Packer"
rake clean

echo "--- Build $PLATFORM-$BENTO_PROVIDERS"
rake build_box[$PLATFORM]

echo "--- Test $PLATFORM-$BENTO_PROVIDERS"
rake test_all

if [ $BENTO_UPLOAD -eq 1 ]
then
  echo "--- Upload Boxes to S3"
  rake upload_all_s3

  echo "--- Upload Boxes to Atlas"
  rake upload_all

  echo "--- Release Boxes on Atlas"
  rake release_all
fi
