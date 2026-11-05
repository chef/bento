#!/bin/sh
#
# @file build_msdos_from_source.sh
# @brief Fetches, normalizes, and stages Microsoft MS-DOS (v1.25, v2.0, v4.0) from https://github.com/microsoft/ms-dos
# @description
#   Downloads the upstream microsoft/ms-dos archive into builds/iso/, verifies
#   the v1.25, v2.0, and v4.0 directory trees, normalizes line endings and
#   strips trailing 0x1A (Ctrl-Z) EOF markers in v4.0/src so MASM/CL/NMAKE can
#   compile cleanly, and stages the version-specific binaries, sources, and
#   development tools (MASM, CL, LINK, NMAKE, EXE2BIN) into a target directory.
#

set -eu

MSDOS_REPO_URL="${MSDOS_REPO_URL:-https://github.com/microsoft/MS-DOS/archive/refs/heads/main.tar.gz}"
SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)
BUILDS_DIR="${REPO_ROOT}/builds"
ISO_DIR="${BUILDS_DIR}/iso"
ARCHIVE_PATH="${ISO_DIR}/microsoft-ms-dos.tar.gz"
EXTRACT_ROOT="${BUILDS_DIR}/msdos_upstream"

#
# @function log_msg
# @description Prints a formatted build status message to standard output.
# @param [String] message The status message to print.
# @return [void]
#
log_msg() {
  printf '==> [MS-DOS Source Builder] %s
' "$1"
}

#
# @function fetch_msdos_repo
# @description
#   Downloads the microsoft/ms-dos tarball into builds/iso/microsoft-ms-dos.tar.gz
#   if not already cached and extracts it to builds/msdos_upstream.
# @noargs
# @return [Integer] Returns 0 on success.
#
fetch_msdos_repo() {
  mkdir -p "$ISO_DIR" "$EXTRACT_ROOT"

  if [ "${BENTO_DRY_RUN:-0}" = "1" ]; then
    log_msg "[Dry-Run] Fetching ${MSDOS_REPO_URL} -> ${ARCHIVE_PATH}"
    mkdir -p "${EXTRACT_ROOT}/v1.25/bin" "${EXTRACT_ROOT}/v1.25/source"
    mkdir -p "${EXTRACT_ROOT}/v2.0/bin" "${EXTRACT_ROOT}/v2.0/source"
    mkdir -p "${EXTRACT_ROOT}/v4.0/src/TOOLS"
    return 0
  fi

  if [ ! -f "$ARCHIVE_PATH" ]; then
    log_msg "Downloading microsoft/ms-dos archive from ${MSDOS_REPO_URL}..."
    curl -fL --retry 3 -o "${ARCHIVE_PATH}.part" "$MSDOS_REPO_URL"
    mv "${ARCHIVE_PATH}.part" "$ARCHIVE_PATH"
  else
    log_msg "Using cached microsoft/ms-dos archive: ${ARCHIVE_PATH}"
  fi

  if [ ! -d "${EXTRACT_ROOT}/v1.25" ] || [ ! -d "${EXTRACT_ROOT}/v2.0" ] || [ ! -d "${EXTRACT_ROOT}/v4.0" ]; then
    log_msg "Extracting microsoft/ms-dos archive to ${EXTRACT_ROOT}..."
    tar -xzf "$ARCHIVE_PATH" --strip-components=1 -C "$EXTRACT_ROOT"
  fi
  return 0
}

#
# @function normalize_v4_sources
# @description
#   Normalizes text files inside v4.0/src by converting LF to DOS CRLF and
#   stripping trailing 0x1A (Ctrl-Z) characters that cause NMAKE and MASM
#   errors during MS-DOS 4.0 compilation.
# @param [String] src_dir Path to the v4.0/src directory.
# @return [Integer] Returns 0 on success.
#
normalize_v4_sources() {
  _src_dir="$1"
  if [ ! -d "$_src_dir" ]; then
    return 0
  fi

  log_msg "Normalizing CRLF and stripping Ctrl-Z (0x1A) EOF markers in ${_src_dir}..."
  find "$_src_dir" -type f \( -iname "*.asm" -o -iname "*.inc" -o -iname "*.c" -o -iname "*.h" -o -iname "*.bat" -o -iname "*.mak" -o -iname "makefile" -o -iname "*.skl" -o -iname "*.msg" \) | while IFS= read -r _f; do
    tr -d '\032' < "$_f" | awk '{ sub(/\015$/, ""); printf "%s\015\012", $0 }' > "${_f}.tmp" && mv "${_f}.tmp" "$_f"
  done
  return 0
}

