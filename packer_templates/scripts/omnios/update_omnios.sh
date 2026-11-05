#!/bin/sh
#
# @file update_omnios.sh
# @brief OmniOS system update and package installation provisioning script
# @description
#   Refreshes IPS (Image Packaging System) publisher catalogs, upgrades installed
#   packages to the latest versions accepted by publisher policies, and installs
#   core utility packages (curl, wget, git, rsync, sudo, bash) essential for
#   subsequent provisioning, testing, and libscript runtime execution.
#
set -eux

#
# @function refresh_publishers
# @description
#   Refreshes all configured IPS publisher metadata catalogs from remote repositories.
# @noargs
# @return [Integer] Returns 0 upon successful refresh.
#
refresh_publishers() {
  echo "Refreshing IPS package publishers..."
  pkg refresh --full || true
}

#
# @function upgrade_packages
# @description
#   Upgrades installed packages in the current boot environment according to publisher policies.
# @noargs
# @return [Integer] Returns 0 upon successful upgrade.
#
upgrade_packages() {
  echo "Upgrading installed system packages..."
  pkg update --accept || true
}

#
# @function install_prerequisites
# @description
#   Installs baseline administration, networking, and version control tools via pkg.
# @noargs
# @return [Integer] Returns 0 upon successful package installation.
#
install_prerequisites() {
  echo "Installing baseline administration packages..."
  for pkg_name in web/curl web/wget developer/versioning/git network/rsync security/sudo shell/bash; do
    pkg install --accept "$pkg_name" || true
  done
}

#
# @function main
# @description
#   Main entry point executing package catalog refresh, system upgrade, and utility installation.
# @noargs
# @return [Integer] Returns 0 upon completion.
#
main() {
  refresh_publishers
  upgrade_packages
  install_prerequisites
}

main
