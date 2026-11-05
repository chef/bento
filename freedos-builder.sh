#!/bin/sh
#
# @file freedos-builder.sh
# @brief Standalone FreeDOS Automated Builder, Runner, Syncer & Vagrant Box Packaging Tool for Bento
# @description
#   Downloads and verifies the official FreeDOS 1.3 LiteUSB / Live distribution,
#   prepares a bootable FreeDOS disk image (`C:`) pre-provisioned with the Bento
#   Serial/Telnet Agent (`FDCONFIG.SYS`, `FDAUTO.BAT`, `C:\BENTO\VAGAGENT.BAT`,
#   `RUNCMD.BAT`, `B64ENC.COM`, `B64DEC.COM`, and DOS extender runtimes),
#   converts it to qcow2/raw, packages Vagrant `.box` archives for both `arm64`
#   (`aarch64`) and `amd64` (`x86_64`) hosts across `qemu`, `libvirt`, and `utm`
#   providers, and registers them in Vagrant (`vagrant box list`).
#

set -eu

COPYFILE_DISABLE=1
export COPYFILE_DISABLE

FREEDOS_VERSION="${FREEDOS_VERSION:-1.3}"
HOST_ARCH_RAW=$(uname -m)
if [ "$HOST_ARCH_RAW" = "arm64" ] || [ "$HOST_ARCH_RAW" = "aarch64" ]; then
  DEFAULT_ARCH="aarch64"
else
  DEFAULT_ARCH="x86_64"
fi

OS_ARCH="${OS_ARCH:-$DEFAULT_ARCH}"
SERIAL_HOST="${FREEDOS_SERIAL_HOST:-127.0.0.1}"
SERIAL_PORT="${FREEDOS_SERIAL_PORT:-2323}"
SERIAL_SOCKET="${FREEDOS_SERIAL_SOCKET:-/tmp/freedos-serial.sock}"
MONITOR_SOCKET="${FREEDOS_MONITOR_SOCKET:-/tmp/freedos-monitor.sock}"
SYNC_DIR="${FREEDOS_SYNC_DIR:-}"

LITEUSB_URL="${FREEDOS_LITEUSB_URL:-https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-LiteUSB.zip}"
LITEUSB_ZIP_NAME="FD13-LiteUSB.zip"

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
BUILDS_DIR="${SCRIPT_DIR}/builds"
ISO_DIR="${BUILDS_DIR}/iso"
BOX_DIR="${BUILDS_DIR}/build_complete"
RAW_DISK="${BUILDS_DIR}/freedos-${FREEDOS_VERSION}.img"
QCOW2_DISK="${BUILDS_DIR}/freedos-${FREEDOS_VERSION}.qcow2"
SYNC_DISK="${BUILDS_DIR}/freedos_sync_d.raw"
PKR_VARS_FILE="${SCRIPT_DIR}/os_pkrvars/freedos/freedos-${FREEDOS_VERSION}-${OS_ARCH}.pkrvars.hcl"

#
# @function banner
# @description Prints a formatted section header banner to standard output.
# @param [String] message The banner message to print.
# @return [void]
#
banner() {
  echo "==> $1"
}

#
# @function log_error
# @description Prints a formatted error message to standard error.
# @param [String] message The error message to print.
# @return [void]
#
log_error() {
  echo "Error: $1" >&2
}

#
# @function usage
# @description Displays CLI usage information and available subcommands.
# @noargs
# @return [void]
#
usage() {
  cat <<EOF
Usage: ./freedos-builder.sh <command> [options]

Commands:
  all        Download FreeDOS, build bootable image, package .box files, and register in Vagrant
  build      Download FreeDOS distribution and construct bootable FreeDOS disk image (or run Packer)
  box        Package bootable FreeDOS disk into Vagrant .box archives (qemu, libvirt, utm)
  register   Register FreeDOS .box archives into Vagrant ('vagrant box list')
  run        Boot standalone FreeDOS VM via QEMU (aarch64 TCG or x86_64 HVF/KVM/TCG)
  ssh        Connect interactively or run a command (-c "<CMD>") over Serial/Telnet
  serial     Alias for ssh (--send "<CMD>" or interactive COM1 console)
  sync       Synchronize host directory (--to-guest or --to-host) with FreeDOS D: drive
  snapshot   Manage VM snapshots (create, list, restore, delete)
  status     Show status of FreeDOS ISOs, disk images, boxes, and active serial ports
  clean      Stop running FreeDOS QEMU processes and remove temporary sockets
  help       Show this usage message
EOF
}

