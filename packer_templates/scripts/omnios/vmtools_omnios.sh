#!/bin/sh
#
# @file vmtools_omnios.sh
# @brief Hypervisor integration and guest additions installation script for OmniOS
# @description
#   Detects the active hypervisor environment (VirtualBox, VMware, QEMU/KVM, UTM)
#   and installs corresponding guest integration utilities, driver packages, or
#   services to enable clipboard sharing, time synchronization, and optimized I/O.
#
set -eux

#
# @function install_virtualbox_tools
# @description
#   Installs VirtualBox Solaris Guest Additions using an automated non-interactive
#   pkgadd admin response file.
# @param [String] home_dir Path to vagrant user home directory.
# @return [Integer] Returns 0 on completion.
#
install_virtualbox_tools() {
  _home_dir="$1"
  echo "Checking for VirtualBox Guest Additions..."

  # Create pkgadd non-interactive answer file
  _admin_file="/tmp/vbox_pkgadd_nocheck"
  cat <<'EOF' > "$_admin_file"
mail=
instance=overwrite
partial=nocheck
runlevel=nocheck
idepend=nocheck
rdepend=nocheck
space=nocheck
setuid=nocheck
conflict=nocheck
action=nocheck
basedir=default
EOF

  _pkg_path=""
  for _cand in /media/VBOXADDITIONS_*/VBoxSolarisAdditions.pkg /tmp/vbox/VBoxSolarisAdditions.pkg; do
    if [ -f "$_cand" ]; then
      _pkg_path="$_cand"
      break
    fi
  done

  # If not already mounted, look for ISO file
  if [ -z "$_pkg_path" ]; then
    _iso_file=""
    if [ -f "${_home_dir}/.vbox_version" ]; then
      _vbox_ver=$(cat "${_home_dir}/.vbox_version")
      for _iso_cand in "${_home_dir}/VBoxGuestAdditions_${_vbox_ver}.iso" "${_home_dir}/VBoxGuestAdditions.iso" /tmp/VBoxGuestAdditions.iso; do
        if [ -f "$_iso_cand" ]; then
          _iso_file="$_iso_cand"
          break
        fi
      done
    fi

    if [ -n "$_iso_file" ] && command -v lofiadm >/dev/null 2>&1; then
      mkdir -p /tmp/vbox
      _lofi_dev=$(lofiadm -a "$_iso_file" 2>/dev/null || true)
      if [ -n "$_lofi_dev" ]; then
        mount -F hsfs -o ro "$_lofi_dev" /tmp/vbox || true
        if [ -f /tmp/vbox/VBoxSolarisAdditions.pkg ]; then
          _pkg_path="/tmp/vbox/VBoxSolarisAdditions.pkg"
        fi
      fi
    fi
  fi

  if [ -n "$_pkg_path" ]; then
    echo "Installing VirtualBox additions from $_pkg_path..."
    echo "all" | pkgadd -a "$_admin_file" -d "$_pkg_path" || true
  else
    echo "VirtualBox guest additions package not located; continuing."
  fi

  rm -f "$_admin_file"
}

#
# @function install_vmware_tools
# @description
#   Installs VMware guest integration utilities via IPS repository.
# @noargs
# @return [Integer] Returns 0 on completion.
#
install_vmware_tools() {
  echo "Installing VMware tools if available in repository..."
  pkg install --accept open-vm-tools 2>/dev/null || true
  if command -v svcadm >/dev/null 2>&1; then
    svcadm enable svc:/application/vmtoolsd:default 2>/dev/null || true
  fi
}

#
# @function install_qemu_tools
# @description
#   Installs and activates QEMU guest agent for time synchronization and host coordination.
# @noargs
# @return [Integer] Returns 0 on completion.
#
install_qemu_tools() {
  echo "Installing QEMU guest agent if available..."
  pkg install --accept qemu-guest-agent 2>/dev/null || true
  if command -v svcadm >/dev/null 2>&1; then
    svcadm enable svc:/application/qemu-guest-agent:default 2>/dev/null || true
  fi
}

#
# @function main
# @description
#   Detects packer builder type or hypervisor hardware and installs appropriate tools.
# @noargs
# @return [Integer] Returns 0 upon completion.
#
main() {
  _home_dir="/export/home/vagrant"
  if [ ! -d "$_home_dir" ]; then
    _home_dir="/home/vagrant"
  fi

  _builder="${PACKER_BUILDER_TYPE:-}"

  case "$_builder" in
    virtualbox-iso|virtualbox-ovf)
      install_virtualbox_tools "$_home_dir"
      ;;
    vmware-iso|vmware-vmx)
      install_vmware_tools
      ;;
    qemu|utm-iso)
      install_qemu_tools
      ;;
    *)
      # Attempt detection based on available markers
      if [ -f "${_home_dir}/.vbox_version" ] || [ -d /media/VBOXADDITIONS* ]; then
        install_virtualbox_tools "$_home_dir"
      fi
      install_vmware_tools
      install_qemu_tools
      ;;
  esac
}

main
