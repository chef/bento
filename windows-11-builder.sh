#!/bin/sh
# ==============================================================================
# Windows 11 Automated Builder, Runner & Minimal Box Creation Tool for Bento
#
# Usage:
#   ./windows-11-builder.sh [COMMAND] [OPTIONS]
#
# Commands:
#   build          Build the Windows 11 box using Packer + auto-box compression (default)
#   box            Compress, sparsify, and package VM disk into minimal .box
#   register       Register built .box into local Vagrant inventory as bento/windows-11
#   run            Run the built VM / box directly with KVM, serial & networking
#   serial         Connect via serial to debug the running VM in real time
#   snapshot       Manage VM snapshots (create, list, restore, delete)
#   status         Show status of ISOs, build files, and running processes
#   clean          Kill running VMs/Packer instances and clean temporary locks
#
# Options:
#   --provider     qemu | virtualbox (default: auto-detected based on KVM)
#   --arch         x86_64 | aarch64  (default: auto-detected host arch)
#   --iso          Path to Windows 11 ISO (default: auto-detected)
#   --headless     true | false (default: true)
#   --gui          Display GUI window for VM (shortcut for --headless false)
#   --debug        Enable Packer and hypervisor debug logging & display VM window
#   --step         Pause interactively after each Packer build step
#   --serial       Stream serial output to terminal during build
#   --watch        Watch live serial log streaming (for serial command)
#   --tail [N]     Display last N lines of serial log (default: 50)
#   --send <CMD>   Send command string to serial console
#   --create [N]   Create VM snapshot (default: snap_<timestamp>)
#   --restore <N>  Restore VM snapshot
#   --delete <N>   Delete VM snapshot
#   --list         List VM snapshots
#   --memory <MB>  Memory for runner in MB (default: 6144)
#   --cpus <N>     CPUs for runner (default: 4)
#   --vnc <PORT>   VNC display port for runner (default: none / headless)
# ==============================================================================
set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
cd "${SCRIPT_DIR}"