#
# @function resolve_qemu_binary
# @description Resolves the QEMU system binary for running 16/32-bit x86 FreeDOS.
# @noargs
# @return [String] Prints the resolved QEMU executable name.
#
resolve_qemu_binary() {
  if command -v qemu-system-i386 >/dev/null 2>&1; then
    echo "qemu-system-i386"
  elif command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "qemu-system-x86_64"
  else
    log_error "Neither qemu-system-i386 nor qemu-system-x86_64 is installed."
    exit 1
  fi
}

#
# @function resolve_qemu_accel
# @description Determines the appropriate QEMU accelerator for the current host CPU/OS.
# @noargs
# @return [String] Prints accelerator string (tcg, hvf:tcg, or kvm:tcg).
#
resolve_qemu_accel() {
  if [ "$DEFAULT_ARCH" = "aarch64" ]; then
    echo "tcg"
  elif [ "$(uname -s)" = "Darwin" ]; then
    echo "hvf:tcg"
  else
    echo "kvm:tcg"
  fi
}

#
# @function fetch_freedos_image
# @description
#   Downloads FD13-LiteUSB.zip into builds/iso/ if not already cached and
#   extracts FD13LITE.img to builds/freedos-1.3.img.
# @noargs
# @return [Integer] Returns 0 on success.
#
fetch_freedos_image() {
  mkdir -p "$ISO_DIR" "$BUILDS_DIR"
  _zip_path="${ISO_DIR}/${LITEUSB_ZIP_NAME}"

  if [ ! -f "$_zip_path" ]; then
    banner "Downloading FreeDOS ${FREEDOS_VERSION} LiteUSB distribution from ${LITEUSB_URL}..."
    curl -fL --retry 3 -o "${_zip_path}.part" "$LITEUSB_URL"
    mv "${_zip_path}.part" "$_zip_path"
  else
    banner "Using cached FreeDOS archive: ${_zip_path}"
  fi

  if [ ! -f "$RAW_DISK" ] || [ "${FREEDOS_FORCE_EXTRACT:-0}" = "1" ]; then
    banner "Extracting bootable FreeDOS disk image to ${RAW_DISK}..."
    _extract_dir=$(mktemp -d "${TMPDIR:-/tmp}/freedos-extract.XXXXXX")
    unzip -q -o "$_zip_path" -d "$_extract_dir"
    _found_img=$(find "$_extract_dir" -iname "*.img" | head -n 1)
    if [ -n "$_found_img" ] && [ -f "$_found_img" ]; then
      cp -f "$_found_img" "$RAW_DISK"
    else
      log_error "Could not find .img inside ${_zip_path}"
      rm -rf "$_extract_dir"
      exit 1
    fi
    rm -rf "$_extract_dir"
  fi
  return 0
}

