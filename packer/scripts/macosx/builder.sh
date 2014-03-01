#!/bin/bash -eux

home_dir="$(python -c 'import pwd; print pwd.getpwnam("vagrant").pw_dir')"

if [ "$PACKER_BUILDER_TYPE" = "vmware" ]; then
    version_file="$home_dir/.vmfusion_version"
    mkdir -p $(dirname $version_file)
    touch $version_file
fi
