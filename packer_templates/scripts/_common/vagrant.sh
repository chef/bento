#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub";
mkdir -p "$HOME_DIR"/.ssh;
if command -v curl --insecure --location "$pubkey_url" > "$HOME_DIR"/.ssh/authorized_keys; then
  echo "Successfully downloaded vagrant public key with curl";
elif command -v wget --no-check-certificate "$pubkey_url" -O "$HOME_DIR"/.ssh/authorized_keys; then
  echo "Successfully downloaded vagrant public key with wget";
elif command -v fetch > /dev/null 2>&1; then
  fetch -am -o "$HOME_DIR"/.ssh/authorized_keys "$pubkey_url";
  echo "Successfully downloaded vagrant public key with fetch";
else
    echo "Cannot download vagrant public key";
    exit 1;
fi
chown -R vagrant "$HOME_DIR"/.ssh;
chmod -R go-rwsx "$HOME_DIR"/.ssh;
