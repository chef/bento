#!/bin/sh -eux

# Set $CHEF_VERSION inside Packer's template. Valid options are:
#   'provisionerless' -- build a box without Chef
#   'x.y.z'           -- build a box with version x.y.z of Chef
#   'latest'          -- build a box with the latest version of Chef

if [ x$CHEF_VERSION != x'provisionerless' ]; then
  if [ x$CHEF_VERSION == x'latest' ]; then
    echo "Installing latest Chef version"
    curl -L https://www.opscode.com/chef/install.sh | sh
  else
    echo "Installing Chef version $CHEF_VERSION"
    curl -L https://www.opscode.com/chef/install.sh | sh -s -- -v $CHEF_VERSION
  fi
else
  echo "Building a box without Chef"
fi