# Load .env if present
if [ -f "${SCRIPT_DIR}/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "${SCRIPT_DIR}/.env"
  set +a
fi

# Ensure storage directory is mounted, created, and writable with automatic fallback
ensure_storage_dir() {
  _target="$1"
  _fallback_sub="$2"

  case "${_target}" in
    /Volumes/*)
      _vol_name=$(printf '%s\n' "${_target}" | awk -F/ '{print $3}')
      if [ -n "${_vol_name}" ] && [ ! -d "/Volumes/${_vol_name}" ] && command -v hdiutil >/dev/null 2>&1; then
        for _bundle in \
          "${EXTERNAL_STATE_SPARSEBUNDLE:-}" \
          ${EXTERNAL_STORAGE_DIR:+"${EXTERNAL_STORAGE_DIR}/${_vol_name}.sparsebundle"} \
          "/Volumes/"*"/${_vol_name}.sparsebundle" \
          "${HOME}/${_vol_name}.sparsebundle"
        do
          if [ -n "${_bundle}" ] && [ -e "${_bundle}" ]; then
            hdiutil attach -nobrowse "${_bundle}" >/dev/null 2>&1 || true
            break
          fi
        done
      fi
      ;;
  esac

  if [ -n "${_target}" ] && mkdir -p "${_target}" 2>/dev/null && [ -w "${_target}" ]; then
    printf '%s\n' "${_target}"
    return 0
  fi

  if [ -n "${EXTERNAL_VAGRANT_DIR:-}" ] && [ -d "${EXTERNAL_VAGRANT_DIR}" ] && [ -w "${EXTERNAL_VAGRANT_DIR}" ]; then
    _fb="${EXTERNAL_VAGRANT_DIR}/${_fallback_sub}"
  elif [ -n "${EXTERNAL_STORAGE_DIR:-}" ] && [ -d "${EXTERNAL_STORAGE_DIR}/vagrant" ] && [ -w "${EXTERNAL_STORAGE_DIR}/vagrant" ]; then
    _fb="${EXTERNAL_STORAGE_DIR}/vagrant/${_fallback_sub}"
  else
    _fb="${SCRIPT_DIR}/builds/${_fallback_sub}"
  fi

  mkdir -p "${_fb}" 2>/dev/null || true
  printf '%s\n' "${_fb}"
}

BENTO_BUILD_FILES_DIR="$(ensure_storage_dir "${BENTO_BUILD_FILES_DIR:-}" "build_files")"
BENTO_BUILD_COMPLETE_DIR="$(ensure_storage_dir "${BENTO_BUILD_COMPLETE_DIR:-}" "build_complete")"
export BENTO_BUILD_FILES_DIR
export BENTO_BUILD_COMPLETE_DIR

# ANSI Colors
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_CYAN="\033[36m"

log_info()    { printf "%b==> [INFO]%b %s
" "${C_CYAN}${C_BOLD}" "${C_RESET}" "$*"; }
log_success() { printf "%b==> [SUCCESS]%b %s
" "${C_GREEN}${C_BOLD}" "${C_RESET}" "$*"; }
log_warn()    { printf "%b==> [WARN]%b %s
" "${C_YELLOW}${C_BOLD}" "${C_RESET}" "$*"; }
log_error()   { printf "%b==> [ERROR]%b %s
" "${C_RED}${C_BOLD}" "${C_RESET}" "$*" >&2; }
get_file_size() { stat -f %z "$1" 2>/dev/null || stat -c %s "$1" 2>/dev/null || wc -c < "$1" | tr -d ' '; }

# Default Parameters
COMMAND="build"
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) ARCH="x86_64" ;;
  aarch64|arm64) ARCH="aarch64" ;;
  *) log_error "Unsupported host architecture: ${ARCH}"; exit 1 ;;
esac

# Auto-detect hypervisor provider
if [ -z "${PROVIDER:-}" ]; then
  if [ -e "/dev/kvm" ] && [ -w "/dev/kvm" ]; then
    PROVIDER="qemu"
  elif command -v VBoxManage >/dev/null 2>&1; then
    PROVIDER="virtualbox"
  elif command -v "qemu-system-${ARCH}" >/dev/null 2>&1; then
    PROVIDER="qemu"
  else
    PROVIDER="qemu"
  fi
fi

HEADLESS="${HEADLESS:-}"
DEBUG_MODE="${DEBUG_MODE:-false}"
STEP_MODE="${STEP_MODE:-false}"
STREAM_SERIAL="${STREAM_SERIAL:-false}"
SERIAL_WATCH="${SERIAL_WATCH:-false}"
SERIAL_TAIL_LINES="${SERIAL_TAIL_LINES:-}"
SERIAL_SEND_CMD="${SERIAL_SEND_CMD:-}"
VM_MEM="${VM_MEM:-6144}"
VM_CPUS="${VM_CPUS:-4}"
VM_VNC="${VM_VNC:-}"
CUSTOM_ISO="${CUSTOM_ISO:-}"
TMP_DIR="${TMP_DIR:-${TMPDIR:-/tmp}}"
SERIAL_SOCK="${SERIAL_SOCK:-/tmp/windows-11-serial.sock}"
SERIAL_CLIENT_SOCK="${SERIAL_CLIENT_SOCK:-/tmp/windows-11-serial-client.sock}"
MONITOR_SOCK="${MONITOR_SOCK:-/tmp/windows-11-monitor.sock}"
SERIAL_LOG="${SERIAL_LOG:-${SCRIPT_DIR}/serial.log}"
PROXY_SCRIPT="${PROXY_SCRIPT:-${SCRIPT_DIR}/serial_proxy.py}"
SNAPSHOT_ACTION="list"
SNAPSHOT_NAME=""

# Parse CLI arguments
while [ $# -gt 0 ]; do
  case "$1" in
    build|box|register|run|serial|status|clean)
      COMMAND="$1"
      shift
      ;;
    snapshot)
      COMMAND="snapshot"
      shift
      if [ $# -gt 0 ]; then
        case "$1" in
          create|save|take)
            SNAPSHOT_ACTION="create"
            shift
            if [ $# -gt 0 ] && case "$1" in -*) false ;; *) true ;; esac; then
              SNAPSHOT_NAME="$1"
              shift
            fi
            ;;
          restore|load|apply|revert)
            SNAPSHOT_ACTION="restore"
            shift
            if [ $# -gt 0 ] && case "$1" in -*) false ;; *) true ;; esac; then
              SNAPSHOT_NAME="$1"
              shift
            fi
            ;;
          delete|del|rm|remove)
            SNAPSHOT_ACTION="delete"
            shift
            if [ $# -gt 0 ] && case "$1" in -*) false ;; *) true ;; esac; then
              SNAPSHOT_NAME="$1"
              shift
            fi
            ;;
          list|ls)
            SNAPSHOT_ACTION="list"
            shift
            ;;
          -*)
            ;;
          *)
            SNAPSHOT_ACTION="create"
            SNAPSHOT_NAME="$1"
            shift
            ;;
        esac
      fi
      ;;
    --provider)
      PROVIDER="$2"
      shift 2
      ;;
    --arch)
      ARCH="$2"
      shift 2
      ;;
    --iso)
      CUSTOM_ISO="$2"
      shift 2
      ;;
    --headless)
      HEADLESS="$2"
      shift 2
      ;;
    --gui|--no-headless)
      HEADLESS="false"
      shift
      ;;
    --debug)
      DEBUG_MODE="true"
      shift
      ;;
    --step)
      STEP_MODE="true"
      shift
      ;;
    --serial)
      STREAM_SERIAL="true"
      shift
      ;;
    --watch)
      SERIAL_WATCH="true"
      shift
      ;;
    --tail)
      if [ $# -ge 2 ]; then
        case "$2" in
          ''|*[!0-9]*)
            SERIAL_TAIL_LINES="50"
            shift
            ;;
          *)
            SERIAL_TAIL_LINES="$2"
            shift 2
            ;;
        esac
      else
        SERIAL_TAIL_LINES="50"
        shift
      fi
      ;;
    --send)
      SERIAL_SEND_CMD="$2"
      shift 2
      ;;
    --create|--save|--take)
      COMMAND="snapshot"
      SNAPSHOT_ACTION="create"
      if [ $# -ge 2 ] && case "$2" in -*) false ;; *) true ;; esac; then
        SNAPSHOT_NAME="$2"
        shift 2
      else
        shift
      fi
      ;;
    --restore|--load|--apply|--revert)
      COMMAND="snapshot"
      SNAPSHOT_ACTION="restore"
      if [ $# -ge 2 ] && case "$2" in -*) false ;; *) true ;; esac; then
        SNAPSHOT_NAME="$2"
        shift 2
      else
        shift
      fi
      ;;
    --delete|--del|--rm)
      COMMAND="snapshot"
      SNAPSHOT_ACTION="delete"
      if [ $# -ge 2 ] && case "$2" in -*) false ;; *) true ;; esac; then
        SNAPSHOT_NAME="$2"
        shift 2
      else
        shift
      fi
      ;;
    --list|--ls)
      COMMAND="snapshot"
      SNAPSHOT_ACTION="list"
      shift
      ;;
    --name|--snapshot-name)
      SNAPSHOT_NAME="$2"
      shift 2
      ;;
    --memory)
      VM_MEM="$2"
      shift 2
      ;;
    --cpus)
      VM_CPUS="$2"
      shift 2
      ;;
    --vnc)
      VM_VNC="$2"
      shift 2
      ;;
    -h|--help)
      sed -n '/^# Usage:/,/^# ====/ { /^# ====/d; s/^# //; s/^#//; p; }' "$0"
      exit 0
      ;;
    *)
      log_error "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Resolve default headless state
if [ -z "${HEADLESS}" ]; then
  if [ "${DEBUG_MODE}" = "true" ]; then
    HEADLESS="false"
  else
    HEADLESS="true"
  fi
fi

# Resolve ISO Path
find_iso() {
  if [ -n "${CUSTOM_ISO:-}" ] && [ -f "${CUSTOM_ISO}" ]; then
    printf '%s\n' "${CUSTOM_ISO}"
    return 0
  fi
  if [ -n "${WIN11_TARGET_ISO:-}" ] && [ -f "${WIN11_TARGET_ISO}" ]; then
    printf '%s\n' "${WIN11_TARGET_ISO}"
    return 0
  fi
  if [ -n "${WIN11_ISO_PATH:-}" ] && [ -f "${WIN11_ISO_PATH}" ]; then
    printf '%s\n' "${WIN11_ISO_PATH}"
    return 0
  fi

  for _sdir in "${ISO_DIR:-}" ${EXTRA_ISO_SEARCH_DIRS:-} "${SCRIPT_DIR}/builds/iso" "${HOME}/isos"; do
    if [ -n "${_sdir}" ] && [ -d "${_sdir}" ]; then
      _found_iso=$(find "${_sdir}" -maxdepth 1 -name "windows-11-${ARCH}*.iso" 2>/dev/null | head -n 1)
      if [ -n "${_found_iso}" ] && [ -f "${_found_iso}" ]; then
        printf '%s\n' "${_found_iso}"
        return 0
      fi
      _found_iso=$(find "${_sdir}" -maxdepth 1 \( -name "*win*11*${ARCH}*.iso" -o -name "*Win*11*${ARCH}*.iso" -o -name "*Win*11*Arm64*.iso" -o -name "*Win11*${ARCH}*.iso" -o -name "*Win11*Arm64*.iso" \) 2>/dev/null | head -n 1)
      if [ -n "${_found_iso}" ] && [ -f "${_found_iso}" ]; then
        printf '%s\n' "${_found_iso}"
        return 0
      fi
      _found_iso=$(find "${_sdir}" -maxdepth 1 -name "*windows-11*.iso" 2>/dev/null | head -n 1)
      if [ -n "${_found_iso}" ] && [ -f "${_found_iso}" ]; then
        printf '%s\n' "${_found_iso}"
        return 0
      fi
    fi
  done
  printf ''
}

# Ensure CRLF line endings for Windows driver INFs, answer files, and batch scripts
ensure_crlf() {
  _target_dir="$1"
  [ -d "${_target_dir}" ] || return 0
  if command -v unix2dos >/dev/null 2>&1; then
    find "${_target_dir}" -type f \( -name "*.inf" -o -name "*.xml" -o -name "*.cmd" -o -name "*.bat" -o -name "*.nsh" \) -exec unix2dos -q {} + 2>/dev/null || true
  else
    find "${_target_dir}" -type f \( -name "*.inf" -o -name "*.xml" -o -name "*.cmd" -o -name "*.bat" -o -name "*.nsh" \) -exec perl -pi -e 's/\r?\n/\r\n/' {} + 2>/dev/null || true
  fi
}

# Ensure VirtIO drivers are present in packer_templates/cidata
ensure_cidata() {
  _cidata_target="${SCRIPT_DIR}/packer_templates/cidata"
  if [ -d "${_cidata_target}/viostor" ]; then
    ensure_crlf "${_cidata_target}"
    ensure_crlf "${SCRIPT_DIR}/windows-11-arm64-packer/packer_templates/cidata"
    ensure_crlf "${SCRIPT_DIR}/packer_templates/win_answer_files"
    ensure_crlf "${SCRIPT_DIR}/windows-11-arm64-packer/packer_templates/win_answer_files"
    return 0
  fi
  log_info "VirtIO drivers not found in packer_templates/cidata. Searching..."
  for _cand in "${SCRIPT_DIR}/../windows-11-arm64-packer/packer_templates/cidata" "${SCRIPT_DIR}/windows-11-arm64-packer/packer_templates/cidata" "${HOME}/repos/bento/windows-11-arm64-packer/packer_templates/cidata"; do
    if [ -d "${_cand}/viostor" ]; then
      log_info "Copying pre-extracted VirtIO drivers from ${_cand}..."
      mkdir -p "${_cidata_target}"
      cp -R "${_cand}/"* "${_cidata_target}/"
      ensure_crlf "${_cidata_target}"
      return 0
    fi
  done

  # Try extracting from virtio-win.iso if available
  _v_iso=""
  for _idir in "${ISO_DIR:-}" ${EXTRA_VIRTIO_SEARCH_DIRS:-} ${EXTRA_ISO_SEARCH_DIRS:-} "${SCRIPT_DIR}/builds/iso" "${HOME}/isos"; do
    if [ -n "${_idir}" ] && [ -f "${_idir}/virtio-win.iso" ]; then
      _v_iso="${_idir}/virtio-win.iso"
      break
    fi
  done

  if [ -n "${_v_iso}" ] && command -v 7z >/dev/null 2>&1; then
    log_info "Extracting VirtIO drivers from ${_v_iso} into ${_cidata_target}..."
    mkdir -p "${_cidata_target}"
    7z x -y -o"${_cidata_target}" "${_v_iso}" Balloon NetKVM pvpanic viofs viogpudo vioinput viomem viorng vioscsi vioserial viostor virtio-win-guest-tools.exe >/dev/null 2>&1 || true
    ensure_crlf "${_cidata_target}"
    return 0
  fi
  log_warn "VirtIO drivers not found. Windows installer may fail to detect virtual disk without storage drivers."
}

# Generate OEM FAT32 volume with answer file and drivers for unattended Windows installation
ensure_oem_iso() {
  [ "${ARCH}" = "aarch64" ] || return 0

  _oem_iso="${WIN11_OEM_ISO:-${PKR_VAR_win11_oem_iso:-}}"
  if [ -z "${_oem_iso}" ]; then
    _oem_dir="${ISO_DIR:-${SCRIPT_DIR}/builds/iso}"
    mkdir -p "${_oem_dir}"
    _oem_iso="${_oem_dir}/bento_win11_arm64_unattend.iso"
  fi
  export WIN11_OEM_ISO="${_oem_iso}"
  export PKR_VAR_win11_oem_iso="${_oem_iso}"

  log_info "Preparing Windows 11 ARM64 OEM volume (${_oem_iso})..."
  _work_dir=$(mktemp -d "${TMP_DIR}/bento_oem.XXXXXX")

  # 1. Copy VirtIO drivers
  if [ -d "${SCRIPT_DIR}/packer_templates/cidata" ]; then
    cp -R "${SCRIPT_DIR}/packer_templates/cidata/"* "${_work_dir}/"
  fi

  # 2. Render Autounattend.xml from answer file template
  _ans_src="${SCRIPT_DIR}/packer_templates/win_answer_files/11/arm64/Autounattend.xml"
  _key="${WIN11_PRODUCT_KEY:-${WINDOWS_PRODUCT_KEY:-${PKR_VAR_windows_product_key:-W269N-WFGWX-YVC9B-4J6C9-T83GX}}}"
  python3 -c "
import re
c = open('${_ans_src}', 'r', encoding='utf-8', errors='ignore').read()
c = re.sub(r'%\{\s*if\s+windows_product_key\s*!=\s*\"\"\s*\}.*?%\{\s*endif\s*\}', f'<Key>${_key}</Key>', c, flags=re.DOTALL)
with open('${_work_dir}/Autounattend.xml', 'w', encoding='utf-8') as f:
    f.write(c)
"
  # Copy SetupComplete.cmd
  if [ -f "${SCRIPT_DIR}/packer_templates/win_answer_files/11/arm64/SetupComplete.cmd" ]; then
    cp -f "${SCRIPT_DIR}/packer_templates/win_answer_files/11/arm64/SetupComplete.cmd" "${_work_dir}/SetupComplete.cmd"
  fi

  # 3. Create startup.nsh for seamless automatic UEFI boot
  cat << 'NSH_EOF' > "${_work_dir}/startup.nsh"
@echo -off
for %i in 0 1 2 3 4 5 6 7 8 9
  if exist fs%i:\efi\microsoft\boot\bootmgfw.efi then
    fs%i:\efi\microsoft\boot\bootmgfw.efi
    goto DONE
  endif
endfor

for %i in 0 1 2 3 4 5 6 7 8 9
  if exist fs%i:\efi\boot\bootaa64.efi then
    fs%i:\efi\boot\bootaa64.efi
    goto DONE
  endif
endfor
:DONE
NSH_EOF

  # 4. Remove any macOS AppleDouble ._* files
  find "${_work_dir}" -name "._*" -delete 2>/dev/null || true
  ensure_crlf "${_work_dir}"

  # 5. Build FAT32 OEMDRV image
  _oem_target_dir=$(dirname "${_oem_iso}")
  mkdir -p "${_oem_target_dir}"

  if command -v hdiutil >/dev/null 2>&1; then
    _tmp_img=$(mktemp "${TMP_DIR}/bento_oem_img.XXXXXX")
    rm -f "${_tmp_img}" "${_tmp_img}.dmg"
    COPYFILE_DISABLE=1 hdiutil create -size 140m -fs "MS-DOS FAT32" -volname "OEMDRV" -srcfolder "${_work_dir}" -format UDRW "${_tmp_img}.dmg" >/dev/null 2>&1
    hdiutil attach "${_tmp_img}.dmg" >/dev/null 2>&1 || true
    find "/Volumes/OEMDRV" -name "._*" -delete 2>/dev/null || true
    hdiutil detach "/Volumes/OEMDRV" >/dev/null 2>&1 || true
    mv -f "${_tmp_img}.dmg" "${_oem_iso}"
    rm -f "${_tmp_img}"
  elif command -v mkfs.vfat >/dev/null 2>&1; then
    dd if=/dev/zero of="${_oem_iso}" bs=1M count=140 >/dev/null 2>&1
    mkfs.vfat -n "OEMDRV" "${_oem_iso}" >/dev/null 2>&1
    mcopy -i "${_oem_iso}" -s "${_work_dir}/"* ::/ >/dev/null 2>&1 || true
  fi

  rm -rf "${_work_dir}"
  log_success "Prepared OEM unattended volume at: ${_oem_iso}"
}

# Clean stale locks and background processes
cmd_clean() {
  log_info "Cleaning up stale locks, temporary build files, and processes..."
  rm -f "${SCRIPT_DIR}/builds/iso/"*.iso.lock 2>/dev/null || true
  rm -f "${SERIAL_SOCK}" "${SERIAL_CLIENT_SOCK}" "${MONITOR_SOCK}" "/tmp/windows-11-serial.sock" "/tmp/windows-11-serial-client.sock" "/tmp/windows-11-monitor.sock" "/tmp/bento-qemu-serial.sock" 2>/dev/null || true

  # Kill background serial proxy
  pkill -f "serial_proxy.py" 2>/dev/null || true

  # Kill running packer instances for windows-11
  pkill -f "packer.*windows-11" 2>/dev/null || true

  # Kill running QEMU instances for windows-11
  pkill -f "qemu-system-.*windows-11" 2>/dev/null || true

  # Clean VirtualBox VM if present
  if command -v VBoxManage >/dev/null 2>&1; then
    for _vm in $(VBoxManage list runningvms 2>/dev/null | grep -i "windows-11" | cut -d'"' -f2); do
      log_warn "Stopping running VirtualBox Windows 11 VM (${_vm})..."
      VBoxManage controlvm "${_vm}" poweroff 2>/dev/null || true
      sleep 1
    done
    for _vm in $(VBoxManage list vms 2>/dev/null | grep -i "windows-11" | cut -d'"' -f2); do
      log_info "Unregistering VirtualBox Windows 11 VM (${_vm})..."
      VBoxManage unregistervm "${_vm}" --delete 2>/dev/null || true
    done
  fi
  log_success "Cleanup complete."
}

# Start the serial multiplexer daemon
start_serial_proxy() {
  log_info "Starting serial console multiplexer daemon..."
  pkill -f "serial_proxy.py" 2>/dev/null || true
  rm -f "${SERIAL_CLIENT_SOCK}"

  export SERIAL_SOCK SERIAL_CLIENT_SOCK SERIAL_LOG
  python3 "${PROXY_SCRIPT}" >/dev/null 2>&1 &
  PROXY_PID=$!
  sleep 0.5
  if kill -0 "${PROXY_PID}" 2>/dev/null; then
    log_success "Serial multiplexer running (PID: ${PROXY_PID})"
    log_info "Serial logging active at: ${SERIAL_LOG}"
  else
    log_warn "Serial multiplexer could not start. Direct socket mode will be used."
  fi
}

# Connect via serial to debug
cmd_serial() {
  # Handle --tail option
  if [ -n "${SERIAL_TAIL_LINES}" ]; then
    if [ -f "${SERIAL_LOG}" ]; then
      log_info "Displaying last ${SERIAL_TAIL_LINES} lines of ${SERIAL_LOG}:"
      tail -n "${SERIAL_TAIL_LINES}" "${SERIAL_LOG}"
    else
      log_warn "No serial log file found at ${SERIAL_LOG}"
    fi
    return 0
  fi

  # Handle --watch option
  if [ "${SERIAL_WATCH}" = "true" ]; then
    if [ -f "${SERIAL_LOG}" ]; then
      log_info "Watching live serial log ${SERIAL_LOG} (Press Ctrl+C to exit):"
      tail -f "${SERIAL_LOG}"
    else
      log_warn "No serial log file found at ${SERIAL_LOG}. Start build or run first."
    fi
    return 0
  fi

  _target_sock="${SERIAL_CLIENT_SOCK}"
  _waited=0
  while [ ! -S "${_target_sock}" ] && [ ! -S "${SERIAL_SOCK}" ]; do
    if [ "${_waited}" -ge 5 ]; then
      break
    fi
    sleep 1
    _waited=$((_waited + 1))
  done

  if [ -S "${SERIAL_CLIENT_SOCK}" ]; then
    _target_sock="${SERIAL_CLIENT_SOCK}"
  elif [ -S "${SERIAL_SOCK}" ]; then
    _target_sock="${SERIAL_SOCK}"
  fi

  if [ ! -S "${_target_sock}" ]; then
    log_warn "Active serial socket (${SERIAL_SOCK}) is not currently open."
    if [ -f "${SERIAL_LOG}" ] && [ -s "${SERIAL_LOG}" ]; then
      log_info "Recent serial activity from ${SERIAL_LOG}:"
      printf "%b----------------------------------------------------------------%b\n" "${C_CYAN}" "${C_RESET}"
      tail -n 30 "${SERIAL_LOG}" 2>/dev/null || true
      printf "%b----------------------------------------------------------------%b\n" "${C_CYAN}" "${C_RESET}"
      log_info "To stream live serial output once the VM starts, use: ./windows-11-builder.sh serial --watch"
      return 0
    else
      log_error "No active socket or serial log found. Run './windows-11-builder.sh build' or 'run' first."
      return 1
    fi
  fi

  # Handle --send option for non-interactive command execution
  if [ -n "${SERIAL_SEND_CMD}" ]; then
    log_info "Sending command to Windows 11 serial console: ${SERIAL_SEND_CMD}"
    SERIAL_TARGET_SOCK="${_target_sock}" CMD_TO_SEND="${SERIAL_SEND_CMD}" python3 -c '
import socket, sys, os, time, select

sock_path = os.environ.get("SERIAL_TARGET_SOCK", "/tmp/windows-11-serial-client.sock")
cmd = os.environ.get("CMD_TO_SEND", "") + "
"

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(sock_path)
s.setblocking(False)

s.sendall(cmd.encode("utf-8"))

end_time = time.time() + 3.0
output = b""
while time.time() < end_time:
    r, _, _ = select.select([s], [], [], 0.2)
    if s in r:
        data = s.recv(4096)
        if not data:
            break
        output += data

s.close()
sys.stdout.buffer.write(output)
sys.stdout.flush()
'
    return 0
  fi

  # Interactive serial console session
  printf "%b================================================================%b\n" "${C_YELLOW}${C_BOLD}" "${C_RESET}"
  printf "%b  CONNECTED TO WINDOWS 11 SERIAL CONSOLE (COM1)                %b\n" "${C_YELLOW}${C_BOLD}" "${C_RESET}"
  printf "%b  - Live terminal stream connected to VM COM1 serial port       %b\n" "${C_YELLOW}" "${C_RESET}"
  printf "%b  - To exit this console session: Press Ctrl+C                  %b\n" "${C_YELLOW}" "${C_RESET}"
  printf "%b================================================================%b\n" "${C_YELLOW}${C_BOLD}" "${C_RESET}"

  SERIAL_TARGET_SOCK="${_target_sock}" python3 -c '
import socket, sys, select, os, tty, termios

sock_path = os.environ.get("SERIAL_TARGET_SOCK", "/tmp/windows-11-serial-client.sock")
if not os.path.exists(sock_path):
    sock_path = "/tmp/windows-11-serial.sock"

try:
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(sock_path)
except Exception as e:
    print(f"\033[31mError connecting to {sock_path}: {e}\033[0m")
    sys.exit(1)

old_settings = None
is_tty = sys.stdin.isatty()

try:
    if is_tty:
        old_settings = termios.tcgetattr(sys.stdin)
        tty.setraw(sys.stdin.fileno())

    try:
        s.sendall(b"
")
    except Exception:
        pass

    while True:
        watch_list = [s]
        if is_tty:
            watch_list.append(sys.stdin)

        r, _, _ = select.select(watch_list, [], [], 0.5)
        if s in r:
            data = s.recv(4096)
            if not data:
                break
            sys.stdout.buffer.write(data)
            sys.stdout.flush()

        if is_tty and sys.stdin in r:
            user_input = sys.stdin.buffer.read(1)
            if not user_input or user_input == b"\x03":
                break
            s.sendall(user_input)
except KeyboardInterrupt:
    pass
finally:
    if old_settings:
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
    s.close()
    print("
\033[33m[Serial connection closed]\033[0m")
'
}

# Show status
cmd_status() {
  log_info "Windows 11 Bento Environment Status:"
  printf "  Architecture   : %s\n" "${ARCH}"
  printf "  Provider       : %s\n" "${PROVIDER}"
  printf "  Files Dir      : %s\n" "${BENTO_BUILD_FILES_DIR}"
  printf "  Complete Dir   : %s\n" "${BENTO_BUILD_COMPLETE_DIR}"
  printf "  Serial Socket  : %s (exists: %s)\n" "${SERIAL_SOCK}" "$([ -S "${SERIAL_SOCK}" ] && echo yes || echo no)"
  printf "  Client Socket  : %s (exists: %s)\n" "${SERIAL_CLIENT_SOCK}" "$([ -S "${SERIAL_CLIENT_SOCK}" ] && echo yes || echo no)"
  printf "  Monitor Socket : %s (exists: %s)\n" "${MONITOR_SOCK}" "$([ -S "${MONITOR_SOCK}" ] && echo yes || echo no)"

  if [ -f "${SERIAL_LOG}" ]; then
    _log_lines=$(wc -l < "${SERIAL_LOG}")
    _log_bytes=$(wc -c < "${SERIAL_LOG}")
    printf "  Serial Log     : %s (%s bytes, %s lines)\n" "${SERIAL_LOG}" "${_log_bytes}" "${_log_lines}"
    if [ "${_log_lines}" -gt 0 ]; then
      _last_entry=$(tail -n 1 "${SERIAL_LOG}" | tr '
' ' ')
      printf "  Last Log Entry : %s\n" "${_last_entry}"
    fi
  else
    printf "  Serial Log     : Not yet created\n"
  fi

  _iso_path="$(find_iso)"
  if [ -n "${_iso_path}" ]; then
    _iso_sz=$(du -h "${_iso_path}" | cut -f1)
    printf "  ISO Located    : %s (%s)\n" "${_iso_path}" "${_iso_sz}"
  else
    printf "  ISO Located    : None found in ISO directory\n"
  fi

  printf "
Disk Images (%s):
" "${BENTO_BUILD_FILES_DIR}"
  _found_disks=0
  for _d in "${BENTO_BUILD_FILES_DIR}"/*/*windows-11* "${BENTO_BUILD_FILES_DIR}"/*/box*.img "${SCRIPT_DIR}/builds/build_files"/*/*windows-11* "${SCRIPT_DIR}/builds/build_files"/*/box*.img; do
    if [ -f "${_d}" ]; then
      _dsz=$(du -h "${_d}" | cut -f1)
      _dbytes=$(get_file_size "${_d}")
      _dir_base=$(basename "$(dirname "${_d}")")
      _f_base=$(basename "${_d}")
      printf "  - %s/%s : %b%s%b (%s bytes)\n" "${_dir_base}" "${_f_base}" "${C_CYAN}" "${_dsz}" "${C_RESET}" "${_dbytes}"
      _found_disks=1
    fi
  done
  if [ "${_found_disks}" -eq 0 ]; then
    printf "  (None found)\n"
  fi

  printf "
Running Processes:
"
  pgrep -fl "packer.*windows-11|qemu-system-.*windows-11|serial_proxy.py" 2>/dev/null || printf "  (None)\n"

  printf "
Built Boxes (%s):
" "${BENTO_BUILD_COMPLETE_DIR}"
  _found_boxes=0
  for _b in "${BENTO_BUILD_COMPLETE_DIR}"/*windows-11*.box "${SCRIPT_DIR}/builds/build_complete/"*windows-11*.box; do
    if [ -f "${_b}" ]; then
      _bsz=$(du -h "${_b}" | cut -f1)
      _bsz_bytes=$(get_file_size "${_b}")
      printf "  - %s : %b%s%b (%s bytes)\n" "$(basename "${_b}")" "${C_GREEN}${C_BOLD}" "${_bsz}" "${C_RESET}" "${_bsz_bytes}"
      _found_boxes=1
    fi
  done
  if [ "${_found_boxes}" -eq 0 ]; then
    printf "  (No .box files built yet)\n"
  fi
}

# Snapshot management (live via QEMU monitor / VBoxManage, or offline via qemu-img)
cmd_snapshot() {
  _action="${SNAPSHOT_ACTION:-list}"
  _snap_name="${SNAPSHOT_NAME:-}"
  _provider="${PROVIDER}"

  # Check if VirtualBox VM exists
  _vbox_vm=""
  if command -v VBoxManage >/dev/null 2>&1; then
    _vbox_vm=$(VBoxManage list vms 2>/dev/null | grep -i "windows-11" | head -n 1 | cut -d'"' -f2 || true)
  fi

  if [ "${_provider}" = "virtualbox" ] || { [ -n "${_vbox_vm}" ] && [ "${_provider}" != "qemu" ]; }; then
    if [ -z "${_vbox_vm}" ]; then
      log_error "No VirtualBox Windows 11 VM found."
      exit 1
    fi
    case "${_action}" in
      create)
        if [ -z "${_snap_name}" ]; then
          _snap_name="snap_$(date +%Y%m%d_%H%M%S)"
        fi
        log_info "Taking VirtualBox snapshot '${_snap_name}' for VM '${_vbox_vm}'..."
        VBoxManage snapshot "${_vbox_vm}" take "${_snap_name}"
        log_success "Snapshot '${_snap_name}' created successfully."
        ;;
      list)
        log_info "VirtualBox snapshots for VM '${_vbox_vm}':"
        VBoxManage snapshot "${_vbox_vm}" list || true
        ;;
      restore)
        if [ -z "${_snap_name}" ]; then
          log_error "Snapshot name required for restore. Run './windows-11-builder.sh snapshot list' to view snapshots."
          exit 1
        fi
        log_info "Restoring VirtualBox VM '${_vbox_vm}' to snapshot '${_snap_name}'..."
        VBoxManage snapshot "${_vbox_vm}" restore "${_snap_name}"
        log_success "Snapshot '${_snap_name}' restored successfully."
        ;;
      delete)
        if [ -z "${_snap_name}" ]; then
          log_error "Snapshot name required for delete."
          exit 1
        fi
        log_info "Deleting VirtualBox snapshot '${_snap_name}' from VM '${_vbox_vm}'..."
        VBoxManage snapshot "${_vbox_vm}" delete "${_snap_name}"
        log_success "Snapshot '${_snap_name}' deleted successfully."
        ;;
      *)
        log_error "Unknown snapshot action: ${_action}"
        exit 1
        ;;
    esac
    return 0
  fi

  # QEMU Provider
  _disk_img=""
  for _cand in \
    "${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu/windows-11-amd64" \
    "${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu/windows-11-${ARCH}" \
    "${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu/box.img" \
    "${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu/box_optimized.img" \
    "${SCRIPT_DIR}/builds/build_files/packer-windows-11-${ARCH}-qemu/windows-11-amd64" \
    "${SCRIPT_DIR}/builds/build_files/packer-windows-11-${ARCH}-qemu/windows-11-${ARCH}" \
    "${SCRIPT_DIR}/builds/build_files/packer-windows-11-${ARCH}-qemu/box.img" \
    "${SCRIPT_DIR}/builds/build_files/packer-windows-11-${ARCH}-qemu/box_optimized.img" \
    "${SCRIPT_DIR}"/.vagrant/machines/*/qemu/*/linked-box.img \
    ${EXTERNAL_VAGRANT_DIR:+"${EXTERNAL_VAGRANT_DIR}/.vagrant/machines/*/qemu/*/linked-box.img"} \
    "${SCRIPT_DIR}/../libscript/vagrant/windows-11"/.vagrant/machines/*/qemu/*/linked-box.img; do
    if [ -f "${_cand}" ]; then
      _disk_img="${_cand}"
      break
    fi
  done

  if [ -z "${_disk_img}" ]; then
    _box_file=$(find "${BENTO_BUILD_COMPLETE_DIR}" "${SCRIPT_DIR}/builds/build_complete" -name "*windows-11*.box" 2>/dev/null | head -n 1)
    if [ -n "${_box_file}" ]; then
      log_info "Extracting box.img from ${_box_file}..."
      _extract_dir="${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu"
      mkdir -p "${_extract_dir}"
      tar -xf "${_box_file}" -C "${_extract_dir}" box.img 2>/dev/null || true
      if [ -f "${_extract_dir}/box.img" ]; then
        _disk_img="${_extract_dir}/box.img"
      fi
    fi
  fi

  if [ -z "${_disk_img}" ]; then
    log_error "No built Windows 11 disk image found. Run './windows-11-builder.sh build' first."
    exit 1
  fi

  _disk_dir="$(dirname "${_disk_img}")"
  _vars_img="${_disk_dir}/efivars_run.qcow2"

  # Check if QEMU is running with monitor socket (check MONITOR_SOCK and vagrant-qemu sockets)
  _qemu_live=false
  _live_sock=""
  for _sock in "${MONITOR_SOCK}" "${HOME}/.vagrant.d/tmp/vagrant-qemu"/*/qemu_socket; do
    if [ -S "${_sock}" ]; then
      if MONITOR_SOCK="${_sock}" python3 -c '
import os, sys, socket
sock = os.environ.get("MONITOR_SOCK", "")
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(1.0)
try:
    s.connect(sock)
    s.close()
    sys.exit(0)
except Exception:
    sys.exit(1)
' 2>/dev/null; then
        _qemu_live=true
        _live_sock="${_sock}"
        break
      fi
    fi
  done

  # Check if QEMU process is running without a monitor socket
  if [ "${_qemu_live}" = "false" ] && pgrep -fl "qemu-system-.*windows-11" >/dev/null 2>&1; then
    log_warn "QEMU is currently running without an accessible monitor socket."
    log_warn "For offline disk snapshot operations, stop the VM using './windows-11-builder.sh clean'."
    log_warn "To enable live VM snapshots, start the VM using './windows-11-builder.sh run'."
  fi

  # Helper to execute command over QEMU monitor socket
  exec_qemu_mon() {
    _cmd="$1"
    MONITOR_SOCK="${_live_sock}" MON_CMD="${_cmd}" python3 -c '
import os, sys, socket, time, re

sock_path = os.environ.get("MONITOR_SOCK", "")
cmd = os.environ.get("MON_CMD", "")
timeout = 30.0

if not sock_path or not os.path.exists(sock_path):
    sys.stderr.write("Monitor socket not found.\n")
    sys.exit(2)

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(timeout)
try:
    s.connect(sock_path)
except Exception as e:
    sys.stderr.write(f"Failed to connect to monitor socket: {e}\n")
    sys.exit(1)

buf = ""
start = time.time()
while "(qemu)" not in buf and (time.time() - start) < 3.0:
    try:
        chunk = s.recv(1024).decode("utf-8", errors="replace")
        if not chunk: break
        buf += chunk
    except Exception:
        break

s.sendall((cmd.strip() + "\n").encode("utf-8"))

out = ""
start = time.time()
while (time.time() - start) < timeout:
    try:
        chunk = s.recv(1024).decode("utf-8", errors="replace")
        if not chunk: break
        out += chunk
        if "(qemu)" in out:
            break
    except Exception:
        break
s.close()

clean = re.sub(r"\x1b\[[0-9;]*[a-zA-Z]", "", out)
lines = [l.strip() for l in clean.splitlines() if l.strip() and not l.strip().startswith("(qemu)") and l.strip() != cmd.strip()]
final_lines = [l for l in lines if not all(c in cmd for c in l)]
result = "\n".join(final_lines).strip()
if result:
    print(result)
if "Error" in result or "error" in result:
    sys.exit(1)
'
  }

  case "${_action}" in
    create)
      if [ -z "${_snap_name}" ]; then
        _snap_name="snap_$(date +%Y%m%d_%H%M%S)"
      fi
      if [ "${_qemu_live}" = "true" ]; then
        log_info "Creating live snapshot '${_snap_name}' via QEMU monitor (RAM + Disk)..."
        if exec_qemu_mon "savevm ${_snap_name}"; then
          log_success "Live snapshot '${_snap_name}' created successfully."
        else
          log_error "Failed to create live snapshot '${_snap_name}'."
          exit 1
        fi
      else
        log_info "Creating offline snapshot '${_snap_name}' on ${_disk_img}..."
        qemu-img snapshot -c "${_snap_name}" "${_disk_img}"
        if [ -f "${_vars_img}" ]; then
          qemu-img snapshot -c "${_snap_name}" "${_vars_img}" 2>/dev/null || true
        fi
        log_success "Offline snapshot '${_snap_name}' created successfully."
      fi
      ;;
    list)
      if [ "${_qemu_live}" = "true" ]; then
        log_info "Snapshots present in running VM (live via monitor):"
        exec_qemu_mon "info snapshots" || true
      else
        log_info "Snapshots present on disk (${_disk_img}):"
        qemu-img snapshot -l "${_disk_img}" || true
      fi
      ;;
    restore)
      if [ -z "${_snap_name}" ]; then
        log_error "Snapshot name required for restore. Run './windows-11-builder.sh snapshot list' to view snapshots."
        exit 1
      fi
      if [ "${_qemu_live}" = "true" ]; then
        log_info "Restoring live VM to snapshot '${_snap_name}' via QEMU monitor..."
        if exec_qemu_mon "loadvm ${_snap_name}"; then
          log_success "Live VM restored to snapshot '${_snap_name}' successfully."
        else
          log_error "Failed to restore live VM to snapshot '${_snap_name}'."
          exit 1
        fi
      else
        log_info "Restoring offline disk image to snapshot '${_snap_name}'..."
        qemu-img snapshot -a "${_snap_name}" "${_disk_img}"
        if [ -f "${_vars_img}" ]; then
          qemu-img snapshot -a "${_snap_name}" "${_vars_img}" 2>/dev/null || true
        fi
        log_success "Snapshot '${_snap_name}' restored successfully."
      fi
      ;;
    delete)
      if [ -z "${_snap_name}" ]; then
        log_error "Snapshot name required for delete."
        exit 1
      fi
      if [ "${_qemu_live}" = "true" ]; then
        log_info "Deleting snapshot '${_snap_name}' via QEMU monitor..."
        if exec_qemu_mon "delvm ${_snap_name}"; then
          log_success "Snapshot '${_snap_name}' deleted successfully."
        else
          log_error "Failed to delete snapshot '${_snap_name}'."
          exit 1
        fi
      else
        log_info "Deleting snapshot '${_snap_name}' from ${_disk_img}..."
        qemu-img snapshot -d "${_snap_name}" "${_disk_img}"
        if [ -f "${_vars_img}" ]; then
          qemu-img snapshot -d "${_snap_name}" "${_vars_img}" 2>/dev/null || true
        fi
        log_success "Snapshot '${_snap_name}' deleted successfully."
      fi
      ;;
    *)
      log_error "Unknown snapshot action: ${_action}"
      exit 1
      ;;
  esac
}