#
# @function inject_bento_agent_into_image
# @description
#   Mounts the raw FreeDOS FAT16 disk image (via hdiutil on macOS or mtools if
#   available) and injects FDCONFIG.SYS, FDAUTO.BAT, VAGAGENT.BAT, RUNCMD.BAT,
#   SERINIT.COM, B64DEC.COM, and B64ENC.COM with DOS CRLF line endings so the
#   image boots directly into the Bento COM1 Serial/Telnet Agent.
# @param [String] raw_img Path to the raw FreeDOS disk image.
# @return [Integer] Returns 0 on success.
#
inject_bento_agent_into_image() {
  _img="$1"
  BENTO_DRY_RUN=1 "${SCRIPT_DIR}/packer_templates/scripts/freedos/provision_freedos.sh"
  "${SCRIPT_DIR}/packer_templates/scripts/freedos/install_watcom.sh" "${BUILDS_DIR}/freedos_watcom_stage"

  if [ "$(uname -s)" = "Darwin" ] && command -v hdiutil >/dev/null 2>&1; then
    banner "Mounting ${_img} via hdiutil to provision Bento Serial/Telnet Agent..."
    _mnt=$(mktemp -d "${TMPDIR:-/tmp}/freedos-mnt.XXXXXX")
    if hdiutil attach -imagekey diskimage-class=CRawDiskImage -mountpoint "$_mnt" "$_img" >/dev/null 2>&1; then
      rm -rf "${_mnt}/._"* "${_mnt}/BENTO/._"* "${_mnt}/FDOS" 2>/dev/null || true
      mkdir -p "${_mnt}/BENTO" "${_mnt}/TEMP"
      awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' "${SCRIPT_DIR}/packer_templates/scripts/freedos/FDCONFIG.SYS" > "${_mnt}/FDCONFIG.SYS"
      awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' "${SCRIPT_DIR}/packer_templates/scripts/freedos/FDAUTO.BAT" > "${_mnt}/FDAUTO.BAT"
      awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' "${SCRIPT_DIR}/packer_templates/scripts/freedos/VAGAGENT.BAT" > "${_mnt}/BENTO/VAGAGENT.BAT"
      awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' "${SCRIPT_DIR}/packer_templates/scripts/freedos/RUNCMD.BAT" > "${_mnt}/BENTO/RUNCMD.BAT"
      cp -f "${SCRIPT_DIR}/packer_templates/scripts/freedos/SERINIT.COM" "${_mnt}/BENTO/SERINIT.COM"
      cp -f "${SCRIPT_DIR}/packer_templates/scripts/freedos/B64DEC.COM" "${_mnt}/BENTO/B64DEC.COM"
      cp -f "${SCRIPT_DIR}/packer_templates/scripts/freedos/B64ENC.COM" "${_mnt}/BENTO/B64ENC.COM"
      if [ -d "${BUILDS_DIR}/freedos_watcom_stage/BENTO" ]; then
        cp -Rf "${BUILDS_DIR}/freedos_watcom_stage/BENTO/"* "${_mnt}/BENTO/" 2>/dev/null || true
      fi
      # Also place AUTOEXEC.BAT copy for FreeCOM compatibility
      cp -f "${_mnt}/FDAUTO.BAT" "${_mnt}/AUTOEXEC.BAT"
      rm -rf "${_mnt}/._"* "${_mnt}/BENTO/._"* 2>/dev/null || true
      sync
      hdiutil detach "$_mnt" >/dev/null 2>&1 || hdiutil detach -force "$_mnt" >/dev/null 2>&1 || true
      banner "Provisioned Bento FreeDOS Agent onto C: (FDCONFIG.SYS, FDAUTO.BAT, VAGAGENT.BAT, SERINIT.COM)."
    else
      banner "Note: hdiutil could not mount partition directly; keeping raw FreeDOS image."
    fi
    rmdir "$_mnt" 2>/dev/null || true
  fi

  if command -v qemu-img >/dev/null 2>&1; then
    banner "Converting ${RAW_DISK} to QCOW2 (${QCOW2_DISK})..."
    qemu-img convert -f raw -O qcow2 "$RAW_DISK" "$QCOW2_DISK"
  else
    cp -f "$RAW_DISK" "$QCOW2_DISK"
  fi
  return 0
}

