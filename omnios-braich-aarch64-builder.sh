#!/bin/sh
#
# @file omnios-braich-aarch64-builder.sh
# @brief Automated download, image preparation, and Vagrant box build script for OmniOS ARM64 (Project Braich)
# @description
#   Coordinates the acquisition and pre-processing of OmniOS Community Edition
#   Project Braich experimental ARM64 artifacts. Downloads the zstd-compressed
#   raw disk image and U-Boot firmware from the official media server, verifies
#   SHA-256 checksum integrity, decompresses the image using zstd, converts
#   the disk format to qcow2 if required, and executes the Bento/Packer QEMU
#   builder to produce a Vagrant .box artifact.
#

set -eu

# Configuration variables
BRAICH_VERSION="151059"
RAW_IMAGE_FILENAME="braich-${BRAICH_VERSION}.raw.zst"
UBOOT_FILENAME="u-boot.bin"
DOWNLOAD_BASE_URL="https://downloads.omnios.org/media/braich"
EXPECTED_IMAGE_SHA256="c6e8faed3d9b1a747a827fbef21101100f1fc148ef19e821ffbf1491f45230b5"
EXPECTED_UBOOT_SHA256="3aa554094ffe1d86d7f9637e548d07df804f5034c32ac3da542ee8da6e2e783e"

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
CACHE_DIR="${SCRIPT_DIR}/builds/iso"
PKR_DIR="${SCRIPT_DIR}/os_pkrvars/omnios"
PKR_VARS_FILE="${PKR_DIR}/omnios-braich-aarch64.pkrvars.hcl"

#
# @function banner
# @description
#   Prints a formatted section banner header to standard output.
# @param [String] message The banner message to print.
# @return [void]
#
banner() {
  printf '==> %s
' "$1"
}

#
# @function check_prerequisites
# @description
#   Verifies that required command-line utilities are available in PATH.
# @noargs
# @return [Integer] Returns 0 if all tools are present, exits 1 otherwise.
#
check_prerequisites() {
  banner "Verifying build prerequisites..."
  for tool in curl zstd qemu-img packer; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      printf 'Error: Required utility "%s" is not installed or not in PATH.
' "$tool" >&2
      exit 1
    fi
  done
}

#
# @function calculate_sha256
# @description
#   Computes the SHA-256 checksum of a file using sha256sum or shasum.
# @param [String] file_path Path to the target file.
# @return [String] Prints the calculated hex hash string.
#
calculate_sha256() {
  _file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$_file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$_file" | awk '{print $1}'
  else
    printf 'Error: Neither sha256sum nor shasum available.
' >&2
    exit 1
  fi
}

#
# @function fetch_and_verify
# @description
#   Downloads a remote file if not already cached and verifies its SHA-256 hash.
# @param [String] filename File name to download and cache.
# @param [String] expected_hash Expected SHA-256 checksum hex string.
# @return [void]
#
fetch_and_verify() {
  _filename="$1"
  _expected="$2"
  _dest="${CACHE_DIR}/${_filename}"

  mkdir -p "$CACHE_DIR"

  if [ -f "$_dest" ]; then
    banner "Verifying cached file: ${_filename}..."
    _actual=$(calculate_sha256 "$_dest")
    if [ "$_actual" != "$_expected" ]; then
      printf 'Cached hash mismatch for %s. Expected: %s, got: %s. Re-downloading.
' "$_filename" "$_expected" "$_actual"
      rm -f "$_dest"
    fi
  fi

  if [ ! -f "$_dest" ]; then
    banner "Downloading ${_filename} from ${DOWNLOAD_BASE_URL}..."
    curl --fail --location --retry 3 --output "$_dest" "${DOWNLOAD_BASE_URL}/${_filename}"
    _actual=$(calculate_sha256 "$_dest")
    if [ "$_actual" != "$_expected" ]; then
      printf 'Downloaded hash mismatch for %s. Expected: %s, got: %s.
' "$_filename" "$_expected" "$_actual" >&2
      exit 1
    fi
  fi
}

#
# @function decompress_raw_image
# @description
#   Decompresses the zstd-compressed raw disk image into uncompressed .raw and .qcow2 formats.
# @noargs
# @return [String] Path to prepared disk image.
#
decompress_raw_image() {
  _compressed="${CACHE_DIR}/${RAW_IMAGE_FILENAME}"
  _raw="${CACHE_DIR}/braich-${BRAICH_VERSION}.raw"
  _qcow2="${CACHE_DIR}/braich-${BRAICH_VERSION}.qcow2"

  if [ ! -f "$_raw" ]; then
    banner "Decompressing raw image using zstd..."
    zstd -d -f "$_compressed" -o "$_raw"
  fi

  if [ ! -f "$_qcow2" ]; then
    banner "Converting raw image to qcow2 format for QEMU / UTM..."
    qemu-img convert -f raw -O qcow2 "$_raw" "$_qcow2"
  fi

  # Place u-boot.bin in packer execution directory if needed
  if [ -f "${CACHE_DIR}/${UBOOT_FILENAME}" ]; then
    cp -f "${CACHE_DIR}/${UBOOT_FILENAME}" "${SCRIPT_DIR}/${UBOOT_FILENAME}"
  fi
}

#
# @function run_build
# @description
#   Invokes the Bento build orchestrator for OmniOS Braich aarch64.
# @noargs
# @return [void]
#
run_build() {
  banner "Executing Bento build for OmniOS Braich (aarch64)..."
  if [ -f "${SCRIPT_DIR}/bin/bento" ]; then
    bundle exec "${SCRIPT_DIR}/bin/bento" build -o qemu.vm "$PKR_VARS_FILE"
  else
    packer build -only=qemu.vm -var-file="$PKR_VARS_FILE" "${SCRIPT_DIR}/packer_templates"
  fi
}

#
# @function main
# @description
#   Coordinates full preparation and build lifecycle for OmniOS aarch64 box.
# @noargs
# @return [Integer] Returns 0 on completion.
#
main() {
  banner "OmniOS Braich (ARM64) Base Box Automated Builder"
  check_prerequisites
  fetch_and_verify "$RAW_IMAGE_FILENAME" "$EXPECTED_IMAGE_SHA256"
  fetch_and_verify "$UBOOT_FILENAME" "$EXPECTED_UBOOT_SHA256"
  decompress_raw_image
  run_build
  banner "Build process completed successfully."
}

main "$@"
