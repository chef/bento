#!/bin/sh
#
# @file vagrant_omnios.sh
# @brief Vagrant user SSH key and privilege configuration script for OmniOS
# @description
#   Installs HashiCorp's official insecure Vagrant public SSH key into the
#   vagrant user's authorized_keys file, enforces strict Unix permissions,
#   and ensures non-interactive (non-TTY) sudo execution without password prompts.
#
set -eux

#
# @function install_vagrant_ssh_key
# @description
#   Downloads the official Vagrant public key (falling back to built-in key if network fails),
#   places it in ~/.ssh/authorized_keys, and applies correct ownership and file permissions.
# @param [String] user_home Target user home directory path.
# @return [Integer] Returns 0 on success.
#
install_vagrant_ssh_key() {
  _home_dir="$1"
  _ssh_dir="${_home_dir}/.ssh"
  _auth_keys="${_ssh_dir}/authorized_keys"
  _pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub"

  mkdir -p "$_ssh_dir"
  chmod 0700 "$_ssh_dir"

  _downloaded=0
  if command -v curl >/dev/null 2>&1; then
    if curl --insecure --location --silent --show-error --output "$_auth_keys" "$_pubkey_url"; then
      _downloaded=1
    fi
  elif command -v wget >/dev/null 2>&1; then
    if wget --no-check-certificate -qO "$_auth_keys" "$_pubkey_url"; then
      _downloaded=1
    fi
  fi

  if [ "$_downloaded" -eq 0 ]; then
    echo "Network fetch unavailable or failed, writing embedded HashiCorp Vagrant public key..."
    cat <<'EOF' > "$_auth_keys"
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1YdxBpNlzxDqfJyw/QKow1F+wvG9hXGoqiysfJOn5Y vagrant insecure public key
EOF
  fi

  chmod 0600 "$_auth_keys"
  chown -R vagrant:staff "$_ssh_dir"
}

#
# @function configure_sudo_privileges
# @description
#   Configures sudoers drop-in configuration for passwordless privilege escalation
#   and ensures requiretty is disabled for automated provisioning.
# @noargs
# @return [Integer] Returns 0 on success.
#
configure_sudo_privileges() {
  _sudoers_dir="/etc/sudoers.d"
  mkdir -p "$_sudoers_dir"

  cat <<'EOF' > "${_sudoers_dir}/vagrant"
vagrant ALL=(ALL) NOPASSWD: ALL
Defaults:vagrant !requiretty
EOF
  chmod 0440 "${_sudoers_dir}/vagrant"

  # Ensure main sudoers file includes /etc/sudoers.d directory
  if ! grep -q '^#includedir /etc/sudoers.d' /etc/sudoers 2>/dev/null; then
    echo '#includedir /etc/sudoers.d' >> /etc/sudoers
  fi
}

#
# @function main
# @description
#   Main routine to configure the vagrant user SSH authorized_keys and sudo rules.
# @noargs
# @return [Integer] Returns 0 on completion.
#
main() {
  _target_home="/export/home/vagrant"
  if [ ! -d "$_target_home" ]; then
    _target_home="/home/vagrant"
  fi

  install_vagrant_ssh_key "$_target_home"
  configure_sudo_privileges
}

main
