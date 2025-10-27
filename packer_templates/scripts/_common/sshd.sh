#!/bin/sh -eux

OS_NAME=$(uname -s)

if [ "$OS_NAME" = "Darwin" ]; then
  echo "Nothing to do for $OS_NAME"
  exit 0
fi

if [ -f "/etc/ssh/sshd_config" ]; then
  SSHD_CONFIG="/etc/ssh/sshd_config"
elif [ -f "/usr/etc/ssh/sshd_config" ]; then
  SSHD_CONFIG="/usr/etc/ssh/sshd_config"
else
  echo "Unable to find sshd_config"
  exit 1
fi

# ensure that there is a trailing newline before attempting to concatenate
# shellcheck disable=SC1003
sed -i -e '$a\' "$SSHD_CONFIG"

USEDNS="UseDNS no"
if grep -q -E "^[[:space:]]*UseDNS" "$SSHD_CONFIG"; then
  sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$SSHD_CONFIG"
else
  echo "$USEDNS" >>"$SSHD_CONFIG"
fi

GSSAPI="GSSAPIAuthentication no"
if grep -q -E "^[[:space:]]*GSSAPIAuthentication" "$SSHD_CONFIG"; then
  sed -i "s/^\s*GSSAPIAuthentication.*/${GSSAPI}/" "$SSHD_CONFIG"
else
  echo "$GSSAPI" >>"$SSHD_CONFIG"
fi
