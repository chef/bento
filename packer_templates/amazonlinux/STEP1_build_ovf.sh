#!/bin/bash

if [ ! -f amazon.vdi ]; then
  echo There must be a file named amazon.vdi in this directory!
  echo You can download the vdi file at https://cdn.amazonlinux.com/os-images/latest/virtualbox/
  exit 1
fi

echo "Cleaning up old files"
rm seed.iso
rm amazon2.ovf
rm *.vmdk

echo "Creating ISO"
hdiutil makehybrid -o seed.iso -hfs -joliet -iso -default-volume-name cidata seed_iso

VM="AmazonLinuxBento"
echo Powering off and deleting any existing VMs named $VM
VBoxManage controlvm $VM poweroff --type gui 2> /dev/null
vboxmanage unregistervm $VM 2> /dev/null
sleep 5

echo "Creating the VM"
# from https://www.perkin.org.uk/posts/create-virtualbox-vm-from-the-command-line.html
VBoxManage createvm --name $VM --ostype "RedHat_64" --register
VBoxManage storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium amazon.vdi
VBoxManage storagectl $VM --name "IDE Controller" --add ide
VBoxManage storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium seed.iso
VBoxManage modifyvm $VM --memory 1024
VBoxManage modifyvm $VM --cpus 2
VBoxManage modifyvm $VM --audio none
VBoxManage modifyvm $VM --ioapic on
sleep 5

echo Sleeping for 200 seconds to let the system boot and cloud-init to run
VBoxManage startvm $VM --type gui
sleep 200
VBoxManage controlvm $VM poweroff --type gui
VBoxManage storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium none
sleep 5

echo Exporting the VM to an OVF file
vboxmanage export $VM -o amazon2.ovf
sleep 5

echo Deleting the VM
vboxmanage unregistervm $VM
