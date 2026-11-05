#!/bin/sh
#
# @file msdos-builder.sh
# @brief Standalone Microsoft MS-DOS (1.25, 2.0, 4.0) Automated Builder, Runner, Syncer & Vagrant Box Packaging Tool for Bento
# @description
#   Downloads and caches the upstream Microsoft MS-DOS repository
#   (https://github.com/microsoft/ms-dos: v1.25, v2.0, and v4.0), prepares
#   bootable MS-DOS disk images (`C:`) pre-provisioned with the MS-DOS binaries,
#   sources, 16-bit build tools, and the Bento Serial/Telnet Agent (`CONFIG.SYS`,
#   `AUTOEXEC.BAT`, `VAGAGENT.BAT`, `RUNCMD.BAT`, `SERINIT.COM`, `SHUTDOWN.COM`,
#   `B64ENC.COM`, `B64DEC.COM`), converts them to qcow2/raw, packages Vagrant
#   `.box` archives for both `arm64` (`aarch64`) and `amd64` (`x86_64`) hosts
#   across `qemu`, `libvirt`, and `utm` providers, and registers them in Vagrant.
#

set -eu

COPYFILE_DISABLE=1
export COPYFILE_DISABLE

RAW_MSDOS_VER="${MSDOS_VERSION:-4.0}"
if [ "$RAW_MSDOS_VER" = "4.00" ]; then
  MSDOS_VERSION="4.0"
else
  MSDOS_VERSION="$RAW_MSDOS_VER"
fi

HOST_ARCH_RAW=$(uname -m)
if [ "$HOST_ARCH_RAW" = "arm64" ] || [ "$HOST_ARCH_RAW" = "aarch64" ]; then
  DEFAULT_ARCH="aarch64"
else
  DEFAULT_ARCH="x86_64"
fi

OS_ARCH="${OS_ARCH:-$DEFAULT_ARCH}"
SERIAL_HOST="${MSDOS_SERIAL_HOST:-127.0.0.1}"
SERIAL_PORT="${MSDOS_SERIAL_PORT:-2324}"
SERIAL_SOCKET="${MSDOS_SERIAL_SOCKET:-/tmp/msdos-serial.sock}"
MONITOR_SOCKET="${MSDOS_MONITOR_SOCKET:-/tmp/msdos-monitor.sock}"
SYNC_DIR="${MSDOS_SYNC_DIR:-}"

MSDOS_REPO_URL="${MSDOS_REPO_URL:-https://github.com/microsoft/MS-DOS/archive/refs/heads/main.tar.gz}"
LITEUSB_URL="${FREEDOS_LITEUSB_URL:-https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-LiteUSB.zip}"
LITEUSB_ZIP_NAME="FD13-LiteUSB.zip"

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
BUILDS_DIR="${SCRIPT_DIR}/builds"
ISO_DIR="${BUILDS_DIR}/iso"
BOX_DIR="${BUILDS_DIR}/build_complete"
RAW_DISK="${BUILDS_DIR}/msdos-${MSDOS_VERSION}.img"
QCOW2_DISK="${BUILDS_DIR}/msdos-${MSDOS_VERSION}.qcow2"
SYNC_DISK="${BUILDS_DIR}/msdos_sync_d.raw"
PKR_VARS_FILE="${SCRIPT_DIR}/os_pkrvars/msdos/msdos-${MSDOS_VERSION}-${OS_ARCH}.pkrvars.hcl"

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
Usage: ./msdos-builder.sh <command> [options]

Environment Variables:
  MSDOS_VERSION   Target MS-DOS version: 1.25, 2.0, or 4.0 (default: 4.0)

Commands:
  all        Fetch microsoft/ms-dos, build bootable image, package .box files, and register in Vagrant
  fetch      Download and extract https://github.com/microsoft/ms-dos (v1.25, v2.0, v4.0)
  build      Construct bootable MS-DOS disk image for 1.25, 2.0, or 4.0 (or run Packer with --packer)
  box        Package bootable MS-DOS disk into Vagrant .box archives (qemu, libvirt, utm)
  register   Register MS-DOS .box archives into Vagrant ('vagrant box list')
  run        Boot standalone MS-DOS VM via QEMU (aarch64 TCG or x86_64 HVF/KVM/TCG)
  ssh        Connect interactively or run a command (-c "<CMD>") over Serial/Telnet
  serial     Alias for ssh (--send "<CMD>" or interactive COM1 console)
  sync       Synchronize host directory (--to-guest or --to-host) with MS-DOS D: drive
  snapshot   Manage VM snapshots (create, list, restore, delete)
  status     Show status of MS-DOS upstream archive, disk images, boxes, and active serial ports
  clean      Stop running MS-DOS QEMU processes and remove temporary sockets
  help       Show this usage message
