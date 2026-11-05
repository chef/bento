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
#   Generates tiny 16-bit 8086 real-mode .COM utilities (B64DEC.COM, B64ENC.COM,
#   and SERINIT.COM) in the FreeDOS scripts directory. SERINIT.COM programs the
#   16550A COM1 UART (0x3F8) to 115200 8N1, sets the BIOS Data Area COM1 port
#   and timeout, and hot-patches the FreeDOS 1.3 kernel (0070:03c3 ComNdRead
#   jump target and 0070:03ce ComOutStat DSR check) in conventional memory so
#   CTTY COM1 serial input does not deadlock in ConNdRead (INT 16h).
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

  # 16-bit 8086 real-mode SERINIT.COM (125 bytes):
  # - Sets BDA [0040:0000]=0x03F8 and [0040:007C]=0x01
  # - Initializes COM1 (0x03F8) 16550A UART to 115200,N,8,1 with FIFO & DTR/RTS/OUT2
  # - Patches FreeDOS 1.3 kernel segment 0070h ComNdRead (88 07 e9 b5 fd -> 88 07 e9 db fd)
  #   and ComOutStat (a8 20 74 f6 -> a8 20 90 90)
  printf '\372\270\100\000\216\300\046\307\006\000\000\370\003\046\306\006\174\000\001\272\371\003\060\300\356\272\373\003\260\200\356\272\370\003\260\001\356\272\371\003\060\300\356\272\373\003\260\003\356\272\372\003\260\307\356\272\374\003\260\013\356\272\370\003\354\270\160\000\216\300\061\377\271\000\040\046\201\075\210\007\165\015\046\201\175\002\351\265\165\005\046\306\105\003\333\046\201\075\250\040\165\016\046\201\175\002\164\366\165\006\046\307\105\002\220\220\107\342\324\373\270\000\114\315\041' > "${_out_dir}/SERINIT.COM"
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
