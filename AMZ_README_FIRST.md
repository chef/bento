This is not your normal Bento box. Instead of building a system from an ISO we're building a system from an Amazon provided vm hdd image files. This means the process is a bit different than usual.

# Building this box

Simply run one of the amazonlinxu-2*-build.sh scripts

These scripts will:

1. Download the vm image file for Amazon Linux 2 or 2023 and place it in the amz_working_files directory. Amazon hosts these at <https://cdn.amazonlinux.com/os-images/latest/> and <https://cdn.amazonlinux.com/al2023/os-images/latest/>.
1. It will prepare the VDI file for packer and export it as a OVF file
1. It will run the packer build
1. Lastly it will clean up the leftover files in the working directory on successful completion