#
# @function stage_msdos_version
# @description
#   Stages the requested MS-DOS version (1.25, 2.0, or 4.0) into the target
#   staging directory ready for injection onto a FAT12/FAT16 bootable disk image.
# @param [String] version MS-DOS version ("1.25", "2.0", or "4.0").
# @param [String] stage_dir Destination directory on the host.
# @return [Integer] Returns 0 on success.
#
stage_msdos_version() {
  _ver="$1"
  _stage="$2"
  mkdir -p "$_stage"

  case "$_ver" in
    1.25)
      log_msg "Staging MS-DOS 1.25 binaries and sources (flat root layout) into ${_stage}..."
      if [ -d "${EXTRACT_ROOT}/v1.25/bin" ]; then
        cp -Rf "${EXTRACT_ROOT}/v1.25/bin/"* "$_stage/" 2>/dev/null || true
      fi
      if [ -d "${EXTRACT_ROOT}/v1.25/source" ]; then
        cp -Rf "${EXTRACT_ROOT}/v1.25/source/"* "$_stage/" 2>/dev/null || true
      fi
      ;;
    2.0)
      log_msg "Staging MS-DOS 2.0 binaries and sources into ${_stage}/DOS and ${_stage}/SRC..."
      mkdir -p "${_stage}/DOS" "${_stage}/SRC" "${_stage}/BENTO" "${_stage}/TEMP"
      if [ -d "${EXTRACT_ROOT}/v2.0/bin" ]; then
        cp -Rf "${EXTRACT_ROOT}/v2.0/bin/"* "${_stage}/DOS/" 2>/dev/null || true
        if [ -f "${EXTRACT_ROOT}/v2.0/bin/COMMAND.COM" ]; then
          cp -f "${EXTRACT_ROOT}/v2.0/bin/COMMAND.COM" "${_stage}/COMMAND.COM"
        fi
        if [ -f "${EXTRACT_ROOT}/v2.0/bin/MSDOS.SYS" ]; then
          cp -f "${EXTRACT_ROOT}/v2.0/bin/MSDOS.SYS" "${_stage}/MSDOS.SYS"
        fi
      fi
      if [ -d "${EXTRACT_ROOT}/v2.0/source" ]; then
        cp -Rf "${EXTRACT_ROOT}/v2.0/source/"* "${_stage}/SRC/" 2>/dev/null || true
      fi
      ;;
    4.0|4.00)
      log_msg "Staging MS-DOS 4.0 sources and 16-bit build toolchain into ${_stage}..."
      mkdir -p "${_stage}/DOS" "${_stage}/TOOLS" "${_stage}/BENTO" "${_stage}/TEMP"
      if [ -d "${EXTRACT_ROOT}/v4.0/src" ] && [ "${BENTO_DRY_RUN:-0}" != "1" ]; then
        normalize_v4_sources "${EXTRACT_ROOT}/v4.0/src"
        if [ -d "${EXTRACT_ROOT}/v4.0/src/TOOLS" ]; then
          cp -Rf "${EXTRACT_ROOT}/v4.0/src/TOOLS/"* "${_stage}/TOOLS/" 2>/dev/null || true
        fi
        for _script_f in SETENV.BAT RUNME.BAT CPY.BAT MAKEFILE; do
          if [ -f "${EXTRACT_ROOT}/v4.0/src/${_script_f}" ]; then
            cp -f "${EXTRACT_ROOT}/v4.0/src/${_script_f}" "${_stage}/DOS/${_script_f}"
          fi
        done
      fi
      ;;
    *)
      log_msg "Unknown MS-DOS version '${_ver}'; defaulting to 4.0."
      ;;
  esac
  return 0
}

#
# @function main
# @description
#   CLI entry point for fetching and staging a specific MS-DOS version.
# @param [String] version Target MS-DOS version (default "4.0").
# @param [String] target_dir Target staging directory (default builds/msdos_stage_<ver>).
# @return [Integer] Returns 0 on success.
#
main() {
  _version="${1:-4.0}"
  _target_dir="${2:-${BUILDS_DIR}/msdos_stage_${_version}}"
  fetch_msdos_repo
  stage_msdos_version "$_version" "$_target_dir"
  return 0
}

main "$@"
