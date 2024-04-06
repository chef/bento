#!/usr/bin/env bash

# Getting script directory location
SCRIPT_RELATIVE_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$SCRIPT_RELATIVE_DIR" || exit

# set tmp dir for files
AMZDIR="$(pwd)/packer_templates/amz_working_files"

echo "Cleaning up old files"
rm -f "$AMZDIR"/*.iso "$AMZDIR"/*.ovf "$AMZDIR"/*.vmdk "$AMZDIR"/*.vdi

# Get virtualbox vdi file name with latest version number
IMG="$(wget -q https://cdn.amazonlinux.com/al2023/os-images/latest/kvm-arm64/ -O - | grep ".qcow2" | cut -d "\"" -f 2)"

echo "Downloading $IMG"
wget -q -O "$AMZDIR"/amazon2023_arm64.qcow2 -c https://cdn.amazonlinux.com/al2023/os-images/latest/kvm-arm64/"$IMG"

echo "Convert qcow2 to vdi"
qemu-img convert -f qcow2 "$AMZDIR"/amazon2023_arm64.qcow2 -O vdi "$AMZDIR"/amazon2023_arm64.vdi

if [ ! -f "$AMZDIR"/amazon2023_arm64.vdi ]; then
  echo There must be a file named amazon2023_arm64.vdi in "$AMZDIR"!
  echo You can download the files at  https://cdn.amazonlinux.com/al2023/os-images/latest/
  exit 1
fi

echo "Creating ISO"
if [ -x "$(command -v genisoimage)" ]; then
  genisoimage -output "$AMZDIR"/seed.iso -volid cidata -joliet -rock "$AMZDIR"/../amz_seed_iso/user-data "$AMZDIR"/../amz_seed_iso/meta-data
elif [ -x "$(command -v hdiutil)" ]; then
  hdiutil makehybrid -o "$AMZDIR"/seed.iso -hfs -joliet -iso -default-volume-name cidata "$AMZDIR"/../amz_seed_iso
elif [ -x "$(command -v mkisofs)" ]; then
  mkfsiso9660 -o "$AMZDIR"/seed.iso "$AMZDIR"/../amz_seed_iso
else
  echo "No tool found to create the seed.iso"
  exit 1
fi

VM="AmazonLinuxBento"
echo Powering off and deleting any existing VMs named $VM
VBoxManage controlvm $VM poweroff --type headless 2> /dev/null
VBoxManage unregistervm $VM --delete 2> /dev/null
sleep 5

echo "Creating the VM"
# from https://www.perkin.org.uk/posts/create-virtualbox-vm-from-the-command-line.html
VBoxManage createvm --name $VM --ostype "Fedora_64" --register
VBoxManage storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --type hdd --medium "$AMZDIR"/amazon2023_arm64.vdi
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 1 --type dvddrive --medium "$AMZDIR"/seed.iso
VBoxManage modifyvm $VM --chipset ich9
VBoxManage modifyvm $VM --firmware efi
VBoxManage modifyvm $VM --memory 2048
VBoxManage modifyvm $VM --cpus 2
VBoxManage modifyvm $VM --nat-localhostreachable1 on
VBoxManage modifyvm $VM --vram 33
VBoxManage modifyvm $VM --graphicscontroller vmsvga
VBoxManage modifyvm $VM --vrde off
VBoxManage modifyvm $VM --audio-driver none
VBoxManage modifyvm $VM --ioapic on
sleep 5

echo "Sleeping for 120 seconds to let the system boot and cloud-init to run"
VBoxManage startvm $VM --type headless
sleep 120
VBoxManage controlvm $VM poweroff --type headless
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 1 --type dvddrive --medium none
sleep 5

echo "Exporting the VM to an OVF file"
vboxmanage export $VM -o "$AMZDIR"/amazon2023_arm64.ovf
sleep 5

echo "Deleting the VM"
vboxmanage unregistervm $VM --delete

echo "starting packer build of amazonlinux"
if bento build --vars vbox_source_path="$AMZDIR"/amazon2023_arm64.ovf,vbox_checksum=null "$AMZDIR"/../../os_pkrvars/amazonlinux/amazonlinux-2023-aarch64.pkrvars.hcl; then
  echo "Cleaning up files"
  rm -f "$AMZDIR"/*.ovf "$AMZDIR"/*.vmdk "$AMZDIR"/*.iso "$AMZDIR"/*.vdi "$AMZDIR"/*.qcow2
else
  exit 1
fi
