This is not your normal Bento box. Instead of building a system from an ISO we're building a system from an Amazon provided VirtualBox VDI file. This means the process is a bit different than usual.

## Building this box

1. Download the VirtualBox .vdi file for Amazon Linux 2 and place it in the same directory as this readme file. Amazon hosts these at https://cdn.amazonlinux.com/os-images/latest/virtualbox/. Make sure to name it amazon.vdi instead of the version specific name that Amazon gives it on their site.
2. Run the STEP1_build_ovf.sh script to prepare this VDI file for packer and export it as a OVF file.
3. Run the packer definition as usual
4. OPTIONAL: Cleanup the leftover files in the directory
