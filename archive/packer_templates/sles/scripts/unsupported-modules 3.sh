#!/bin/sh

# Enable unsupported kernel modules, so vboxguest can install
sed -i -e 's#^allow_unsupported_modules 0#allow_unsupported_modules 1#' /etc/modprobe.d/10-unsupported-modules.conf