# Run built box/disk directly with KVM, serial and port forwards
cmd_run() {
  _disk_img=""
  for _cand in "${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu/windows-11-amd64" "${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu/windows-11-${ARCH}" "${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu/box.img" "${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu/box_optimized.img" "${SCRIPT_DIR}/builds/build_files/packer-windows-11-${ARCH}-qemu/windows-11-amd64" "${SCRIPT_DIR}/builds/build_files/packer-windows-11-${ARCH}-qemu/windows-11-${ARCH}" "${SCRIPT_DIR}/builds/build_files/packer-windows-11-${ARCH}-qemu/box.img" "${SCRIPT_DIR}/builds/build_files/packer-windows-11-${ARCH}-qemu/box_optimized.img"; do
    if [ -f "${_cand}" ]; then
      _disk_img="${_cand}"
      break
    fi
  done

  # Also check if box exists and extract if necessary
  if [ -z "${_disk_img}" ]; then
    _box_file=$(find "${BENTO_BUILD_COMPLETE_DIR}" "${SCRIPT_DIR}/builds/build_complete" -name "*windows-11*.box" 2>/dev/null | head -n 1)
    if [ -n "${_box_file}" ]; then
      log_info "Extracting box.img from ${_box_file}..."
      _extract_dir="${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-qemu"
      mkdir -p "${_extract_dir}"
      tar -xf "${_box_file}" -C "${_extract_dir}" box.img 2>/dev/null || true
      if [ -f "${_extract_dir}/box.img" ]; then
        _disk_img="${_extract_dir}/box.img"
      fi
    fi
  fi

  if [ -z "${_disk_img}" ]; then
    log_error "No built disk image found. Run './windows-11-builder.sh build' first."
    exit 1
  fi

  # Find UEFI firmware code and vars
  _brew_prefix=""
  if command -v brew >/dev/null 2>&1; then
    _brew_prefix="$(brew --prefix 2>/dev/null || true)"
  fi

  _efi_code=""
  _efi_vars=""
  if [ "${ARCH}" = "x86_64" ]; then
    for _c in "${QEMU_EDK2_CODE:-}" "${QEMU_BIOS:-}" "/usr/share/OVMF/OVMF_CODE.fd" "/usr/share/OVMF/OVMF_CODE_4M.fd" "/usr/share/ovmf/OVMF.fd" "/usr/share/edk2/ovmf/OVMF_CODE.fd" "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd" "${_brew_prefix}/share/qemu/edk2-x86_64-code.fd" "/opt/homebrew/share/qemu/edk2-x86_64-code.fd" "/usr/local/share/qemu/edk2-x86_64-code.fd" "/opt/local/share/qemu/edk2-x86_64-code.fd" "/usr/share/qemu/edk2-x86_64-code.fd" "/usr/share/qemu/OVMF.fd" "C:/Program Files/qemu/share/edk2-x86_64-code.fd" "C:/msys64/mingw64/share/qemu/edk2-x86_64-code.fd"; do
      if [ -n "${_c}" ] && [ -f "${_c}" ]; then _efi_code="${_c}"; break; fi
    done
    for _v in "${QEMU_EDK2_VARS:-}" "/usr/share/OVMF/OVMF_VARS.fd" "/usr/share/OVMF/OVMF_VARS_4M.fd" "/usr/share/ovmf/OVMF_VARS.fd" "/usr/share/edk2/ovmf/OVMF_VARS.fd" "/usr/share/edk2-ovmf/x64/OVMF_VARS.fd" "${_brew_prefix}/share/qemu/edk2-i386-vars.fd" "/opt/homebrew/share/qemu/edk2-i386-vars.fd" "/usr/local/share/qemu/edk2-i386-vars.fd" "/opt/local/share/qemu/edk2-i386-vars.fd" "/usr/share/qemu/edk2-i386-vars.fd" "C:/Program Files/qemu/share/edk2-i386-vars.fd" "C:/msys64/mingw64/share/qemu/edk2-i386-vars.fd"; do
      if [ -n "${_v}" ] && [ -f "${_v}" ]; then _efi_vars="${_v}"; break; fi
    done
  else
    for _c in "${QEMU_EDK2_CODE:-}" "${QEMU_BIOS:-}" "${_brew_prefix}/share/qemu/edk2-aarch64-code.fd" "/opt/homebrew/share/qemu/edk2-aarch64-code.fd" "/usr/share/AAVMF/AAVMF_CODE.fd" "/usr/share/AAVMF/AAVMF32_CODE.fd" "/usr/share/qemu/edk2-aarch64-code.fd" "/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw" "/usr/share/edk2/aarch64/QEMU_EFI.fd" "/usr/share/edk2-armvirt/aarch64/QEMU_EFI.fd" "/usr/local/share/qemu/edk2-aarch64-code.fd" "/opt/local/share/qemu/edk2-aarch64-code.fd" "C:/Program Files/qemu/share/edk2-aarch64-code.fd" "C:/msys64/mingw64/share/qemu/edk2-aarch64-code.fd"; do
      if [ -n "${_c}" ] && [ -f "${_c}" ]; then _efi_code="${_c}"; break; fi
    done
    for _v in "${QEMU_EDK2_VARS:-}" "${_brew_prefix}/share/qemu/edk2-arm-vars.fd" "/opt/homebrew/share/qemu/edk2-arm-vars.fd" "/usr/share/AAVMF/AAVMF_VARS.fd" "/usr/share/qemu/edk2-arm-vars.fd" "/usr/share/edk2/aarch64/vars-template-pflash.raw" "/usr/share/edk2-armvirt/aarch64/QEMU_VARS.fd" "/usr/local/share/qemu/edk2-arm-vars.fd" "/opt/local/share/qemu/edk2-arm-vars.fd" "C:/Program Files/qemu/share/edk2-arm-vars.fd" "C:/msys64/mingw64/share/qemu/edk2-arm-vars.fd"; do
      if [ -n "${_v}" ] && [ -f "${_v}" ]; then _efi_vars="${_v}"; break; fi
    done
  fi

  log_info "Starting Windows 11 VM directly with QEMU (${ARCH})..."
  printf "  Disk Image     : %s\n" "${_disk_img}"
  printf "  UEFI Firmware  : %s\n" "${_efi_code:-'(none)'}"
  printf "  CPUs / Memory  : %s CPUs, %s MB RAM\n" "${VM_CPUS}" "${VM_MEM}"
  printf "  WinRM Forward  : 127.0.0.1:5985\n"
  printf "  RDP Forward    : 127.0.0.1:3389\n"
  printf "  SSH Forward    : 127.0.0.1:2222\n"
  printf "  Serial Console : %s\n" "${SERIAL_SOCK}"
  printf "  Monitor Socket : %s\n" "${MONITOR_SOCK}"

  # Clean stale sockets
  rm -f "${SERIAL_SOCK}" "${MONITOR_SOCK}"

  # Start serial multiplexer
  start_serial_proxy

  printf "%bVM is starting. In another terminal, run './windows-11-builder.sh serial' to connect.%b\n" "${C_GREEN}${C_BOLD}" "${C_RESET}"

  _host_os="linux"
  case "$(uname -s)" in
    Darwin*) _host_os="darwin" ;;
    Linux*)  _host_os="linux" ;;
    CYGWIN*|MINGW*|MSYS*) _host_os="windows" ;;
  esac

  _qemu_accel="kvm"
  if [ "${_host_os}" = "darwin" ]; then
    _qemu_accel="hvf"
  elif [ "${_host_os}" = "windows" ]; then
    _qemu_accel="whpx"
  fi

  _qemu_mach="q35,accel=${_qemu_accel}"
  if [ "${ARCH}" = "aarch64" ]; then
    _qemu_mach="virt,highmem=on,accel=${_qemu_accel}"
  fi

  set -- "qemu-system-${ARCH}" \
    "-name" "windows-11-${ARCH}" \
    "-machine" "${_qemu_mach}" \
    "-cpu" "host" \
    "-smp" "${VM_CPUS}" \
    "-m" "${VM_MEM}"

  if [ -n "${_efi_code}" ]; then
    set -- "$@" "-drive" "if=pflash,format=raw,readonly=on,file=${_efi_code}"
  fi

  # Setup writable NVRAM efivars (converted to qcow2 format for snapshot support)
  _disk_dir="$(dirname "${_disk_img}")"
  _run_vars="${_disk_dir}/efivars_run.qcow2"
  _src_vars=""
  if [ -f "${_disk_dir}/efivars.fd" ]; then
    _src_vars="${_disk_dir}/efivars.fd"
  elif [ -n "${_efi_vars}" ]; then
    _src_vars="${_efi_vars}"
  fi
  if [ -n "${_src_vars}" ]; then
    if [ ! -f "${_run_vars}" ] || [ "${_src_vars}" -nt "${_run_vars}" ]; then
      qemu-img convert -f raw -O qcow2 "${_src_vars}" "${_run_vars}"
    fi
    set -- "$@" "-drive" "if=pflash,format=qcow2,file=${_run_vars}"
  fi

  if [ "${ARCH}" = "aarch64" ]; then
    set -- "$@" \
      "-device" "pcie-root-port,id=pcie.1,chassis=1,slot=1" \
      "-drive" "file=${_disk_img},if=none,id=disk0,cache=writeback,discard=unmap" \
      "-device" "nvme,serial=nvme0,drive=disk0,bus=pcie.1" \
      "-netdev" "user,id=user.0,hostfwd=tcp::5985-:5985,hostfwd=tcp::3389-:3389,hostfwd=tcp::2222-:22" \
      "-device" "virtio-net-pci,netdev=user.0" \
      "-device" "qemu-xhci" \
      "-device" "usb-kbd" \
      "-device" "usb-tablet" \
      "-device" "ramfb"
  else
    set -- "$@" \
      "-drive" "file=${_disk_img},if=none,id=disk0,cache=writeback,discard=unmap" \
      "-device" "ide-hd,drive=disk0,bus=ide.0" \
      "-netdev" "user,id=user.0,hostfwd=tcp::5985-:5985,hostfwd=tcp::3389-:3389,hostfwd=tcp::2222-:22" \
      "-device" "virtio-net-pci,netdev=user.0" \
      "-device" "qemu-xhci" \
      "-device" "usb-kbd" \
      "-device" "usb-tablet" \
      "-vga" "std"
  fi

  if [ -n "${VM_VNC}" ]; then
    set -- "$@" "-vnc" ":${VM_VNC}"
    log_info "VNC display accessible on port 590${VM_VNC}"
  elif [ "${HEADLESS}" = "true" ]; then
    set -- "$@" "-display" "none"
  fi

  set -- "$@" \
    "-chardev" "socket,id=ser0,path=${SERIAL_SOCK},server=on,wait=off" \
    "-serial" "chardev:ser0" \
    "-monitor" "unix:${MONITOR_SOCK},server,nowait"

  exec "$@"
}

