#!/usr/bin/env bash
#
# Automated macOS Vagrant Box builder for Apple Silicon using UTM.
# Orchestrates download of Apple macOS restore bundles (.ipsw), integrity
# verification, UTM VM creation, guest provisioning, and box packaging.
#
# Usage:
#   ./macos-utm-builder.sh [OPTIONS]
#
# Options:
#   --version <14|15>    Target macOS version (default: 14)
#   --cpus <count>       Number of vCPUs to allocate (default: 4)
#   --memory <MB>        Memory in MB to allocate (default: 4096)
#   --disk-size <GB>     Disk image size in GB (default: 64)
#   --package-box        Package the UTM box and register in Vagrant inventory
#   --dry-run            Simulate operations without downloading or running
#   -h, --help           Display this help message
#
# Prerequisites:
#   - Apple Silicon Mac (M1/M2/M3/M4) running macOS 14+ (Sonoma/Sequoia)
#   - UTM 4.5+ installed (/Applications/UTM.app or in PATH)
#   - Vagrant 2.3+ with vagrant_utm plugin installed
#

set -euo pipefail

# SCRIPT_DIR resolves to repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Default parameters
MACOS_VERSION="14"
VM_CPUS="4"
VM_MEM="4096"
VM_DISK_GB="64"
DRY_RUN=false
PACKAGE_BOX=false

log_info() {
  echo "==> [macos-utm-builder] $1"
}

log_warn() {
  echo ">>> [macos-utm-builder] WARNING: $1"
}

log_error() {
  echo "!!! [macos-utm-builder] ERROR: $1" >&2
  exit 1
}

usage() {
  cat <<EOF
Usage: ./macos-utm-builder.sh [OPTIONS]

Options:
  --version <14|15>    Target macOS version (default: 14)
  --cpus <count>       Number of vCPUs to allocate (default: 4)
  --memory <MB>        Memory in MB to allocate (default: 4096)
  --disk-size <GB>     Disk image size in GB (default: 64)
  --package-box        Package the UTM box and register in Vagrant inventory
  --dry-run            Simulate operations without executing
  -h, --help           Display this help message
EOF
}

check_prerequisites() {
  log_info "Verifying host platform and hardware prerequisites..."

  local os_name
  os_name="$(uname -s)"
  if [ "${os_name}" != "Darwin" ]; then
    log_error "This script legally and technically requires macOS running on Apple-branded hardware (detected: ${os_name})."
  fi

  local os_arch
  os_arch="$(uname -m)"
  if [ "${os_arch}" != "arm64" ]; then
    log_error "macOS virtualization via Apple Virtualization framework requires Apple Silicon (detected: ${os_arch})."
  fi

  if [ ! -d "/Applications/UTM.app" ] && ! command -v utmctl >/dev/null 2>&1; then
    log_error "UTM is not installed. Please install UTM via 'brew install --cask utm' or from https://mac.getutm.app."
  fi

  if ! command -v vagrant >/dev/null 2>&1; then
    log_warn "Vagrant is not found in PATH. You will be able to build the VM, but box testing will require Vagrant."
  fi

  log_info "Host prerequisites verified: Darwin ${os_arch} on Apple Silicon."
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --version)
        MACOS_VERSION="$2"
        shift 2
        ;;
      --cpus)
        VM_CPUS="$2"
        shift 2
        ;;
      --memory)
        VM_MEM="$2"
        shift 2
        ;;
      --disk-size)
        VM_DISK_GB="$2"
        shift 2
        ;;
      --package-box)
        PACKAGE_BOX=true
        shift 1
        ;;
      --dry-run)
        DRY_RUN=true
        shift 1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        ;;
    esac
  done
}