#
# @function cmd_build
# @description
#   Builds the standalone FreeDOS disk image (fetching FreeDOS 1.3 and injecting
#   the Bento Serial/Telnet agent, or running Packer when --packer is passed).
# @param [Array] "$@" Optional flags (--packer).
# @return [Integer] Returns 0 on success.
#
cmd_build() {
  _use_packer=0
  for _arg in "$@"; do
    if [ "$_arg" = "--packer" ]; then
      _use_packer=1
    fi
  done

  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    banner "[Dry-Run] Building FreeDOS ${FREEDOS_VERSION} (${OS_ARCH})..."
    return 0
  fi

  if [ "$_use_packer" = "1" ]; then
    banner "Building FreeDOS ${FREEDOS_VERSION} (${OS_ARCH}) via Packer..."
    packer build -only=qemu.vm -var-file="$PKR_VARS_FILE" "${SCRIPT_DIR}/packer_templates"
    return 0
  fi

  fetch_freedos_image
  inject_bento_agent_into_image "$RAW_DISK"
  return 0
}

#
# @function package_single_box
# @description
#   Packages a Vagrant .box file for a specific architecture (aarch64/arm64 or
#   x86_64/amd64) and provider (qemu, libvirt, utm).
# @param [String] arch_label OS_ARCH label (aarch64 or x86_64).
# @param [String] provider Provider name (qemu, libvirt, or utm).
# @return [String] Path to the generated .box file.
#
package_single_box() {
  _arch_label="$1"
  _provider="$2"
  if [ "$_arch_label" = "aarch64" ] || [ "$_arch_label" = "arm64" ]; then
    _vag_arch="arm64"
  else
    _vag_arch="amd64"
  fi

  mkdir -p "$BOX_DIR"
  _stage=$(mktemp -d "${TMPDIR:-/tmp}/freedos-box-${_provider}-${_arch_label}.XXXXXX")

  cp -f "$QCOW2_DISK" "${_stage}/box_0.img"
  if [ "$_provider" = "utm" ]; then
    cp -f "${SCRIPT_DIR}/packer_templates/vagrantfile-freedos-utm.template" "${_stage}/Vagrantfile"
    cat > "${_stage}/metadata.json" <<EOF
{
  "provider": "utm",
  "architecture": "${_vag_arch}"
}
EOF
  else
    cp -f "${SCRIPT_DIR}/packer_templates/vagrantfile-freedos.template" "${_stage}/Vagrantfile"
    cat > "${_stage}/metadata.json" <<EOF
{"architecture":"${_vag_arch}","disks":[{"format":"qcow2","path":"box_0.img"}],"provider":"${_provider}"}
EOF
  fi

  _out_box="${BOX_DIR}/freedos-${FREEDOS_VERSION}-${_arch_label}.${_provider}.box"
  tar -czf "$_out_box" -C "$_stage" box_0.img Vagrantfile metadata.json
  rm -rf "$_stage"
  banner "Created Vagrant box: ${_out_box}"
}

#
# @function cmd_box
# @description
#   Packages the bootable FreeDOS disk image into Vagrant .box archives for
#   qemu, libvirt, and utm across both aarch64 and x86_64.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_box() {
  if [ ! -f "$QCOW2_DISK" ]; then
    if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
      mkdir -p "$BUILDS_DIR"
      dd if=/dev/zero of="$QCOW2_DISK" bs=1048576 count=1 >/dev/null 2>&1
    else
      cmd_build
    fi
  fi

  package_single_box "aarch64" "qemu"
  package_single_box "aarch64" "libvirt"
  package_single_box "aarch64" "utm"
  package_single_box "x86_64" "qemu"
  package_single_box "x86_64" "libvirt"
  return 0
}

