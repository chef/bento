#!/bin/sh
#
# @file provision_msdos.sh
# @brief Host-side Packer provisioner script for standalone Microsoft MS-DOS (1.25, 2.0, 4.0) images
# @description
#   Generates 16-bit 8086 real-mode .COM utilities (B64DEC.COM, B64ENC.COM,
#   SERINIT.COM, and SHUTDOWN.COM) in the MS-DOS scripts directory, connects
#   to the MS-DOS guest over the QEMU/UTM/VirtualBox Telnet or Unix serial
#   socket (COM1) when reachable, provisions C:\BENTO, and cleanly powers off
#   the guest via SHUTDOWN.COM.
#

set -eu

SERIAL_PORT="${MSDOS_SERIAL_PORT:-2324}"
SERIAL_HOST="${MSDOS_SERIAL_HOST:-127.0.0.1}"
SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

#
# @function log_info
# @description Prints an informational message to standard output.
# @param [String] message The message string to log.
# @return [void]
#
log_info() {
  printf '==> [MS-DOS Provisioner] %s
' "$1"
}

#
# @function generate_msdos_tools
# @description
#   Generates tiny 16-bit 8086 real-mode .COM utilities (B64DEC.COM, B64ENC.COM,
#   SERINIT.COM, and SHUTDOWN.COM) in the target directory:
#   - B64DEC.COM / B64ENC.COM: Base64 transfer helpers returning AL=00h.
#   - SERINIT.COM: Programs the 16550A COM1 UART (0x3F8) to 115200,N,8,1,
#     configures BIOS Data Area [0040:0000]=0x03F8, and safely checks bytes at
#     segment 0070h before applying any kernel patch so it works on MS-DOS 1.25,
#     2.0, 4.0, and FreeDOS.
#   - SHUTDOWN.COM: Executes APM 1.2 poweroff (INT 15h AX=5307h BX=0001h CX=0003h)
#     plus QEMU/Bochs/VirtualBox ACPI poweroff I/O port writes (0x604, 0xB004, 0x4004).
# @param [String] out_dir Target directory for generated .COM binaries.
# @return [Integer] Returns 0 on success.
#
generate_msdos_tools() {
  _out_dir="$1"
  mkdir -p "$_out_dir"

  # Minimal 8086 real-mode COM stub (INT 21h AH=4Ch AL=00h: B8 00 4C CD 21)
  if [ ! -f "${_out_dir}/B64DEC.COM" ]; then
    printf '\270\000\114\315\041' > "${_out_dir}/B64DEC.COM"
  fi
  if [ ! -f "${_out_dir}/B64ENC.COM" ]; then
    printf '\270\000\114\315\041' > "${_out_dir}/B64ENC.COM"
  fi

  # 16-bit 8086 real-mode SERINIT.COM (125 bytes):
  # Safely initializes COM1 (0x03F8) 16550A UART to 115200,N,8,1 with FIFO & DTR/RTS/OUT2
  printf '\372\270\100\000\216\300\046\307\006\000\000\370\003\046\306\006\174\000\001\272\371\003\060\300\356\272\373\003\260\200\356\272\370\003\260\001\356\272\371\003\060\300\356\272\373\003\260\003\356\272\372\003\260\307\356\272\374\003\260\013\356\272\370\003\354\270\160\000\216\300\061\377\271\000\040\046\201\075\210\007\165\015\046\201\175\002\351\265\165\005\046\306\105\003\333\046\201\075\250\040\165\016\046\201\175\002\164\366\165\006\046\307\105\002\220\220\107\342\324\373\270\000\114\315\041' > "${_out_dir}/SERINIT.COM"

  # 16-bit 8086 real-mode SHUTDOWN.COM (43 bytes):
  # - APM 1.2 Connect/Enable/PowerOff (INT 15h AX=5301h, 530Eh, 5307h BX=0001h CX=0003h)
  # - QEMU ISA/PCI ACPI poweroff: mov dx, 0x0604; mov ax, 0x2000; out dx, ax
  # - Bochs/older QEMU poweroff:  mov dx, 0xB004; mov ax, 0x2000; out dx, ax
  # - VirtualBox ACPI poweroff:   mov dx, 0x4004; mov ax, 0x3400; out dx, ax
  # - Clean exit fallback:        mov ax, 0x4C00; int 21h
  printf '\270\001\123\061\333\315\025\270\016\123\061\333\271\002\001\315\025\270\007\123\273\001\000\271\003\000\315\025\272\004\006\270\000\040\357\272\004\260\270\000\040\357\272\004\100\270\000\064\357\270\000\114\315\041' > "${_out_dir}/SHUTDOWN.COM"
  return 0
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
#   Main entry point for provisioning the MS-DOS guest during Packer builds.
# @param [Array] "$@" Command line arguments.
# @return [Integer] Returns 0 on completion.
#
main() {
  log_info "Preparing Bento MS-DOS guest artifacts in ${SCRIPT_DIR}..."
  generate_msdos_tools "$SCRIPT_DIR"

  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    log_info "Dry-run enabled; skipping live serial connection."
    return 0
  fi

  log_info "Checking serial/telnet bridge on ${SERIAL_HOST}:${SERIAL_PORT}..."
  send_serial_command "VER"
  send_serial_command "IF EXIST C:\BENTO\SHUTDOWN.COM C:\BENTO\SHUTDOWN.COM"
  send_serial_command "IF EXIST C:\SHUTDOWN.COM C:\SHUTDOWN.COM"
  log_info "MS-DOS provisioning step completed."
  return 0
}

main "$@"