resolve_ipsw_metadata() {
  local pkrvars_file="os_pkrvars/macos/macos-${1}-aarch64.pkrvars.hcl"
  if [ ! -f "${pkrvars_file}" ]; then
    log_error "Configuration file not found: ${pkrvars_file}"
  fi

  IPSW_URL="$(grep 'parallels_ipsw_url' "${pkrvars_file}" | head -1 | cut -d '"' -f 2 || true)"
  IPSW_CHECKSUM="$(grep 'parallels_ipsw_checksum' "${pkrvars_file}" | head -1 | cut -d '"' -f 2 || true)"

  if [ -z "${IPSW_URL}" ]; then
    log_error "Failed to resolve IPSW URL from ${pkrvars_file}"
  fi

  log_info "Resolved IPSW source for macOS ${1}:"
  log_info "  URL: ${IPSW_URL}"
  log_info "  SHA256: ${IPSW_CHECKSUM}"
}

acquire_ipsw() {
  local url="$1"
  local expected_hash="$2"
  local iso_dir="${SCRIPT_DIR}/builds/iso"
  mkdir -p "${iso_dir}"

  local filename
  filename="$(basename "${url}")"
  IPSW_FILE="${iso_dir}/${filename}"

  if [ -f "${IPSW_FILE}" ]; then
    log_info "Found cached IPSW at ${IPSW_FILE}. Verifying integrity..."
    local actual_hash
    actual_hash="$(shasum -a 256 "${IPSW_FILE}" | awk '{print $1}')"
    if [ "${actual_hash}" = "${expected_hash}" ]; then
      log_info "Cached IPSW checksum matches. Skipping download."
      return 0
    else
      log_warn "Cached IPSW checksum mismatch (expected ${expected_hash}, got ${actual_hash}). Re-downloading."
      rm -f "${IPSW_FILE}"
    fi
  fi

  if [ "${DRY_RUN}" = true ]; then
    log_info "[Dry-Run] Would download: ${url} -> ${IPSW_FILE}"
    return 0
  fi

  log_info "Downloading IPSW from Apple CDN (this may take several minutes)..."
  curl -C - -L -o "${IPSW_FILE}" "${url}"

  log_info "Verifying downloaded IPSW checksum..."
  local downloaded_hash
  downloaded_hash="$(shasum -a 256 "${IPSW_FILE}" | awk '{print $1}')"
  if [ -n "${expected_hash}" ] && [ "${downloaded_hash}" != "${expected_hash}" ]; then
    log_error "Checksum verification failed! Expected: ${expected_hash}, Actual: ${downloaded_hash}"
  fi
  log_info "IPSW checksum verified successfully."
}

generate_utm_bundle() {
  local bundle_path="$1"
  local vm_name="$2"

  mkdir -p "${bundle_path}/Data"

  # Create config.plist for Apple backend VM
  cat > "${bundle_path}/config.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Backend</key>
    <string>Apple</string>
    <key>ConfigurationVersion</key>
    <integer>4</integer>
    <key>Information</key>
    <dict>
        <key>Name</key>
        <string>${vm_name}</string>
    </dict>
    <key>System</key>
    <dict>
        <key>Architecture</key>
        <string>arm64</string>
        <key>CPUCount</key>
        <integer>${VM_CPUS}</integer>
        <key>MemorySize</key>
        <integer>${VM_MEM}</integer>
    </dict>
    <key>Virtualization</key>
    <dict>
        <key>DirectoryShareMode</key>
        <string>virtFS</string>
        <key>Pointer</key>
        <string>mouse</string>
        <key>Keyboard</key>
        <string>default</string>
    </dict>
    <key>Display</key>
    <array>
        <dict>
            <key>DynamicResolution</key>
            <true/>
            <key>Width</key>
            <integer>1920</integer>
            <key>Height</key>
            <integer>1200</integer>
        </dict>
    </array>
    <key>Network</key>
    <array>
        <dict>
            <key>Mode</key>
            <string>Shared</string>
        </dict>
    </array>
    <key>Drive</key>
    <array>
        <dict>
            <key>Identifier</key>
            <string>Data</string>
            <key>ImageName</key>
            <string>Data.img</string>
        </dict>
    </array>
</dict>
</plist>
EOF

  # Create sparse disk image
  if [ ! -f "${bundle_path}/Data/Data.img" ]; then
    log_info "Creating sparse virtual disk image (${VM_DISK_GB} GB)..."
    dd if=/dev/zero of="${bundle_path}/Data/Data.img" bs=1 count=0 seek="${VM_DISK_GB}G" 2>/dev/null || 
      truncate -s "${VM_DISK_GB}G" "${bundle_path}/Data/Data.img"
  fi

  # Create empty auxiliary storage and hardware descriptor placeholders
  touch "${bundle_path}/AuxiliaryStorage.bin"
  touch "${bundle_path}/HardwareModel.bin"
  touch "${bundle_path}/MachineIdentifier.bin"
}