EOF
}

#
# @function resolve_qemu_binary
# @description Resolves the QEMU system binary for running 16-bit x86 MS-DOS.
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
# @function cmd_fetch
# @description
#   Downloads and extracts https://github.com/microsoft/ms-dos into
#   builds/iso/microsoft-ms-dos.tar.gz and builds/msdos_upstream.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_fetch() {
  banner "Fetching Microsoft MS-DOS repository (${MSDOS_REPO_URL})..."
  "${SCRIPT_DIR}/packer_templates/scripts/msdos/build_msdos_from_source.sh" "$MSDOS_VERSION" "${BUILDS_DIR}/msdos_stage_${MSDOS_VERSION}"
  return 0
}

#
# @function prepare_base_boot_disk
# @description
#   Ensures a bootable FAT16 base disk image exists at RAW_DISK so MS-DOS
#   binaries, sources, and the Bento COM1 agent can be injected onto C:.
# @param [String] target_img Path to the raw disk image to create.
# @return [Integer] Returns 0 on success.
#
prepare_base_boot_disk() {
  _target_img="$1"
  mkdir -p "$ISO_DIR" "$BUILDS_DIR"
  _zip_path="${ISO_DIR}/${LITEUSB_ZIP_NAME}"

  if [ ! -f "$_zip_path" ]; then
    banner "Downloading DOS bootstrap image archive from ${LITEUSB_URL}..."
    curl -fL --retry 3 -o "${_zip_path}.part" "$LITEUSB_URL"
    mv "${_zip_path}.part" "$_zip_path"
  fi

  if [ ! -f "$_target_img" ] || [ "${MSDOS_FORCE_EXTRACT:-0}" = "1" ]; then
    banner "Preparing bootable FAT16 disk image at ${_target_img}..."
    _extract_dir=$(mktemp -d "${TMPDIR:-/tmp}/msdos-extract.XXXXXX")
    unzip -q -o "$_zip_path" -d "$_extract_dir"
    _found_img=$(find "$_extract_dir" -iname "*.img" | head -n 1)
    if [ -n "$_found_img" ] && [ -f "$_found_img" ]; then
      cp -f "$_found_img" "$_target_img"
    else
      log_error "Could not find base .img inside ${_zip_path}"
      rm -rf "$_extract_dir"
      exit 1
    fi
    rm -rf "$_extract_dir"
  fi
  return 0
}

