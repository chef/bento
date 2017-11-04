#!/bin/sh -eux
# Major thanks to @timsutton's osx-vm-templates:
# https://github.com/timsutton/osx-vm-templates

osx_minor_version="`sw_vers -productVersion | awk -F '.' '{print $2}'`";

# Set computer/hostname
computer_name="macosx-10-${osx_minor_version}";
scutil --set ComputerName "$computer_name";
scutil --set HostName "${computer_name}.vagrantup.com";
