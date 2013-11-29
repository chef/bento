#!/bin/sh -eux

# Set $CHEF_VERSION inside Packer's template. Valid options are:
#   'provisionerless' -- build a box without Chef
#   'x.y.z'           -- build a box with version x.y.z of Chef
#   'latest'          -- build a box with the latest version of Chef

exists() {
  if command -v $1 &>/dev/null
  then
    return 0
  else
    return 1
  fi
}

if [ x$CHEF_VERSION != x'provisionerless' ]; then
  if [ x$CHEF_VERSION == x'latest' ]; then
    echo "Installing latest Chef version"
    if exists wget; then
      wget https://www.opscode.com/chef/install.sh -O - | sh
    else
      if exists curl; then
        curl -L https://www.opscode.com/chef/install.sh | sh
      fi
    fi
  else
    echo "Installing Chef version $CHEF_VERSION"
    if exists wget; then
      wget https://www.opscode.com/chef/install.sh -O - | sh -s -- -v $CHEF_VERSION
    else
      if exists curl; then
        curl -L https://www.opscode.com/chef/install.sh | sh -s -- -v $CHEF_VERSION
      fi
    fi
  fi
else
  echo "Building a box without Chef"
fi
