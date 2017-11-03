#!/bin/sh -eux

# Variables
URL=""
INSTALL_SCRIPT="install.sh"
VERSION_CMD=""

saltminion () {
  URL="https://bootstrap.saltstack.com"
  VERSION_CMD="-P stable"
}

chefclient () {
  URL="https://omnitruck.chef.io/install.sh"
  VERSION_CMD="-v"
}

install () {
  curl -o $INSTALL_SCRIPT -L $URL
  if [ -z "$CM_VERSION" ];
  then
    bash $INSTALL_SCRIPT
  else
    echo "Version: $CM_VERSION"
    bash $INSTALL_SCRIPT $VERSION_CMD $CM_VERSION
  fi
  echo "Removing script: bootstrap.sh"
  rm $INSTALL_SCRIPT
}

case "$CM_PROVISIONER" in
  saltminion)
  echo "Installing Salt Minion"
  saltminion
  install
  salt-minion --versions-report
  ;;
  chefclient)
  echo "Installing Chef Client"
  chefclient
  install
  chef-client --version
  ;;
esac