# Multi-stage aggressive box size reduction pipeline
cmd_box() {
  _provider="${1:-${PROVIDER}}"
  log_info "================================================================"
  log_info "  AGGRESSIVE VAGRANT .BOX SIZE REDUCTION PIPELINE (${ARCH}, ${_provider})"
  log_info "================================================================"

  _build_files_dir="${BENTO_BUILD_FILES_DIR}/packer-windows-11-${ARCH}-${_provider}"
  mkdir -p "${BENTO_BUILD_COMPLETE_DIR}"

  _box_name="windows-11-${ARCH}.${_provider}.box"
  _target_box="${BENTO_BUILD_COMPLETE_DIR}/${_box_name}"

  if [ "${_provider}" = "qemu" ]; then
    _src_img=""
    for _cand in "${_build_files_dir}/windows-11-amd64" "${_build_files_dir}/windows-11-${ARCH}" "${_build_files_dir}/box.img"; do
      if [ -f "${_cand}" ]; then
        _src_img="${_cand}"
        break
      fi
    done

    # Check builds/build_complete if packer's vagrant post-processor already built a base box
    if [ -z "${_src_img}" ]; then
      _existing_box=$(find "${BENTO_BUILD_COMPLETE_DIR}" "${SCRIPT_DIR}/builds/build_complete" -name "*windows-11*.box" 2>/dev/null | head -n 1)
      if [ -n "${_existing_box}" ]; then
        log_info "Extracting disk image from existing box (${_existing_box}) for optimization..."
        mkdir -p "${_build_files_dir}"
        tar -xf "${_existing_box}" -C "${_build_files_dir}" box_0.img 2>/dev/null || tar -xf "${_existing_box}" -C "${_build_files_dir}" box.img 2>/dev/null || true
        if [ -f "${_build_files_dir}/box_0.img" ]; then
          mv -f "${_build_files_dir}/box_0.img" "${_build_files_dir}/box.img"
        fi
        if [ -f "${_build_files_dir}/box.img" ]; then
          _src_img="${_build_files_dir}/box.img"
        fi
      fi
    fi

    if [ -z "${_src_img}" ]; then
      log_error "Could not find QEMU disk image in ${_build_files_dir}"
      exit 1
    fi

    _orig_bytes=$(get_file_size "${_src_img}")
    _orig_mb=$((_orig_bytes / 1024 / 1024))
    log_info "Step 1: Input disk image: ${_src_img}"
    log_info "        Original disk image size: ${_orig_mb} MB ($((_orig_mb / 1024)) GB)"

    # Step 2: Multi-threaded zero-block sparsification and cluster compression
    _opt_img="${_build_files_dir}/box_optimized.img"
    log_info "Step 2: Multi-threaded sparsification (-S 4k) & zlib cluster compression (-c)..."
    qemu-img convert -p -m 16 -W -O qcow2 -c -S 4k "${_src_img}" "${_opt_img}"

    _opt_bytes=$(get_file_size "${_opt_img}")
    _opt_mb=$((_opt_bytes / 1024 / 1024))
    _saved_mb=$((_orig_mb - _opt_mb))
    log_success "Compressed disk image size: ${_opt_mb} MB (Direct disk savings: ${_saved_mb} MB)"

    mv -f "${_opt_img}" "${_build_files_dir}/box.img"

    _virt_gb=$(qemu-img info --output=json "${_src_img}" | python3 -c "import sys, json; print(int(json.load(sys.stdin).get('virtual-size', 68719476736) / (1024**3)))" 2>/dev/null || echo "64")

    # Step 3: Generate Vagrant metadata and template
    log_info "Step 3: Generating Vagrant metadata (${_provider}, virtual_size: ${_virt_gb} GB) and Vagrantfile template..."
    cat << EOF > "${_build_files_dir}/metadata.json"
{
  "provider": "${_provider}",
  "format": "qcow2",
  "virtual_size": ${_virt_gb}
}
EOF

    cat << 'EOF' > "${_build_files_dir}/Vagrantfile"
Vagrant.configure("2") do |config|
  config.vm.guest = :windows
  config.vm.communicator = "winrm"
  config.vm.boot_timeout = 600
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"
  config.winrm.retry_limit = 30
  config.winrm.retry_delay = 10
  config.ssh.username = "vagrant"
  config.ssh.insert_key = false
  config.ssh.private_key_path = File.expand_path("~/.vagrant.d/insecure_private_key")
  config.ssh.shell = "powershell"

  config.vm.network :forwarded_port, guest: 22, host: 2222, id: 'ssh', auto_correct: true
  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: 'rdp', auto_correct: true
  config.vm.network :forwarded_port, guest: 5985, host: 5985, id: 'winrm', auto_correct: true

  # Synced folder: rsync works without host privileges or password prompts
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.provider :libvirt do |lv|
    lv.cpus = 4
    lv.memory = 6144
    lv.video_type = "virtio"
    lv.nic_model_type = "virtio"
    lv.driver = "kvm"
    lv.channel :type => 'unix', :target_type => 'virtio', :target_name => 'org.qemu.guest_agent.0'
  end

  is_darwin = /darwin/ =~ RUBY_PLATFORM
  is_windows = /mswin|mingw|cygwin/ =~ RUBY_PLATFORM
  accel = is_darwin ? "hvf" : (is_windows ? "whpx" : "kvm")

  host_cpu = (RbConfig::CONFIG["host_cpu"] || RUBY_PLATFORM).downcase
  is_arm = host_cpu =~ /aarch64|arm64/

  config.vm.provider :qemu do |qe|
    if is_arm
      qe.arch = "aarch64"
      qe.machine = "virt,highmem=on,accel=#{accel}"
      qe.cpu = "host"
      qe.smp = "4"
      qe.memory = "4096M"
      qe.firmware_format = nil
      qe.drive_interface = "none"
      qe.net_device = "virtio-net-pci"
      qe.ssh_auto_correct = true

      bios_candidates = [
        ENV["QEMU_EDK2_CODE"],
        ENV["QEMU_EDK2_PATH"],
        ENV["QEMU_BIOS"],
        "/opt/homebrew/share/qemu/edk2-aarch64-code.fd",
        "/usr/share/AAVMF/AAVMF_CODE.fd",
        "/usr/share/AAVMF/AAVMF32_CODE.fd",
        "/usr/share/qemu/edk2-aarch64-code.fd",
        "/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw",
        "/usr/share/edk2/aarch64/QEMU_EFI.fd",
        "/usr/share/edk2-armvirt/aarch64/QEMU_EFI.fd",
        "/usr/local/share/qemu/edk2-aarch64-code.fd",
        "/opt/local/share/qemu/edk2-aarch64-code.fd",
        "C:/Program Files/qemu/share/edk2-aarch64-code.fd",
        "C:/msys64/mingw64/share/qemu/edk2-aarch64-code.fd"
      ].compact
      bios_path = bios_candidates.find { |path| File.exist?(path) }

      extra_args = []
      extra_args.push("-bios", bios_path) if bios_path
      extra_args.push(
        "-device", "pcie-root-port,id=pcie.1,chassis=1,slot=1",
        "-device", "nvme,serial=nvme0,drive=disk0,bus=pcie.1",
        "-device", "ramfb",
        "-device", "qemu-xhci",
        "-device", "usb-kbd",
        "-device", "usb-tablet"
      )
      qe.extra_qemu_args = extra_args
    else
      qe.arch = "x86_64"
      qe.machine = "q35,accel=#{accel}"
      qe.cpu = "host"
      qe.smp = "4"
      qe.memory = "4096M"
      qe.drive_interface = "ide"
      qe.net_device = "virtio-net-pci"
      qe.ssh_auto_correct = true

      ovmf_candidates = [
        ENV["QEMU_EDK2_CODE"],
        ENV["QEMU_EDK2_PATH"],
        ENV["QEMU_BIOS"],
        "/usr/share/OVMF/OVMF_CODE.fd",
        "/usr/share/OVMF/OVMF_CODE_4M.fd",
        "/usr/share/ovmf/OVMF.fd",
        "/usr/share/edk2/ovmf/OVMF_CODE.fd",
        "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd",
        "/opt/homebrew/share/qemu/edk2-x86_64-code.fd",
        "/usr/local/share/qemu/edk2-x86_64-code.fd",
        "/opt/local/share/qemu/edk2-x86_64-code.fd",
        "/usr/share/qemu/edk2-x86_64-code.fd",
        "C:/Program Files/qemu/share/edk2-x86_64-code.fd",
        "C:/msys64/mingw64/share/qemu/edk2-x86_64-code.fd"
      ].compact
      ovmf_path = ovmf_candidates.find { |path| File.exist?(path) }

      extra_args = []
      extra_args.push("-bios", ovmf_path) if ovmf_path
      extra_args.push(
        "-device", "qemu-xhci",
        "-device", "usb-kbd",
        "-device", "usb-tablet",
        "-vga", "std"
      )
      qe.extra_qemu_args = extra_args
    end
  end
end
EOF

    # Step 4: Archive into .box with maximum level-9 compression and sparse support
    log_info "Step 4: Compacting into .box with sparse block preservation & level-9 compression..."
    _tmp_box="${_target_box}.tmp"

    _tar_cmd="tar"
    _tar_sparse="--sparse"
    if command -v gtar >/dev/null 2>&1; then
      _tar_cmd="gtar"
    else
      case "$(uname -s)" in
        Darwin*) _tar_sparse="" ;;
      esac
    fi

    if command -v pigz >/dev/null 2>&1; then
      log_info "Using parallel pigz for maximum compression (-9) across all CPU cores..."
      (
        cd "${_build_files_dir}"
        if [ -n "${_tar_sparse}" ]; then
          ${_tar_cmd} "${_tar_sparse}" -I 'pigz -9' -cf "${_tmp_box}" metadata.json Vagrantfile box.img
        else
          ${_tar_cmd} -I 'pigz -9' -cf "${_tmp_box}" metadata.json Vagrantfile box.img
        fi
      )
    else
      log_info "Using gzip -9 for maximum compression..."
      (
        cd "${_build_files_dir}"
        if [ -n "${_tar_sparse}" ]; then
          GZIP="-9" ${_tar_cmd} "${_tar_sparse}" -czf "${_tmp_box}" metadata.json Vagrantfile box.img
        else
          GZIP="-9" ${_tar_cmd} -czf "${_tmp_box}" metadata.json Vagrantfile box.img
        fi
      )
    fi

    mv -f "${_tmp_box}" "${_target_box}"

    # Also build companion libvirt box with provider: libvirt to match vagrant provider convention
    _libvirt_box="${BENTO_BUILD_COMPLETE_DIR}/windows-11-${ARCH}.libvirt.box"
    if [ "${_target_box}" != "${_libvirt_box}" ]; then
      log_info "Packaging companion libvirt box (${_libvirt_box})..."
      cat << EOF > "${_build_files_dir}/metadata.json"
{
  "provider": "libvirt",
  "format": "qcow2",
  "virtual_size": ${_virt_gb}
}
EOF
      _tmp_libvirt="${_libvirt_box}.tmp"
      (
        cd "${_build_files_dir}"
        if command -v pigz >/dev/null 2>&1; then
          if [ -n "${_tar_sparse}" ]; then
            ${_tar_cmd} "${_tar_sparse}" -I 'pigz -9' -cf "${_tmp_libvirt}" metadata.json Vagrantfile box.img
          else
            ${_tar_cmd} -I 'pigz -9' -cf "${_tmp_libvirt}" metadata.json Vagrantfile box.img
          fi
        else
          if [ -n "${_tar_sparse}" ]; then
            GZIP="-9" ${_tar_cmd} "${_tar_sparse}" -czf "${_tmp_libvirt}" metadata.json Vagrantfile box.img
          else
            GZIP="-9" ${_tar_cmd} -czf "${_tmp_libvirt}" metadata.json Vagrantfile box.img
          fi
        fi
      )
      mv -f "${_tmp_libvirt}" "${_libvirt_box}"
    fi

    _box_bytes=$(get_file_size "${_target_box}")
    _box_mb=$((_box_bytes / 1024 / 1024))
    _total_saved_mb=$((_orig_mb - _box_mb))

    printf "\n"
    printf "%b================================================================%b\n" "${C_GREEN}${C_BOLD}" "${C_RESET}"
    printf "%b  WINDOWS 11 VAGRANT .BOX OPTIMIZATION SUMMARY                 %b\n" "${C_GREEN}${C_BOLD}" "${C_RESET}"
    printf "%b================================================================%b\n" "${C_GREEN}${C_BOLD}" "${C_RESET}"
    printf "  Target Box Path  : %s\n" "${_target_box}"
    printf "  Libvirt Box Path : %s\n" "${_libvirt_box}"
    printf "  Uncompressed Disk: %s MB (%s GB)\n" "${_orig_mb}" "$((_orig_mb / 1024))"
    printf "  Optimized Disk   : %s MB (%s GB)\n" "${_opt_mb}" "$((_opt_mb / 1024))"
    printf "  FINAL .BOX SIZE  : %b%s MB (%s GB)%b\n" "${C_GREEN}${C_BOLD}" "${_box_mb}" "$((_box_bytes / 1024 / 1024 / 1024))" "${C_RESET}"
    printf "  Total Reduction  : %b%s MB reclaimed%b\n" "${C_GREEN}${C_BOLD}" "${_total_saved_mb}" "${C_RESET}"
    printf "%b================================================================%b\n" "${C_GREEN}${C_BOLD}" "${C_RESET}"

  elif [ "${_provider}" = "virtualbox" ]; then
    _vdi_path=$(find "${_build_files_dir}" -name "*.vdi" 2>/dev/null | head -n 1)
    if [ -n "${_vdi_path}" ]; then
      log_info "Compacting VirtualBox VDI disk to reclaim zeroed sectors..."
      VBoxManage modifymedium disk "${_vdi_path}" --compact
    fi
    log_info "Packaging VirtualBox .box with maximum level-9 compression..."
    _tmp_box="${_target_box}.tmp"
    if command -v pigz >/dev/null 2>&1; then
      (
        cd "${_build_files_dir}"
        tar --sparse -I 'pigz -9' -cf "${_tmp_box}" ./*
      )
    else
      (
        cd "${_build_files_dir}"
        GZIP="-9" tar --sparse -czf "${_tmp_box}" ./*
      )
    fi
    mv -f "${_tmp_box}" "${_target_box}"
    _box_bytes=$(get_file_size "${_target_box}")
    log_success "Created optimized box: ${_target_box} ($((_box_bytes / 1024 / 1024)) MB)"
  fi

  # Auto-register box locally into Vagrant
  cmd_register "${_provider}"
}

# Register built box into local Vagrant inventory as bento/windows-11
cmd_register() {
  _provider="${1:-${PROVIDER}}"
  if ! command -v vagrant >/dev/null 2>&1; then
    log_warn "Vagrant CLI not found in PATH. Skipping local box registration."
    return 0
  fi

  log_info "Registering Windows 11 box into local Vagrant inventory as 'bento/windows-11'..."
  _qemu_box="${BENTO_BUILD_COMPLETE_DIR}/windows-11-${ARCH}.qemu.box"
  _libvirt_box="${BENTO_BUILD_COMPLETE_DIR}/windows-11-${ARCH}.libvirt.box"
  _vbox_box="${BENTO_BUILD_COMPLETE_DIR}/windows-11-${ARCH}.virtualbox.box"

  if [ "${_provider}" = "qemu" ]; then
    if [ -f "${_qemu_box}" ]; then
      log_info "Adding ${_qemu_box} as 'bento/windows-11' (qemu)..."
      vagrant box add --name "bento/windows-11" "${_qemu_box}" --force
    fi
    if [ -f "${_libvirt_box}" ]; then
      log_info "Adding ${_libvirt_box} as 'bento/windows-11' (libvirt)..."
      vagrant box add --name "bento/windows-11" "${_libvirt_box}" --force
    fi
  elif [ "${_provider}" = "virtualbox" ]; then
    if [ -f "${_vbox_box}" ]; then
      log_info "Adding ${_vbox_box} as 'bento/windows-11' (virtualbox)..."
      vagrant box add --name "bento/windows-11" "${_vbox_box}" --force
    fi
  fi

  log_success "Vagrant box registration complete. Current Windows 11 Vagrant boxes:"
  vagrant box list | grep -i "windows-11" || true
}

# Main build execution
cmd_build() {
  log_info "Starting Windows 11 Build Pipeline:"
  printf "  Architecture : %s\n" "${ARCH}"
  printf "  Provider     : %s\n" "${PROVIDER}"
  printf "  Headless     : %s\n" "${HEADLESS}"
  printf "  Debug        : %s\n" "${DEBUG_MODE}"
  if [ "${HEADLESS}" = "false" ]; then
    log_info "GUI Mode     : Active (QEMU graphical window will open automatically)"
  else
    log_info "GUI Mode     : Headless (view live via 'open vnc://127.0.0.1:<port>')"
  fi

  # 1. Clean prior locks and processes
  cmd_clean

  # Ensure VirtIO drivers are present for Windows guest
  ensure_cidata

  # Ensure OEM unattended volume is prepared
  ensure_oem_iso

  # 2. Check and locate ISO
  _iso_path="$(find_iso)"
  if [ -z "${_iso_path}" ]; then
    log_warn "No Windows 11 ISO found locally. Packer will use the remote URL in pkrvars."
  else
    log_info "Using local Windows 11 ISO: ${_iso_path} ($(du -h "${_iso_path}" | cut -f1))"
  fi

  # 3. Setup background serial port multiplexer and logger
  start_serial_proxy

  # 4. If stream serial requested, tail serial.log in background
  if [ "${STREAM_SERIAL}" = "true" ]; then
    log_info "Live serial output streaming enabled. Displaying serial log:"
    tail -f "${SERIAL_LOG}" &
    TAIL_PID=$!
    trap 'kill "${TAIL_PID}" 2>/dev/null || true' EXIT INT TERM
  fi

  # 5. Dedicated Windows 11 ARM64 build pipeline if available
  if [ "${ARCH}" = "aarch64" ] && [ "${PROVIDER}" = "qemu" ] && [ -f "${SCRIPT_DIR}/windows-11-arm64-packer/build.sh" ]; then
    log_info "Executing dedicated Windows 11 ARM64 QEMU build pipeline..."
    HEADLESS="${HEADLESS}" DEBUG_MODE="${DEBUG_MODE}" STEP_MODE="${STEP_MODE}" "${SCRIPT_DIR}/windows-11-arm64-packer/build.sh"
    cmd_box "${PROVIDER}"
    log_success "Windows 11 build and box creation completed successfully!"
    return 0
  fi

  # 6. Locate pkrvars for generic pipeline
  _pkrvars="${SCRIPT_DIR}/os_pkrvars/windows/windows-11-${ARCH}.pkrvars.hcl"
  if [ ! -f "${_pkrvars}" ]; then
    log_error "Configuration file ${_pkrvars} does not exist."
    exit 1
  fi

  log_info "Validating Packer templates..."
  packer validate -var-file="${_pkrvars}" "${SCRIPT_DIR}/packer_templates"

  log_info "Executing Packer Build for Windows 11 (${PROVIDER})..."
  set -- -timestamp-ui -force -var-file="${_pkrvars}"

  _effective_iso="${CUSTOM_ISO:-${_iso_path}}"
  if [ -n "${_effective_iso}" ]; then
    set -- "$@" -var "iso_url=file://${_effective_iso}"
    if [ -s "${_effective_iso}.sha256" ]; then
      set -- "$@" -var "iso_checksum=$(cat "${_effective_iso}.sha256")"
    elif [ -n "${PKR_VAR_iso_checksum:-}" ]; then
      set -- "$@" -var "iso_checksum=${PKR_VAR_iso_checksum}"
    fi
  fi

  if [ "${PROVIDER}" = "qemu" ]; then
    set -- "$@" "-only=qemu.vm"
    if [ -n "${PKR_VAR_win11_oem_iso:-}" ]; then
      set -- "$@" -var "win11_oem_iso=${PKR_VAR_win11_oem_iso}"
    fi
  elif [ "${PROVIDER}" = "virtualbox" ]; then
    set -- "$@" "-only=virtualbox-iso.vm"
  fi

  set -- "$@" -var "headless=${HEADLESS}"
  set -- "$@" -var "cpus=${VM_CPUS}" -var "memory=${VM_MEM}"

  _key="${WIN11_PRODUCT_KEY:-${WINDOWS_PRODUCT_KEY:-${PKR_VAR_windows_product_key:-}}}"
  if [ -n "${_key}" ]; then
    set -- "$@" -var "windows_product_key=${_key}"
  fi
  if [ -n "${QEMU_EDK2_CODE:-}" ]; then
    set -- "$@" -var "qemu_efi_firmware_code=${QEMU_EDK2_CODE}"
  fi
  if [ -n "${QEMU_EDK2_VARS:-}" ]; then
    set -- "$@" -var "qemu_efi_firmware_vars=${QEMU_EDK2_VARS}"
  fi
  if [ -n "${INSTALL_WINDOWS_UPDATES:-}" ]; then
    set -- "$@" -var "install_windows_updates=${INSTALL_WINDOWS_UPDATES}"
  fi
  if [ "${DEBUG_MODE}" = "true" ]; then
    export PACKER_LOG=1
  fi
  if [ "${STEP_MODE}" = "true" ]; then
    set -- "$@" -debug
  fi

  log_info "Running: packer build $* ${SCRIPT_DIR}/packer_templates"
  packer build "$@" "${SCRIPT_DIR}/packer_templates"

  # 7. Apply post-build multi-stage size optimizations
  cmd_box "${PROVIDER}"

  log_success "Windows 11 build and box creation completed successfully!"
}

# Main Entrypoint
case "${COMMAND}" in
  build)    cmd_build ;;
  box)      cmd_box "${PROVIDER}" ;;
  register) cmd_register "${PROVIDER}" ;;
  run)      cmd_run ;;
  serial)   cmd_serial ;;
  snapshot) cmd_snapshot ;;
  status)   cmd_status ;;
  clean)    cmd_clean ;;
  *)
    log_error "Unknown command: ${COMMAND}"
    exit 1
    ;;
esac