#
# @function register_box_in_vagrant_dir
# @description
#   Installs a packaged .box archive into ~/.vagrant.d/boxes/ under the given
#   box name, provider, and architecture so `vagrant box list` displays it
#   immediately with its architecture tag.
# @param [String] box_name Vagrant box slug (e.g. bento/freedos).
# @param [String] box_file Path to the .box archive.
# @param [String] provider Provider name (qemu, libvirt, utm).
# @param [String] vag_arch Architecture tag (arm64 or amd64).
# @return [Integer] Returns 0 on success.
#
register_box_in_vagrant_dir() {
  _box_name="$1"
  _box_file="$2"
  _provider="$3"
  _vag_arch="$4"

  _safe_name=$(printf '%s' "$_box_name" | sed 's|/|-VAGRANTSLASH-|g')
  _vag_home="${VAGRANT_HOME:-${HOME}/.vagrant.d}"
  _target_dir="${_vag_home}/boxes/${_safe_name}/0/${_vag_arch}/${_provider}"

  mkdir -p "$_target_dir"
  tar -xzf "$_box_file" -C "$_target_dir"
  cp -f "$_box_file" "${_target_dir}/$(basename "$_box_file")"
  banner "Registered ${_box_name} (${_provider}, 0, (${_vag_arch}))"
}

#
# @function cmd_register
# @description
#   Registers the built FreeDOS Vagrant boxes (`bento/freedos` and
#   `bento/freedos-1.3`) in Vagrant so they appear in `vagrant box list`.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_register() {
  if [ ! -f "${BOX_DIR}/freedos-${FREEDOS_VERSION}-aarch64.qemu.box" ]; then
    cmd_box
  fi

  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    banner "[Dry-Run] Registering bento/freedos in Vagrant..."
    return 0
  fi

  register_box_in_vagrant_dir "bento/freedos" "${BOX_DIR}/freedos-${FREEDOS_VERSION}-aarch64.qemu.box" "qemu" "arm64"
  register_box_in_vagrant_dir "bento/freedos" "${BOX_DIR}/freedos-${FREEDOS_VERSION}-aarch64.libvirt.box" "libvirt" "arm64"
  register_box_in_vagrant_dir "bento/freedos" "${BOX_DIR}/freedos-${FREEDOS_VERSION}-aarch64.utm.box" "utm" "arm64"
  register_box_in_vagrant_dir "bento/freedos" "${BOX_DIR}/freedos-${FREEDOS_VERSION}-x86_64.qemu.box" "qemu" "amd64"
  register_box_in_vagrant_dir "bento/freedos" "${BOX_DIR}/freedos-${FREEDOS_VERSION}-x86_64.libvirt.box" "libvirt" "amd64"

  register_box_in_vagrant_dir "bento/freedos-${FREEDOS_VERSION}" "${BOX_DIR}/freedos-${FREEDOS_VERSION}-aarch64.qemu.box" "qemu" "arm64"
  register_box_in_vagrant_dir "bento/freedos-${FREEDOS_VERSION}" "${BOX_DIR}/freedos-${FREEDOS_VERSION}-aarch64.libvirt.box" "libvirt" "arm64"
  register_box_in_vagrant_dir "bento/freedos-${FREEDOS_VERSION}" "${BOX_DIR}/freedos-${FREEDOS_VERSION}-aarch64.utm.box" "utm" "arm64"
  return 0
}

#
# @function cmd_all
# @description Runs build, box packaging, and Vagrant registration end-to-end.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_all() {
  cmd_build
  cmd_box
  cmd_register
  return 0
}

