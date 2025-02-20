#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

if command -v ping > /dev/null 2>&1; then
  echo "Pinging raw.githubusercontent.com";
  if ! ping -c 1 raw.githubusercontent.com > /dev/null 2>&1; then
    echo "Ping failed, sleeping for 30 seconds";
    sleep 30;
  fi
fi

pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub";
mkdir -p "$HOME_DIR"/.ssh;
if command -v curl > /dev/null 2>&1; then
  curl --insecure --location "$pubkey_url" > "$HOME_DIR"/.ssh/authorized_keys && \
  echo "Successfully downloaded vagrant public key with curl";
elif command -v wget > /dev/null 2>&1; then
  wget --no-check-certificate "$pubkey_url" -O "$HOME_DIR"/.ssh/authorized_keys && \
  echo "Successfully downloaded vagrant public key with wget";
elif command -v fetch > /dev/null 2>&1; then
  fetch -am -o "$HOME_DIR"/.ssh/authorized_keys "$pubkey_url" && \
  echo "Successfully downloaded vagrant public key with fetch";
else
    echo "Cannot download vagrant public key";
    exit 1;
fi
chown -R vagrant "$HOME_DIR"/.ssh;
chmod -R go-rwsx "$HOME_DIR"/.ssh;
