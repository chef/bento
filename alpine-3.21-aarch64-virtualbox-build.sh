#!/bin/sh

if [ ! -z "${BASH_VERSION+x}" ]; then
  this_file="${BASH_SOURCE[0]}"
  set -o pipefail
elif [ ! -z "${ZSH_VERSION+x}" ]; then
  this_file="${(%):-%x}"
  set -o pipefail
else
  this_file="${0}"
fi
set -feu

export ARCH="${ARCH:-aarch64}"
export VERSION="${VERSION:-3.21.2}"
export VERSION_MAJOR_MINOR="${VERSION%.*}"

# Getting script directory location
SCRIPT_RELATIVE_DIR=$(dirname -- "${this_file}")
cd -- "$SCRIPT_RELATIVE_DIR" || exit

# set tmp dir for files
ALPDIR="$(pwd)/builds/build_files/alpine-${VERSION}-${ARCH}-virtualbox"
[ -d "$ALPDIR" ] || mkdir -p -- "$ALPDIR"

echo "Cleaning up old files"
set +f
rm -f -- "$ALPDIR"/*.iso "$ALPDIR"/*.ovf "$ALPDIR"/*.vmdk "$ALPDIR"/*.vdi

NAME='generic_alpine-'"${VERSION}"'-'"${ARCH}"'-uefi-tiny-r0'
export QCOW="${NAME}"'.qcow2'
export VMDK="${NAME}"'.vmdk'
export VDI="${NAME}"'.vdi'

if [ ! -f "$ALPDIR"'/'"${QCOW}" ]; then
    wget -q -O -- "$ALPDIR"'/'"${QCOW}" 'https://dl-cdn.alpinelinux.org/alpine/v'"${VERSION_MAJOR_MINOR}"'/releases/cloud/'"${QCOW}"
fi

if [ ! -f "${VMDK}" ]; then
    qemu-img convert -f qcow2 -O vmdk -- "$ALPDIR"'/'"${QCOW}" "$ALPDIR"'/'"${VMDK}" # &
fi

if [ ! -f "${VMDK}" ]; then
  qemu-img convert -f qcow2 -O vdi    -- "$ALPDIR"'/'"${QCOW}" "$ALPDIR"'/'"${VDI}" # &
fi

wait

echo "starting packer build of alpine ${VERSION} for ${ARCH}"
if bento build --vars 'ssh_timeout=60m' --vars vbox_source_path="$ALPDIR"/alpine_arm64.ovf,vbox_checksum=null "$(pwd)"/os_pkrvars/alpine/alpine-3.21-aarch64.pkrvars.hcl; then
  echo "Cleaning up files"
  rm -rf -- "$ALPDIR"
else
  exit 1
fi