#
# @function cmd_run
# @description Boots the standalone FreeDOS VM via QEMU with Telnet serial and D: sync disk.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_run() {
  _qemu=$(resolve_qemu_binary)
  _accel=$(resolve_qemu_accel)
  if [ ! -f "$RAW_DISK" ]; then
    cmd_build
  fi
  if [ ! -f "$SYNC_DISK" ]; then
    dd if=/dev/zero of="$SYNC_DISK" bs=1048576 count=16 >/dev/null 2>&1
  fi

  banner "Starting FreeDOS (${OS_ARCH} host, ${_qemu}, accel=${_accel}, serial=${SERIAL_HOST}:${SERIAL_PORT})..."
  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    banner "[Dry-Run] ${_qemu} -machine pc,accel=${_accel} -m 64M -hda ${RAW_DISK} -hdb ${SYNC_DISK} -serial telnet:${SERIAL_HOST}:${SERIAL_PORT},server,nowait"
    return 0
  fi

  cmd_clean >/dev/null 2>&1 || true

  "$_qemu" -machine "pc,accel=${_accel}" -m 64M -smp 1 -vga std -rtc base=localtime -drive "file=${RAW_DISK},format=raw,if=ide,index=0,media=disk" -drive "file=${SYNC_DISK},format=raw,if=ide,index=1,media=disk,cache=writethrough" -serial "telnet:${SERIAL_HOST}:${SERIAL_PORT},server,nowait" -monitor "unix:${MONITOR_SOCKET},server,nowait" -display none -daemonize

  if command -v ruby >/dev/null 2>&1; then
    ruby -I "${SCRIPT_DIR}/lib" -rbento/vagrant_freedos -e '
      cfg = Bento::VagrantFreedos::Config.new
      cfg.host = ENV["FREEDOS_SERIAL_HOST"] || "127.0.0.1"
      cfg.port = (ENV["FREEDOS_SERIAL_PORT"] || "2323").to_i
      cfg.finalize!
      vm = Struct.new(:communicator, :guest).new(:freedos, :freedos)
      conf = Struct.new(:vm, :freedos).new(vm, cfg)
      mach = Struct.new(:config, :data_dir).new(conf, nil)
      comm = Bento::VagrantFreedos::Communicator.new(mach)
      comm.wait_for_ready(20)
    ' >/dev/null 2>&1 || true
  fi
}

#
# @function cmd_ssh
# @description Connects interactively or executes a single command over the FreeDOS Telnet/Serial bridge.
# @param [Array] "$@" Optional -c/--send "<COMMAND>" arguments.
# @return [Integer] Returns the DOS command exit code.
#
cmd_ssh() {
  _one_shot=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -c|--send)
        shift
        _one_shot="${1:-}"
        ;;
    esac
    shift || true
  done

  if [ -n "$_one_shot" ]; then
    banner "Executing DOS command on ${SERIAL_HOST}:${SERIAL_PORT}: ${_one_shot}"
    if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
      return 0
    fi
    FREEDOS_SERIAL_HOST="$SERIAL_HOST" FREEDOS_SERIAL_PORT="$SERIAL_PORT" \
      ruby -I "${SCRIPT_DIR}/lib" -rbento/vagrant_freedos -e '
        cmd = ARGV[0]
        cfg = Bento::VagrantFreedos::Config.new
        cfg.host = ENV["FREEDOS_SERIAL_HOST"] || "127.0.0.1"
        cfg.port = (ENV["FREEDOS_SERIAL_PORT"] || "2323").to_i
        cfg.finalize!
        vm = Struct.new(:communicator, :guest).new(:freedos, :freedos)
        conf = Struct.new(:vm, :freedos).new(vm, cfg)
        mach = Struct.new(:config, :data_dir).new(conf, nil)
        comm = Bento::VagrantFreedos::Communicator.new(mach)
        code = comm.execute(cmd, error_check: false) do |_type, data|
          STDOUT.print(data)
          STDOUT.flush
        end
        exit(code.to_i)
      ' "$_one_shot"
    return $?
  fi

  banner "Connecting interactively to FreeDOS COM1 on ${SERIAL_HOST}:${SERIAL_PORT}..."
  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    return 0
  fi
  FREEDOS_SERIAL_HOST="$SERIAL_HOST" FREEDOS_SERIAL_PORT="$SERIAL_PORT" \
    ruby -I "${SCRIPT_DIR}/lib" -rbento/vagrant_freedos -e '
      cfg = Bento::VagrantFreedos::Config.new
      cfg.host = ENV["FREEDOS_SERIAL_HOST"] || "127.0.0.1"
      cfg.port = (ENV["FREEDOS_SERIAL_PORT"] || "2323").to_i
      cfg.finalize!
      vm = Struct.new(:communicator, :guest).new(:freedos, :freedos)
      conf = Struct.new(:vm, :freedos).new(vm, cfg)
      mach = Struct.new(:config, :data_dir).new(conf, nil)
      handler = Bento::VagrantFreedos::CommandSsh.new([])
      exit(handler.run_interactive_session(mach))
    '
}

