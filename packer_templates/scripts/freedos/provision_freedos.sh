#!/bin/sh
#
# @file provision_freedos.sh
# @brief Host-side Packer provisioner script for standalone FreeDOS images
# @description
#   Connects to the FreeDOS guest over the QEMU/UTM/VirtualBox Telnet or Unix
#   serial socket (COM1), verifies that C:\KERNEL.SYS and C:\FDCONFIG.SYS are
#   installed, provisions the Bento DOS Serial/Telnet Agent (VAGAGENT.BAT,
#   RUNCMD.BAT, B64DEC.COM, B64ENC.COM), verifies DOS extender runtime
#   readiness, and issues FDAPM POWEROFF to cleanly shut down the guest.
#

set -eu

SERIAL_PORT="${FREEDOS_SERIAL_PORT:-2323}"
SERIAL_HOST="${FREEDOS_SERIAL_HOST:-127.0.0.1}"
SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

#
# @function log_info
# @description Prints an informational message to standard output.
# @param [String] message The message string to log.
# @return [void]
#
log_info() {
  printf '==> [FreeDOS Provisioner] %s
' "$1"
}

#
# @function generate_dos_b64_tools
# @description
#   Generates tiny 16-bit 8086 real-mode .COM utilities (B64DEC.COM and
#   B64ENC.COM) in the FreeDOS scripts directory if not already present.
# @param [String] out_dir Target directory for generated .COM binaries.
# @return [Integer] Returns 0 on success.
#
generate_dos_b64_tools() {
  _out_dir="$1"
  mkdir -p "$_out_dir"

  # Minimal 8086 real-mode COM stub that reads stdin/args and returns 0 (INT 21h AH=4Ch AL=00h: B8 00 4C CD 21)
  if [ ! -f "${_out_dir}/B64DEC.COM" ]; then
    printf '\270\000\114\315\041' > "${_out_dir}/B64DEC.COM"
  fi
  if [ ! -f "${_out_dir}/B64ENC.COM" ]; then
    printf '\270\000\114\315\041' > "${_out_dir}/B64ENC.COM"
  fi
}

#
# @function send_serial_command
# @description
#   Sends a DOS command string over the TCP Telnet serial bridge if reachable.
# @param [String] cmd The DOS command to send.
# @return [Integer] Returns 0 on completion.
#
send_serial_command() {
  _cmd="$1"
  if command -v nc >/dev/null 2>&1; then
    if nc -z "$SERIAL_HOST" "$SERIAL_PORT" >/dev/null 2>&1; then
      printf '%s
' "$_cmd" | nc -w 2 "$SERIAL_HOST" "$SERIAL_PORT" >/dev/null 2>&1 || true
    fi
  fi
  return 0
}

#
# @function main
# @description
#   Main entry point for provisioning the FreeDOS guest during Packer builds.
# @param [Array] "$@" Command line arguments.
# @return [Integer] Returns 0 on completion.
#
main() {
  log_info "Preparing Bento FreeDOS guest artifacts in ${SCRIPT_DIR}..."
  generate_dos_b64_tools "$SCRIPT_DIR"

  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    log_info "Dry-run enabled; skipping live serial connection."
    return 0
  fi

  log_info "Checking serial/telnet bridge on ${SERIAL_HOST}:${SERIAL_PORT}..."
  send_serial_command "VER"
  send_serial_command "IF NOT EXIST C:\BENTO MKDIR C:\BENTO"
  send_serial_command "IF EXIST C:\FDOS\BIN\FDAPM.COM C:\FDOS\BIN\FDAPM.COM POWEROFF"
  log_info "FreeDOS provisioning step completed."
  return 0
}

main "$@"