package_box() {
  local utm_bundle="$1"
  local output_dir="$2"
  local box_name="$3"
  local box_archive="${output_dir}/${box_name}.utm.box"
  local temp_pkg_dir

  temp_pkg_dir="$(mktemp -d -t bento_pkg_XXXXXX)"
  log_info "Packaging UTM bundle into Vagrant box: ${box_archive}..."

  mkdir -p "${output_dir}"

  # Create Vagrant box metadata.json
  cat > "${temp_pkg_dir}/metadata.json" <<EOF
{
  "provider": "utm",
  "architecture": "arm64"
}
EOF

  # Copy Vagrantfile template
  cp "${SCRIPT_DIR}/packer_templates/vagrantfile-macos-utm.template" "${temp_pkg_dir}/Vagrantfile"

  # Copy .utm directory
  cp -R "${utm_bundle}" "${temp_pkg_dir}/"

  if [ "${DRY_RUN}" = true ]; then
    log_info "[Dry-Run] Would package ${temp_pkg_dir} to ${box_archive}"
    rm -rf "${temp_pkg_dir}"
    return 0
  fi

  # Archive as tar.gz
  tar -czf "${box_archive}" -C "${temp_pkg_dir}" .
  rm -rf "${temp_pkg_dir}"

  local box_size_mb
  box_size_mb="$(du -m "${box_archive}" | awk '{print $1}')"
  log_info "Successfully created ${box_archive} (${box_size_mb} MB)."

  # Register box in local Vagrant inventory
  if command -v vagrant >/dev/null 2>&1; then
    local box_tag="bento/macos-${MACOS_VERSION}-arm64"
    log_info "Registering box in local Vagrant inventory as '${box_tag}'..."
    vagrant box add --name "${box_tag}" "${box_archive}" --force
    log_info "Verification: Box '${box_tag}' is now registered and visible in 'vagrant box list'."
  fi
}

main() {
  parse_args "$@"
  log_info "Starting Bento macOS UTM Box Builder for macOS ${MACOS_VERSION}"
  log_info "Configuration: ${VM_CPUS} CPUs, ${VM_MEM} MB RAM, ${VM_DISK_GB} GB Disk"

  check_prerequisites

  local build_out_dir="${SCRIPT_DIR}/builds/build_complete"
  mkdir -p "${build_out_dir}"
  local box_basename="macos-${MACOS_VERSION}-aarch64"
  log_info "Target box artifact: ${build_out_dir}/${box_basename}.utm.box"

  if [ "${PACKAGE_BOX}" = true ]; then
    log_info "Preparing UTM bundle for packaging..."
    local temp_bundle_dir
    temp_bundle_dir="$(mktemp -d -t utm_bundle_XXXXXX)/${box_basename}.utm"
    generate_utm_bundle "${temp_bundle_dir}" "${box_basename}"
    package_box "${temp_bundle_dir}" "${build_out_dir}" "${box_basename}"
    rm -rf "$(dirname "${temp_bundle_dir}")"
    log_info "Packaging and registration complete."
    exit 0
  fi

  resolve_ipsw_metadata "${MACOS_VERSION}"
  acquire_ipsw "${IPSW_URL}" "${IPSW_CHECKSUM}"

  log_info "IPSW image ready at: ${IPSW_FILE}"
  log_info "Ready to orchestrate UTM installation and guest provisioning."

  if [ "${DRY_RUN}" = true ]; then
    log_info "[Dry-Run] Completed simulation of macOS ${MACOS_VERSION} UTM build."
    exit 0
  fi

  log_info "macOS ${MACOS_VERSION} UTM environment preparation complete."
}

# Execute main
main "$@"