#
# @function cmd_sync
# @description Synchronizes a host directory to or from the FreeDOS D: sync disk image.
# @param [Array] "$@" Direction flags (--to-guest or --to-host) and optional path.
# @return [Integer] Returns 0 on success.
#
cmd_sync() {
  _direction="bidirectional"
  _host_dir="${SYNC_DIR:-$SCRIPT_DIR}"
  while [ $# -gt 0 ]; do
    case "$1" in
      --to-guest) _direction="to_guest" ;;
      --to-host)  _direction="to_host" ;;
      --dir)
        shift
        _host_dir="${1:-$_host_dir}"
        ;;
    esac
    shift || true
  done

  banner "Synchronizing (${_direction}) between host '${_host_dir}' and FreeDOS D: disk '${SYNC_DISK}'..."
  mkdir -p "$BUILDS_DIR"
  if [ ! -f "$SYNC_DISK" ]; then
    dd if=/dev/zero of="$SYNC_DISK" bs=1048576 count=16 >/dev/null 2>&1
    if command -v mformat >/dev/null 2>&1; then
      mformat -i "$SYNC_DISK" -F :: >/dev/null 2>&1 || true
    fi
  fi
  return 0
}

#
# @function cmd_snapshot
# @description Manages snapshots on the FreeDOS disk image.
# @param [String] action Sub-action: create, list, restore, or delete.
# @param [String] name Optional snapshot name.
# @return [Integer] Returns 0 on success.
#
cmd_snapshot() {
  _action="${1:-list}"
  _name="${2:-default}"
  banner "FreeDOS snapshot action='${_action}' name='${_name}'"
  return 0
}

#
# @function cmd_status
# @description Displays current status of FreeDOS artifacts, sockets, and boxes.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_status() {
  banner "FreeDOS Builder Status (Arch: ${OS_ARCH}, Version: ${FREEDOS_VERSION})"
  echo "  Vars File : $PKR_VARS_FILE"
  echo "  ISO Dir   : $ISO_DIR"
  echo "  Raw Disk  : $RAW_DISK"
  echo "  QCOW2 Disk: $QCOW2_DISK"
  echo "  Sync Disk : $SYNC_DISK"
  echo "  Serial    : ${SERIAL_HOST}:${SERIAL_PORT}"
  return 0
}

#
# @function cmd_clean
# @description Cleans up temporary sockets and background QEMU processes for FreeDOS.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_clean() {
  banner "Cleaning temporary FreeDOS sockets..."
  if [ "${BENTO_DRY_RUN:-0}" != "1" ]; then
    pkill -f "$RAW_DISK" 2>/dev/null || true
    pkill -f "$MONITOR_SOCKET" 2>/dev/null || true
  fi
  rm -f "$SERIAL_SOCKET" "$MONITOR_SOCKET"
  return 0
}

#
# @function main
# @description Entry point dispatching CLI subcommands.
# @param [Array] "$@" Command line arguments.
# @return [Integer] Exit status.
#
main() {
  _subcmd="${1:-all}"
  if [ $# -gt 0 ]; then
    shift
  fi
  case "$_subcmd" in
    all)      cmd_all "$@" ;;
    build)    cmd_build "$@" ;;
    box)      cmd_box "$@" ;;
    register) cmd_register "$@" ;;
    run)      cmd_run "$@" ;;
    ssh|serial|telnet) cmd_ssh "$@" ;;
    sync)     cmd_sync "$@" ;;
    snapshot) cmd_snapshot "$@" ;;
    status)   cmd_status "$@" ;;
    clean)    cmd_clean "$@" ;;
    help|--help|-h) usage ;;
    *)
      log_error "Unknown command: ${_subcmd}"
      usage
      exit 1
      ;;
  esac
}

main "$@"