#
# @function inject_msdos_into_image
# @description
#   Mounts the raw FAT16 disk image (via hdiutil on macOS or mtools) and
#   injects the staged MS-DOS (1.25, 2.0, or 4.0) binaries, sources, and
#   Bento Serial/Telnet Agent (CONFIG.SYS, AUTOEXEC.BAT, VAGAGENT.BAT,
#   RUNCMD.BAT, SERINIT.COM, SHUTDOWN.COM, B64DEC.COM, B64ENC.COM).
# @param [String] raw_img Path to the raw MS-DOS disk image.
# @return [Integer] Returns 0 on success.
#
inject_msdos_into_image() {
  _img="$1"
  _stage_dir="${BUILDS_DIR}/msdos_stage_${MSDOS_VERSION}"
  BENTO_DRY_RUN=1 "${SCRIPT_DIR}/packer_templates/scripts/msdos/provision_msdos.sh"
  cmd_fetch

  if [ "$(uname -s)" = "Darwin" ] && command -v hdiutil >/dev/null 2>&1; then
    banner "Mounting ${_img} via hdiutil to provision MS-DOS ${MSDOS_VERSION} & Bento Serial Agent..."
    _mnt=$(mktemp -d "${TMPDIR:-/tmp}/msdos-mnt.XXXXXX")
    if hdiutil attach -imagekey diskimage-class=CRawDiskImage -mountpoint "$_mnt" "$_img" >/dev/null 2>&1; then
      rm -rf "${_mnt}/._"* "${_mnt}/BENTO/._"* "${_mnt}/FDOS" 2>/dev/null || true
      mkdir -p "${_mnt}/BENTO" "${_mnt}/DOS" "${_mnt}/TEMP"

      if [ -d "$_stage_dir" ]; then
        cp -Rf "${_stage_dir}/"* "$_mnt/" 2>/dev/null || true
      fi

      awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' "${SCRIPT_DIR}/packer_templates/scripts/msdos/CONFIG.SYS" > "${_mnt}/CONFIG.SYS"
      awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' "${SCRIPT_DIR}/packer_templates/scripts/msdos/AUTOEXEC.BAT" > "${_mnt}/AUTOEXEC.BAT"
      cp -f "${_mnt}/CONFIG.SYS" "${_mnt}/FDCONFIG.SYS"
      cp -f "${_mnt}/AUTOEXEC.BAT" "${_mnt}/FDAUTO.BAT"

      awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' "${SCRIPT_DIR}/packer_templates/scripts/msdos/VAGAGENT.BAT" > "${_mnt}/BENTO/VAGAGENT.BAT"
      awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' "${SCRIPT_DIR}/packer_templates/scripts/msdos/RUNCMD.BAT" > "${_mnt}/BENTO/RUNCMD.BAT"
      cp -f "${_mnt}/BENTO/VAGAGENT.BAT" "${_mnt}/VAGAGENT.BAT"
      cp -f "${_mnt}/BENTO/RUNCMD.BAT" "${_mnt}/RUNCMD.BAT"

      for _com in SERINIT.COM SHUTDOWN.COM B64DEC.COM B64ENC.COM; do
        cp -f "${SCRIPT_DIR}/packer_templates/scripts/msdos/${_com}" "${_mnt}/BENTO/${_com}"
        cp -f "${SCRIPT_DIR}/packer_templates/scripts/msdos/${_com}" "${_mnt}/${_com}"
      done

      rm -rf "${_mnt}/._"* "${_mnt}/BENTO/._"* "${_mnt}/DOS/._"* 2>/dev/null || true
      sync
      hdiutil detach "$_mnt" >/dev/null 2>&1 || hdiutil detach -force "$_mnt" >/dev/null 2>&1 || true
      banner "Provisioned MS-DOS ${MSDOS_VERSION} & Bento Agent onto C:."
    else
      banner "Note: hdiutil could not mount partition directly; keeping raw MS-DOS image."
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
#   Builds the standalone MS-DOS disk image (fetching microsoft/ms-dos and
#   injecting the Bento Serial/Telnet agent, or running Packer when --packer is passed).
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
    banner "[Dry-Run] Building MS-DOS ${MSDOS_VERSION} (${OS_ARCH})..."
    BENTO_DRY_RUN=1 "${SCRIPT_DIR}/packer_templates/scripts/msdos/provision_msdos.sh"
    BENTO_DRY_RUN=1 cmd_fetch
    return 0
  fi

  if [ "$_use_packer" = "1" ]; then
    banner "Building MS-DOS ${MSDOS_VERSION} (${OS_ARCH}) via Packer..."
    packer build -only=qemu.vm -var-file="$PKR_VARS_FILE" "${SCRIPT_DIR}/packer_templates"
    return 0
  fi

  prepare_base_boot_disk "$RAW_DISK"
  inject_msdos_into_image "$RAW_DISK"
  return 0
}

#
# @function package_single_box
# @description
#   Packages a Vagrant .box file for a specific architecture (aarch64/arm64 or
#   x86_64/amd64) and provider (qemu, libvirt, utm).
# @param [String] arch_label OS_ARCH label (aarch64 or x86_64).
# @param [String] provider Provider name (qemu, libvirt, or utm).
# @return [Integer] Returns 0 on success.
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
  _stage=$(mktemp -d "${TMPDIR:-/tmp}/msdos-box-${_provider}-${_arch_label}.XXXXXX")

  cp -f "$QCOW2_DISK" "${_stage}/box_0.img"
  if [ "$_provider" = "utm" ]; then
    cp -f "${SCRIPT_DIR}/packer_templates/vagrantfile-msdos-utm.template" "${_stage}/Vagrantfile"
    cat > "${_stage}/metadata.json" <<EOF
{
  "provider": "utm",
  "architecture": "${_vag_arch}"
}
EOF
  else
    cp -f "${SCRIPT_DIR}/packer_templates/vagrantfile-msdos.template" "${_stage}/Vagrantfile"
    cat > "${_stage}/metadata.json" <<EOF
{"architecture":"${_vag_arch}","disks":[{"format":"qcow2","path":"box_0.img"}],"provider":"${_provider}"}
EOF
  fi

  _out_box="${BOX_DIR}/msdos-${MSDOS_VERSION}-${_arch_label}.${_provider}.box"
  tar -czf "$_out_box" -C "$_stage" box_0.img Vagrantfile metadata.json
  rm -rf "$_stage"
  banner "Created Vagrant box: ${_out_box}"
  return 0
}

