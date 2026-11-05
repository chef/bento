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

if command -v sshd >/dev/null 2>&1; then
  if sshd -T 2>/dev/null | grep -q -i "pubkeyacceptedalgorithms"; then
    RSA_ALGO="PubkeyAcceptedAlgorithms +ssh-rsa"
    if grep -q -E "^[[:space:]]*PubkeyAcceptedAlgorithms" "$SSHD_CONFIG"; then
      sed -i "s/^\s*PubkeyAcceptedAlgorithms.*/${RSA_ALGO}/" "$SSHD_CONFIG"
    else
      echo "$RSA_ALGO" >>"$SSHD_CONFIG"
    fi
  elif sshd -T 2>/dev/null | grep -q -i "pubkeyacceptedkeytypes"; then
    RSA_ALGO="PubkeyAcceptedKeyTypes +ssh-rsa"
    if grep -q -E "^[[:space:]]*PubkeyAcceptedKeyTypes" "$SSHD_CONFIG"; then
      sed -i "s/^\s*PubkeyAcceptedKeyTypes.*/${RSA_ALGO}/" "$SSHD_CONFIG"
    else
      echo "$RSA_ALGO" >>"$SSHD_CONFIG"
    fi
  fi
fi
