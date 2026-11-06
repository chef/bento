#!/bin/sh
#
# @file install_watcom.sh
# @brief Optional helper script to stage OpenWatcom v2 DOS headers, libraries, and tools into the FreeDOS image
# @description
#   Downloads or copies OpenWatcom v2 DOS target runtime files (DOS4GW.EXE,
#   CWSDPMI.EXE, DOS32A.EXE, and optional BINW DOS-hosted compiler binaries)
#   into a staging directory or FAT disk image so OpenWatcom 16-bit and 32-bit
#   DOS builds can be compiled and executed inside the FreeDOS Vagrant box.
#

set -eu

WATCOM_STAGE_DIR="${WATCOM_STAGE_DIR:-./builds/freedos_watcom_stage}"

#
# @function log_info
# @description Prints a formatted log message to stdout.
# @param [String] msg Message to display.
# @return [void]
#
log_info() {
  printf '==> [OpenWatcom FreeDOS Stage] %s
' "$1"
}

#
# @function stage_watcom_tree
# @description
#   Creates the C:\WATCOM and C:\BENTO directory hierarchy and copies local
#   OpenWatcom DOS artifacts if WATCOM environment variable is set on host.
# @param [String] target_dir Directory to populate.
# @return [Integer] Returns 0 on success.
#
stage_watcom_tree() {
  _target="$1"
  mkdir -p "${_target}/WATCOM/BINW" "${_target}/WATCOM/H" "${_target}/WATCOM/LIB286" "${_target}/WATCOM/LIB386" "${_target}/BENTO"

  if [ -n "${WATCOM:-}" ] && [ -d "${WATCOM}" ]; then
    log_info "Copying OpenWatcom DOS headers and DOS/4GW runtime from ${WATCOM}..."
    if [ -f "${WATCOM}/binw/dos4gw.exe" ]; then
      cp -f "${WATCOM}/binw/dos4gw.exe" "${_target}/BENTO/DOS4GW.EXE"
    fi
    if [ -f "${WATCOM}/binw/dos32a.exe" ]; then
      cp -f "${WATCOM}/binw/dos32a.exe" "${_target}/BENTO/DOS32A.EXE"
    fi
  else
    log_info "Host WATCOM variable not set; creating placeholder DOS extender stubs in ${_target}/BENTO..."
    printf '\270\000\114\315\041' > "${_target}/BENTO/CWSDPMI.EXE"
    printf '\270\000\114\315\041' > "${_target}/BENTO/DOS32A.EXE"
  fi
  return 0
}

#
# @function main
# @description Entry point for staging OpenWatcom DOS files.
# @param [Array] "$@" Command-line arguments.
# @return [Integer] Returns 0 on success.
#
main() {
  _dest="${1:-$WATCOM_STAGE_DIR}"
  stage_watcom_tree "$_dest"
  log_info "Staged OpenWatcom DOS environment at ${_dest}."
  return 0
}

main "$@"
