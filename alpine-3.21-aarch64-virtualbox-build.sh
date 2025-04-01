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
export VERSION="${VERSION:-3.21.3}"
export VERSION_MAJOR_MINOR="${VERSION%.*}"

# Getting script directory location
SCRIPT_RELATIVE_DIR=$(dirname -- "${this_file}")
cd -- "$SCRIPT_RELATIVE_DIR" || exit

# set tmp dir for files
ALPDIR="$(pwd)/builds/build_files/alpine-${VERSION}-${ARCH}-virtualbox"
mkdir -p "$ALPDIR"

echo "Cleaning up old files"
set +f
rm -f -- "$ALPDIR"/*.iso "$ALPDIR"/*.ovf "$ALPDIR"/*.vmdk "$ALPDIR"/*.vdi

# Get virtualbox vdi file name with latest version number

qemu-img create -f qcow2 -- "$ALPDIR"'/alpine.qcow2' 8G

export IMG='alpine-standard-'"${VERSION}"'-aarch64.iso'
if [ ! -f "$ALPDIR"'/'"${IMG}" ]; then
    echo "Downloading $IMG"
    wget -q -O "$ALPDIR"'/'"${IMG}" -c 'https://dl-cdn.alpinelinux.org/alpine/v'"${VERSION_MAJOR_MINOR}"'/releases/aarch64/alpine-standard-'"${VERSION}"'-aarch64.iso'
fi

if [ ! -f "$ALPDIR"'/alpine_arm64.vdi' ]; then
  qemu-system-x86_64 -m 512 -nic user -boot d -cdrom "$ALPDIR"'/'"${IMG}" -hda "$ALPDIR"'/alpine.qcow2' -display none  # -enable-kvm
  echo "Convert qcow2 to vdi"
  qemu-img convert -f qcow2 "$ALPDIR"'/alpine.qcow2' -O vdi "$ALPDIR"'/alpine_arm64.vdi'
fi

echo "Creating ISO"
SEED_ISO_DIR="$(pwd)/packer_templates/http/alpine"
if [ -x "$(command -v genisoimage)" ]; then
  genisoimage -output "$ALPDIR"/seed.iso -volid cidata -joliet -rock "$SEED_ISO_DIR"/user-data -- "$SEED_ISO_DIR"/meta-data
elif [ -x "$(command -v hdiutil)" ]; then
  hdiutil makehybrid -o "$ALPDIR"/seed.iso -hfs -joliet -iso -default-volume-name cidata -- "$SEED_ISO_DIR"/
elif [ -x "$(command -v mkisofs)" ]; then
  mkfsiso9660 -o "$ALPDIR"/seed.iso -- "$SEED_ISO_DIR"/
else
  echo "No tool found to create the seed.iso"
  exit 1
fi

VM="AlpineLinuxBento"
echo Powering off and deleting any existing VMs named $VM
VBoxManage controlvm "$VM" poweroff --type headless 2>/dev/null
VBoxManage unregistervm "$VM" --delete 2>/dev/null
sleep 5

echo "Creating the VM"
# from https://www.perkin.org.uk/posts/create-virtualbox-vm-from-the-command-line.html
VBoxManage createvm --name "$VM" --ostype "ArchLinux_arm64" --register
VBoxManage storagectl "$VM" --name "VirtioSCSI" --add virtio-scsi --controller VirtIO
VBoxManage storageattach "$VM" --storagectl "VirtioSCSI" --port 0 --type hdd --medium "$ALPDIR"/alpine_arm64.vdi
VBoxManage storageattach "$VM" --storagectl "VirtioSCSI" --port 1 --type dvddrive --medium "$ALPDIR"/seed.iso
VBoxManage modifyvm "$VM" --chipset armv8virtual
VBoxManage modifyvm "$VM" --firmware efi
VBoxManage modifyvm "$VM" --memory 4096
VBoxManage modifyvm "$VM" --cpus 2
VBoxManage modifyvm "$VM" --nat-localhostreachable1 on
VBoxManage modifyvm "$VM" --vram 33
VBoxManage modifyvm "$VM" --graphicscontroller vmsvga
VBoxManage modifyvm "$VM" --vrde on
VBoxManage modifyvm "$VM" --audio-enabled off
VBoxManage modifyvm "$VM" --ioapic on
VBoxManage modifyvm "$VM" --usb-xhci on
VBoxManage modifyvm "$VM" --mouse usb
VBoxManage modifyvm "$VM" --keyboard usb
VBoxManage modifyvm "$VM" --boot1 disk
VBoxManage modifyvm "$VM" --boot2 dvd
sleep 5

echo "Starting $VM then sleeping for 120 seconds to let the system boot and cloud-init to run"
VBoxManage startvm "$VM" --type headless
sleep 120
VBoxManage guestcontrol "$VM" run --exe /bin/sh -- 'apk add virtualbox-guest-additions &&
    rc-service virtualbox-guest-additions start &&
    rc-update add virtualbox-guest-additions boot'
VBoxManage controlvm "$VM" poweroff
VBoxManage storageattach "$VM" --storagectl "VirtioSCSI" --port 1 --type dvddrive --medium none
sleep 5

echo "Exporting the VM to an OVF file"
vboxmanage export "$VM" -o "$ALPDIR"/alpine_arm64.ovf
sleep 5

echo "Deleting the VM"
vboxmanage unregistervm "$VM" --delete

echo "starting packer build of alpine ${VERSION} for ${ARCH}"
if bento build --vars 'ssh_timeout=60m' --vars vbox_source_path="$ALPDIR"/alpine_arm64.ovf,vbox_checksum=null "$(pwd)"/os_pkrvars/alpine/alpine-3.21-aarch64.pkrvars.hcl; then
  echo "Cleaning up files"
  rm -rf -- "$ALPDIR"
else
  exit 1
fi
