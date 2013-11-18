#!/bin/sh -eux

# Set $CHEF_VERSION inside Packer's template. Valid options are:
#   'provisionerless' -- build a box without Chef
#   'x.y.z'           -- build a box with version x.y.z of Chef
#   'latest'          -- build a box with the latest version of Chef

if [ $CHEF_VERSION != 'provisionerless' ]; then
  if [ $CHEF_VERSION == 'latest' ]; then
    echo "Installing latest Chef version"
    sh <(curl -L https://www.opscode.com/chef/install.sh)
  else
    echo "Installing Chef version $CHEF_VERSION"
    sh <(curl -L https://www.opscode.com/chef/install.sh) -v $CHEF_VERSION
  fi
else
  echo "Building a box without Chef"
fi