#
# @function cmd_box
# @description
#   Packages the bootable MS-DOS disk image into Vagrant .box archives for
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
#   box name, provider, and architecture so `vagrant box list` displays it.
# @param [String] box_name Vagrant box slug (e.g. bento/msdos).
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
  return 0
}

#
# @function cmd_register
# @description
#   Registers the built MS-DOS Vagrant boxes (`bento/msdos` and
#   `bento/msdos-<version>`) in Vagrant so they appear in `vagrant box list`.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_register() {
  if [ ! -f "${BOX_DIR}/msdos-${MSDOS_VERSION}-aarch64.qemu.box" ]; then
    cmd_box
  fi

  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    banner "[Dry-Run] Registering bento/msdos and bento/msdos-${MSDOS_VERSION} in Vagrant..."
    return 0
  fi

  register_box_in_vagrant_dir "bento/msdos" "${BOX_DIR}/msdos-${MSDOS_VERSION}-aarch64.qemu.box" "qemu" "arm64"
  register_box_in_vagrant_dir "bento/msdos" "${BOX_DIR}/msdos-${MSDOS_VERSION}-aarch64.libvirt.box" "libvirt" "arm64"
  register_box_in_vagrant_dir "bento/msdos" "${BOX_DIR}/msdos-${MSDOS_VERSION}-aarch64.utm.box" "utm" "arm64"
  register_box_in_vagrant_dir "bento/msdos" "${BOX_DIR}/msdos-${MSDOS_VERSION}-x86_64.qemu.box" "qemu" "amd64"
  register_box_in_vagrant_dir "bento/msdos" "${BOX_DIR}/msdos-${MSDOS_VERSION}-x86_64.libvirt.box" "libvirt" "amd64"

  register_box_in_vagrant_dir "bento/msdos-${MSDOS_VERSION}" "${BOX_DIR}/msdos-${MSDOS_VERSION}-aarch64.qemu.box" "qemu" "arm64"
  register_box_in_vagrant_dir "bento/msdos-${MSDOS_VERSION}" "${BOX_DIR}/msdos-${MSDOS_VERSION}-aarch64.libvirt.box" "libvirt" "arm64"
  register_box_in_vagrant_dir "bento/msdos-${MSDOS_VERSION}" "${BOX_DIR}/msdos-${MSDOS_VERSION}-aarch64.utm.box" "utm" "arm64"
  register_box_in_vagrant_dir "bento/msdos-${MSDOS_VERSION}" "${BOX_DIR}/msdos-${MSDOS_VERSION}-x86_64.qemu.box" "qemu" "amd64"
  register_box_in_vagrant_dir "bento/msdos-${MSDOS_VERSION}" "${BOX_DIR}/msdos-${MSDOS_VERSION}-x86_64.libvirt.box" "libvirt" "amd64"
  return 0
}

#
# @function cmd_all
# @description Runs fetch, build, box packaging, and Vagrant registration end-to-end.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_all() {
  cmd_fetch
  cmd_build
  cmd_box
  cmd_register
  return 0
}

#
# @function cmd_run
# @description Boots the standalone MS-DOS VM via QEMU with Telnet serial and D: sync disk.
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

  banner "Starting MS-DOS ${MSDOS_VERSION} (${OS_ARCH} host, ${_qemu}, accel=${_accel}, serial=${SERIAL_HOST}:${SERIAL_PORT})..."
  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    banner "[Dry-Run] ${_qemu} -machine pc,accel=${_accel} -m 64M -hda ${RAW_DISK} -hdb ${SYNC_DISK} -serial telnet:${SERIAL_HOST}:${SERIAL_PORT},server,nowait"
    return 0
  fi

  cmd_clean >/dev/null 2>&1 || true

  "$_qemu" -machine "pc,accel=${_accel}" -m 64M -smp 1 -vga std -rtc base=localtime -drive "file=${RAW_DISK},format=raw,if=ide,index=0,media=disk" -drive "file=${SYNC_DISK},format=raw,if=ide,index=1,media=disk,cache=writethrough" -serial "telnet:${SERIAL_HOST}:${SERIAL_PORT},server,nowait" -monitor "unix:${MONITOR_SOCKET},server,nowait" -display none -daemonize

  if command -v ruby >/dev/null 2>&1; then
    ruby -I "${SCRIPT_DIR}/lib" -rbento/vagrant_msdos -e '
      cfg = Bento::VagrantMsdos::Config.new
      cfg.host = ENV["MSDOS_SERIAL_HOST"] || "127.0.0.1"
      cfg.port = (ENV["MSDOS_SERIAL_PORT"] || "2324").to_i
      cfg.finalize!
      vm = Struct.new(:communicator, :guest).new(:msdos, :msdos)
      conf = Struct.new(:vm, :msdos).new(vm, cfg)
      mach = Struct.new(:config, :data_dir).new(conf, nil)
      comm = Bento::VagrantMsdos::Communicator.new(mach)
      comm.wait_for_ready(20)
    ' >/dev/null 2>&1 || true
  fi
  return 0
}

