This is not your normal Bento box. Instead of building a system from an ISO we're building a system from an Amazon provided VirtualBox VDI file. This means the process is a bit different than usual.

# Building this box

Simply run the AMZ_build_virtualbox-ovf.sh script

This script will:

1. Download the VirtualBox .vdi file for Amazon Linux 2 and place it in the amz_working_files directory. Amazon hosts these at <https://cdn.amazonlinux.com/os-images/latest/virtualbox/>. It will name it amazon.vdi instead of the version specific name that Amazon gives it on their site
1. It will prepare this VDI file for packer and export it as a OVF file
1. It will run the packer build
1. Lastly it will clean up the leftover files in the working directory 
