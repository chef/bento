Please refer to <https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/TESTING.MD>

## Testing OmniOS Community Edition (x86_64 & aarch64)

OmniOS Community Edition (illumos) base boxes can be built for x86_64 (stable `r151058` and LTS `r151054`) and aarch64 (experimental Project Braich).

### Building x86_64 (Stable & LTS)
The x86_64 builds use the automated Kayak installer served over HTTP. Kayak partitions the root ZFS pool, sets up identity and networking, creates the `vagrant` user with passwordless `sudo` and `Primary Administrator` RBAC privileges, and configures SSH.

To build the stable release (`r151058`):
```sh
bundle exec bin/bento build os_pkrvars/omnios/omnios-r151058-x86_64.pkrvars.hcl
```

To build the LTS release (`r151054`):
```sh
bundle exec bin/bento build os_pkrvars/omnios/omnios-r151054-x86_64.pkrvars.hcl
```

### Building aarch64 (Project Braich)
Project Braich provides pre-built raw disk images and U-Boot firmware for ARM64:
1. Download artifacts from `https://downloads.omnios.org/media/braich/`:
   ```sh
   curl -LO https://downloads.omnios.org/media/braich/braich-151059.raw.zst
   curl -LO https://downloads.omnios.org/media/braich/u-boot.bin
   ```
2. Decompress the raw disk image:
   ```sh
   zstd -d braich-151059.raw.zst -o braich-151059.raw
   ```
3. (Optional) Convert raw disk image to qcow2 format:
   ```sh
   qemu-img convert -O qcow2 braich-151059.raw braich-151059.qcow2
   ```
4. Run the aarch64 build with QEMU:
   ```sh
   bundle exec bin/bento build -o qemu.vm os_pkrvars/omnios/omnios-braich-aarch64.pkrvars.hcl
   ```

### Vagrant Box Testing
Verify the generated box artifact with Vagrant:
```sh
vagrant box add --name bento/omnios-r151058 builds/build_complete/omnios-r151058-x86_64.virtualbox.box
vagrant init bento/omnios-r151058
vagrant up
vagrant ssh -c "sudo whoami"   # Verifies passwordless sudo returns root
vagrant ssh -c "uname -a"      # Verifies SunOS illumos kernel
vagrant destroy -f
```