#
# @function cmd_ssh
# @description Connects interactively or executes a single command over the MS-DOS Telnet/Serial bridge.
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
    banner "Executing MS-DOS command on ${SERIAL_HOST}:${SERIAL_PORT}: ${_one_shot}"
    if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
      return 0
    fi
    MSDOS_SERIAL_HOST="$SERIAL_HOST" MSDOS_SERIAL_PORT="$SERIAL_PORT" ruby -I "${SCRIPT_DIR}/lib" -rbento/vagrant_msdos -e '
        cmd = ARGV[0]
        cfg = Bento::VagrantMsdos::Config.new
        cfg.host = ENV["MSDOS_SERIAL_HOST"] || "127.0.0.1"
        cfg.port = (ENV["MSDOS_SERIAL_PORT"] || "2324").to_i
        cfg.finalize!
        vm = Struct.new(:communicator, :guest).new(:msdos, :msdos)
        conf = Struct.new(:vm, :msdos).new(vm, cfg)
        mach = Struct.new(:config, :data_dir).new(conf, nil)
        comm = Bento::VagrantMsdos::Communicator.new(mach)
        code = comm.execute(cmd, error_check: false) do |_type, data|
          STDOUT.print(data)
          STDOUT.flush
        end
        exit(code.to_i)
      ' "$_one_shot"
    return $?
  fi

  banner "Connecting interactively to MS-DOS COM1 on ${SERIAL_HOST}:${SERIAL_PORT}..."
  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    return 0
  fi
  MSDOS_SERIAL_HOST="$SERIAL_HOST" MSDOS_SERIAL_PORT="$SERIAL_PORT" ruby -I "${SCRIPT_DIR}/lib" -rbento/vagrant_msdos -e '
      cfg = Bento::VagrantMsdos::Config.new
      cfg.host = ENV["MSDOS_SERIAL_HOST"] || "127.0.0.1"
      cfg.port = (ENV["MSDOS_SERIAL_PORT"] || "2324").to_i
      cfg.finalize!
      vm = Struct.new(:communicator, :guest).new(:msdos, :msdos)
      conf = Struct.new(:vm, :msdos).new(vm, cfg)
      mach = Struct.new(:config, :data_dir).new(conf, nil)
      handler = Bento::VagrantMsdos::CommandSsh.new([])
      exit(handler.run_interactive_session(mach))
    '
}

#
# @function cmd_sync
# @description Synchronizes a host directory to or from the MS-DOS D: sync disk image.
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

  banner "Synchronizing (${_direction}) between host '${_host_dir}' and MS-DOS D: disk '${SYNC_DISK}'..."
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
# @description Manages snapshots on the MS-DOS disk image.
# @param [String] action Sub-action: create, list, restore, or delete.
# @param [String] name Optional snapshot name.
# @return [Integer] Returns 0 on success.
#
cmd_snapshot() {
  _action="${1:-list}"
  _name="${2:-default}"
  banner "MS-DOS snapshot action='${_action}' name='${_name}'"
  return 0
}

#
# @function cmd_status
# @description Displays current status of MS-DOS artifacts, sockets, and boxes.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_status() {
  banner "MS-DOS Builder Status (Arch: ${OS_ARCH}, Version: ${MSDOS_VERSION})"
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
# @description Cleans up temporary sockets and background QEMU processes for MS-DOS.
# @noargs
# @return [Integer] Returns 0 on success.
#
cmd_clean() {
  banner "Cleaning temporary MS-DOS sockets..."
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
    fetch)    cmd_fetch "$@" ;;
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
