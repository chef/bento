#!/usr/bin/env bash

set -eo pipefail

source ~/.bashrc

env

function inline_image {
  printf '\033]1338;url='%s';alt='%s'\a\n' "$1" "$2"
}

inline_image 'https://oaxacaborn.files.wordpress.com/2012/02/clean-all-the-things-via-hyperbole-and-a-half.png' 'Clean All The Things'


echo "--- Cleaning up after VirtualBox"

for i in $(vboxmanage list runningvms | awk '{print $1}' | sed 's/"//g')
do
  echo "Powering off $i"
  vboxmanage controlvm "$i" poweroff
done

for i in $(vboxmanage list vms | awk '{print $1}' | sed 's/"//g')
do
  echo "Unregistering $i"
  sleep 10
  vboxmanage unregistervm "$i"
done

for i in ~/VirtualBox\ VMs/*
do
  echo "Removing $i"
  rm -rf ~/VirtualBox\ VMs/"$i"
done

echo "--- Cleaning up after Parallels"

for i in $(prlctl list --no-header --output name)
do
  echo "Powering off $i"
  prlctl stop "$i" --kill
  sleep 10
done

for i in $(prlctl list --all --no-header --output uuid)
do
  echo "Unregistering $i"
  prlctl unregister "$i"
done

echo "--- Cleaning up after VMware"

for i in $(vmrun list | grep -v "Total")
do
  echo "Stopping $i"
  vmrun stop "$i"
  sleep 10

  echo "Deleting $i"
  vmrun deleteVM "$i"
done

echo "--- Cleaning up after Packer"
rake clean

echo "--- Build $PLATFORM-$BENTO_PROVIDERS"
./bin/bento build --headless --version $BENTO_VERSION --only $BENTO_PROVIDERS $PLATFORM

echo "--- Test $PLATFORM-$BENTO_PROVIDERS"
if [ "$BENTO_TEST_SHARED_FOLDER" -eq 1 ]
then
  echo "--- Testing Shared Folder Support"
  ./bin/bento test -f
else
  echo "--- NOT Testing Shared Folder Support"
  ./bin/bento test
fi

if [ "$BENTO_UPLOAD" -eq 1 ]
then
  echo "--- Upload Boxes to Atlas and S3"
  ./bin/bento upload

  echo "--- Release Boxes on Atlas"
  ./bin/bento release $ATLAS_NAME $BENTO_VERSION
fi
