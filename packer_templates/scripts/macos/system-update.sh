#!/bin/sh

echo "Downloading and installing system updates..."
softwareupdate -i -r -R
