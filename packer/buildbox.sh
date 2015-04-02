#!/bin/bash

VER=14.04.2
#VER=12.04.5

rm ../builds/virtualbox/opscode_ubuntu-${VER}_chef-provisionerless.box || true
packer build -only=virtualbox-iso ubuntu-${VER}-amd64.json
vagrant box remove opscode-ubuntu-${VER} || true
vagrant box add opscode-ubuntu-${VER} ../builds/virtualbox/opscode_ubuntu-${VER}_chef-provisionerless.box

echo "If this box tests out well, upload to AWS:"
echo "aws s3 cp ../builds/virtualbox/opscode_ubuntu-${VER}_chef-provisionerless.box s3://deployination/ --acl public-read"

