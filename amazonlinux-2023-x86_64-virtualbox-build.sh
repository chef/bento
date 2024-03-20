#!/usr/bin/env bash

# Getting script directory location
SCRIPT_RELATIVE_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$SCRIPT_RELATIVE_DIR" || exit

# set tmp dir for files
AMZDIR="$(pwd)/packer_templates/amz_working_files"

echo "Cleaning up old files"
rm -f "$AMZDIR"/*.iso "$AMZDIR"/*.ovf "$AMZDIR"/*.vmdk "$AMZDIR"/*.vdi

# Get virtualbox vdi file name with latest version number
IMG="$(wget -q https://cdn.amazonlinux.com/al2023/os-images/latest/kvm/ -O - | grep ".qcow2" | cut -d "\"" -f 2)"

echo "Downloading $IMG"
wget -q -O "$AMZDIR"/amazon2023_x86_64.qcow2 -c https://cdn.amazonlinux.com/al2023/os-images/latest/kvm/"$IMG"

echo "Convert qcow2 to vdi"
qemu-img convert -f qcow2 "$AMZDIR"/amazon2023_x86_64.qcow2 -O vdi "$AMZDIR"/amazon2023_x86_64.vdi

if [ ! -f "$AMZDIR"/amazon2023_x86_64.vdi ]; then
  echo There must be a file named amazon2023_x86_64.vdi in "$AMZDIR"!
  echo You can download the files at  https://cdn.amazonlinux.com/al2023/os-images/latest/
  exit 1
fi

echo "Creating ISO"
hdiutil makehybrid -o "$AMZDIR"/seed.iso -hfs -joliet -iso -default-volume-name cidata "$AMZDIR"/../amz_seed_iso

VM="AmazonLinuxBento"
echo Powering off and deleting any existing VMs named $VM
VBoxManage controlvm $VM poweroff --type headless 2> /dev/null
VBoxManage unregistervm $VM --delete 2> /dev/null
sleep 5

echo "Creating the VM"
# from https://www.perkin.org.uk/posts/create-virtualbox-vm-from-the-command-line.html
VBoxManage createvm --name $VM --ostype "Fedora_64" --register
VBoxManage storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$AMZDIR"/amazon2023_x86_64.vdi
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$AMZDIR"/seed.iso
VBoxManage modifyvm $VM --memory 2048
VBoxManage modifyvm $VM --cpus 2
VBoxManage modifyvm $VM --nat-localhostreachable1 on
VBoxManage modifyvm $VM --vram 10
VBoxManage modifyvm $VM --graphicscontroller vmsvga
VBoxManage modifyvm $VM --vrde off
VBoxManage modifyvm $VM --audio-driver none
VBoxManage modifyvm $VM --ioapic on
sleep 5

echo "Sleeping for 120 seconds to let the system boot and cloud-init to run"
VBoxManage startvm $VM --type headless
sleep 120
VBoxManage controlvm $VM poweroff --type headless
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium none
sleep 5

echo "Exporting the VM to an OVF file"
vboxmanage export $VM -o "$AMZDIR"/amazon2023_x86_64.ovf
sleep 5

echo "Deleting the VM"
vboxmanage unregistervm $VM --delete

echo "starting packer build of amazonlinux"
if packer build -timestamp-ui -var "vbox_source_path=$AMZDIR/amazon2023_x86_64.ovf" -var "vbox_checksum=null" -var-file="$AMZDIR"/../../os_pkrvars/amazonlinux/amazonlinux-2023-x86_64.pkrvars.hcl "$AMZDIR"/../../packer_templates; then
  echo "Cleaning up files"
  rm -f "$AMZDIR"/*.ovf "$AMZDIR"/*.vmdk "$AMZDIR"/*.iso "$AMZDIR"/*.vdi "$AMZDIR"/*.qcow2
else
  exit 1
fi
