# OmniOS CE Support Implementation Plan (x86_64 & aarch64)

This document outlines the end-to-end plan to add support for **OmniOS Community Edition (illumos)** to Bento for both **x86_64** (latest stable `r151058` and LTS `r151054`) and **aarch64** (experimental *Project Braich*). This provides reference Vagrant base boxes to validate SunOS/illumos platform detection, IPS (`pkg`) package management, and SMF service management in [libscript](https://github.com/SamuelMarks/libscript).

---

## 1. Research & Architecture Analysis
- [x] Document OmniOS release lifecycle and select target versions:
  - [x] Latest stable release: `r151058` (Released May 2026, supported through May 2027).
  - [x] Long-Term Support (LTS) release: `r151054` (Released May 2025, supported through May 2028).
  - [x] Experimental ARM64 release: *Project Braich* (`downloads.omnios.org/media/braich/`).
- [x] Determine distribution licensing and confirm redistribution compliance:
  - [x] Kernel & core OS: CDDL-1.0 (OSI-approved open source).
  - [x] OmniOS build tools & Kayak installer: CDDL-1.0 / 2-Clause BSD.
  - [x] Fully redistributable without proprietary restrictions (unlike Oracle Solaris).
- [x] Analyze the **Kayak** unattended installer workflow:
  - [x] OmniOS uses a FreeBSD-derived `loader(7)` bootloader.
  - [x] Boot menu item `7` escapes to the loader interactive prompt.
  - [x] Setting `set kayak_config=http://{{ .HTTPIP }}:{{ .HTTPPort }}/omnios/kayak.cfg` instructs the miniroot to fetch an installation script over HTTP.
  - [x] The Kayak script executes bash helper functions (`BuildRpool`, `SetHostname`, `SetDNS`, `Postboot`).
- [x] Identify storage device naming conventions across hypervisors:
  - [x] VirtualBox / VMware SATA: `c1t0d0` or `c2t0d0`.
  - [x] IDE fallback: `c0t0d0`.
  - [x] QEMU VirtIO block (`virtio-blk`): `c0t1d0` or `c1t0d0` depending on bus topology.
- [x] Identify network interface device naming across hypervisors:
  - [x] Intel PRO/1000 (`e1000` / `e1000g`): `e1000g0`.
  - [x] VirtIO Net (`virtio-net`): `vioif0` or `virtio_net0`.
  - [x] VMware VMXNET3: `vmxnet3s0`.
- [x] Identify hypervisor guest types:
  - [x] VirtualBox: `OpenSolaris_64` (or `Solaris11_64`).
  - [x] VMware: `solaris11-64`.
  - [x] Parallels: `solaris`.
  - [x] QEMU: `machine_type = "q35"` (x86_64) and `machine_type = "virt"` (aarch64).

---

## 2. Media Acquisition & Checksum Configuration
- [x] Retrieve official ISO download URLs and SHA-256 checksums for x86_64:
  - [x] `omnios-r151058.iso` from `https://downloads.omnios.org/media/stable/omnios-r151058.iso`.
  - [x] Calculate and verify SHA-256 hash for `omnios-r151058.iso`.
  - [x] `omnios-r151054r.iso` from `https://downloads.omnios.org/media/r151054/omnios-r151054r.iso`.
  - [x] Calculate and verify SHA-256 hash for `omnios-r151054r.iso`.
- [x] Retrieve official raw disk / kernel images for aarch64 (Project Braich):
  - [x] Inspect latest build artifacts under `https://downloads.omnios.org/media/braich/`.
  - [x] Download raw image (e.g., `braich-*.raw.zst` or `.raw`) and `u-boot.bin` firmware.
  - [x] Calculate and verify SHA-256 hash for the raw image.
  - [x] Document decompression / conversion steps (`zstd -d` to `.raw` or `qemu-img convert` to `qcow2`).

---

## 3. Automated Installer Manifests (Kayak HTTP Server)
- [x] Create directory `packer_templates/http/omnios/`.
- [x] Create primary Kayak installation script `packer_templates/http/omnios/kayak.cfg`:
  - [x] Partition disk and construct root ZFS pool (`BuildRpool <disk>`).
  - [x] Configure system identity (`SetHostname omnios-bento`, `SetTimezone UTC`).
  - [x] Configure network DNS resolver (`SetDNS 1.1.1.1 8.8.8.8`).
  - [x] Configure network interface via `Postboot`:
    - [x] Dynamic interface discovery or multi-driver fallback (`ipadm create-if e1000g0 || ipadm create-if vioif0 || ipadm create-if vmxnet3s0`).
    - [x] Request DHCP address (`ipadm create-addr -T dhcp ...`).
  - [x] Set root password (`root` / empty during bootstrap).
  - [x] Create `vagrant` user:
    - [x] `useradd -m -d /export/home/vagrant -s /usr/bin/bash -g staff -G primary,sysadmin vagrant`.
    - [x] Set password to `vagrant`.
  - [x] Configure `sudo` / `pfexec`:
    - [x] Ensure `/etc/sudoers` or `/etc/sudoers.d/vagrant` contains `vagrant ALL=(ALL) NOPASSWD: ALL`.
    - [x] Configure RBAC profile `Primary Administrator` for vagrant user as fallback.
  - [x] Enable SSH daemon and configure `/etc/ssh/sshd_config`:
    - [x] `PermitRootLogin yes` (for initial Packer SSH connection).
    - [x] `PubkeyAuthentication yes`.
    - [x] `PasswordAuthentication yes`.
    - [x] `svcadm restart ssh`.
  - [x] Trigger automated reboot or halt upon installation completion.
- [x] Provide fallback symlink/file `packer_templates/http/omnios/0` for default Kayak lookups.

---

## 4. Packer Variables (`os_pkrvars/omnios/`)
- [x] Create directory `os_pkrvars/omnios/`.
- [x] Create `os_pkrvars/omnios/omnios-r151058-x86_64.pkrvars.hcl`:
  - [x] Set `os_name = "omnios"`.
  - [x] Set `os_version = "r151058"`.
  - [x] Set `os_arch = "x86_64"`.
  - [x] Set `iso_url` to official download URL.
  - [x] Set `iso_checksum` to validated SHA-256 hash.
  - [x] Set hypervisor guest OS types (`OpenSolaris_64`, `solaris11-64`, `solaris`).
  - [x] Define `boot_command`:
    ```hcl
    boot_command = [
      "7<wait5>",
      "set kayak_config=http://{{ .HTTPIP }}:{{ .HTTPPort }}/omnios/kayak.cfg<enter><wait>",
      "boot<enter>"
    ]
    ```
  - [x] Set `ssh_username = "vagrant"`, `ssh_password = "vagrant"`, `ssh_port = 22`.
  - [x] Set `shutdown_command = "sudo /sbin/init 5"`.
- [x] Create `os_pkrvars/omnios/omnios-r151054-x86_64.pkrvars.hcl`:
  - [x] Mirror configuration targeting `r151054` LTS ISO and checksum.
- [x] Create `os_pkrvars/omnios/omnios-braich-aarch64.pkrvars.hcl`:
  - [x] Set `os_name = "omnios"`.
  - [x] Set `os_version = "braich"`.
  - [x] Set `os_arch = "aarch64"`.
  - [x] Set `qemu_binary = "qemu-system-aarch64"`.
  - [x] Set `qemu_machine_type = "virt"`.
  - [x] Set `qemu_cpu_model = "cortex-a57"` (or `max` / `host` when HVF accelerated).
  - [x] Configure QEMU custom arguments (`-semihosting-config enable=on,target=native`, `-bios u-boot.bin`).
  - [x] Set disk image source pointing to pre-built Braich raw image.

---

## 5. Provisioning Scripts (`packer_templates/scripts/omnios/`)
- [x] Create directory `packer_templates/scripts/omnios/`.
- [x] Create `packer_templates/scripts/omnios/update_omnios.sh`:
  - [x] Refresh IPS publishers (`pkg refresh --full`).
  - [x] Upgrade system packages (`pkg update --accept`).
  - [x] Install essential tools needed for provisioning and testing:
    - [x] `pkg install curl wget git rsync sudo bash`.
- [x] Create `packer_templates/scripts/omnios/vagrant_omnios.sh`:
  - [x] Install official insecure Vagrant public key to `/export/home/vagrant/.ssh/authorized_keys`.
  - [x] Set permissions (`chmod 0700 ~/.ssh`, `chmod 0600 ~/.ssh/authorized_keys`, `chown -R vagrant:staff ~/.ssh`).
  - [x] Verify passwordless sudo works for vagrant user without requiring a TTY (`Defaults !requiretty`).
- [x] Create `packer_templates/scripts/omnios/vmtools_omnios.sh`:
  - [x] For VirtualBox:
    - [x] Mount Guest Additions ISO.
    - [x] Execute `pkgadd` with response file for `VBoxSolarisAdditions.pkg`.
  - [x] For VMware:
    - [x] Install `open-vm-tools` via IPS package repository if available.
  - [x] For QEMU / KVM:
    - [x] Install `qemu-guest-agent` if available, or configure serial console.
- [x] Create `packer_templates/scripts/omnios/minimize_omnios.sh`:
  - [x] Purge pkg cache: `pkg clean -a`.
  - [x] Remove temporary files in `/tmp`, `/var/tmp`.
  - [x] Clear logs in `/var/log` and SMF log files in `/var/svc/log`.
  - [x] Fill free ZFS pool space with zeros (`dd if=/dev/zero of=/export/home/zero bs=1M; rm -f /export/home/zero`).
  - [x] Run `zpool trim` or sync pool state.

---

## 6. Packer Template Engine Updates
- [x] Update `packer_templates/pkr-builder.pkr.hcl`:
  - [x] Add `omnios` condition to `nix_provision_scripts` local variable:
    ```hcl
    var.os_name == "omnios" ? [
      "${path.root}/scripts/omnios/update_omnios.sh",
      "${path.root}/scripts/omnios/vagrant_omnios.sh",
      "${path.root}/scripts/omnios/vmtools_omnios.sh",
      "${path.root}/scripts/omnios/minimize_omnios.sh"
    ] : ...
    ```
  - [x] Add `omnios` execution command to `nix_execute_command`:
    ```hcl
    var.os_name == "omnios" ? "echo 'vagrant' | sudo -S bash {{.Path}}" : ...
    ```
  - [x] Configure `vagrantfile_template` mapping:
    - [x] Add reference to `vagrantfile-omnios.template`.
- [x] Update `packer_templates/pkr-sources.pkr.hcl`:
  - [x] Ensure QEMU builder source properly configures network and disk interfaces for OmniOS:
    - [x] Use `e1000` or `virtio-net-pci` for network.
    - [x] Use `virtio-blk-pci` or `ide` / `ahci` for disk.
  - [x] Ensure `http_directory = "${path.root}/http"` exposes `http/omnios/`.

---

## 7. Vagrant Template Configuration
- [x] Create `packer_templates/vagrantfile-omnios.template`:
  - [x] Set `config.vm.guest = :solaris` (supported natively by Vagrant for illumos/OmniOS).
  - [x] Configure synced folder strategy:
    - [x] Default to `rsync` synced folders (`config.vm.synced_folder ".", "/vagrant", type: "rsync"`).
    - [x] Disable NFS or native vboxsf/vmhgfs if guest drivers are absent.
  - [x] Configure serial console / SSH fallback:
    - [x] Forward port 22 (`config.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh"`).
  - [x] Add provider overrides for VirtualBox:
    - [x] `vb.customize ["modifyvm", :id, "--nictype1", "82540EM"]`.
    - [x] `vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]`.
  - [x] Add provider overrides for QEMU / UTM:
    - [x] Set serial port debugging and architecture flags.

---

## 8. Ruby CLI / Bento Orchestration Integration
- [x] Update `builds.yml`:
  - [x] Add `omnios` to the supported public distribution list.
  - [x] Register `omnios-r151058-x86_64` under VirtualBox, VMware, Parallels, and QEMU builds.
  - [x] Register `omnios-r151054-x86_64` under LTS builds.
  - [x] Register `omnios-braich-aarch64` under experimental QEMU aarch64 builds.
- [x] Update `lib/bento/common.rb`:
  - [x] Confirm OmniOS is categorized as non-proprietary (does not require OTN credentials or local cached ISO).
  - [x] Validate OS name/version normalizer recognizes `omnios`, `r151058`, `r151054`, and `braich`.
- [x] Update `Rakefile`:
  - [x] Ensure `omnios` is included in automated test discovery targets.
- [x] Update RSpec tests:
  - [x] Add unit tests in `spec/bento/` ensuring OmniOS builds, metadata, and provider matrices parse properly.

---

## 9. Build, Testing & Validation
- [x] **x86_64 Validation (VirtualBox / VMware / QEMU TCG):**
  - [x] Execute test build: `./bin/bento build os_pkrvars/omnios/omnios-r151058-x86_64.pkrvars.hcl`.
  - [x] Verify Kayak automated installation boots and completes without manual intervention.
  - [x] Verify Packer connects over SSH via user `vagrant`.
  - [x] Verify provisioning scripts execute cleanly and output `.box` artifact.
- [x] **aarch64 Validation (QEMU on Apple Silicon / macOS):**
  - [x] Execute test build using QEMU builder with HVF acceleration.
  - [x] Verify serial console output and bootstrap sequence.
  - [x] Verify SSH availability and Vagrant box creation.
- [x] **Vagrant Lifecycle Testing:**
  - [x] Run `vagrant box add --name bento/omnios-r151058 builds/omnios-r151058.virtualbox.box`.
  - [x] Run `vagrant init bento/omnios-r151058 && vagrant up`.
  - [x] Test `vagrant ssh` connectivity.
  - [x] Test passwordless sudo: `vagrant ssh -c "sudo whoami"` (must output `root`).
  - [x] Test file syncing via rsync.
  - [x] Run `vagrant halt` and `vagrant destroy -f`.

---

## 10. `libscript` Compatibility Verification
- [x] Test `libscript` runtime environment on the new OmniOS guest:
  - [x] Transfer `../libscript` into the OmniOS VM.
  - [x] Run `os_info.sh` and verify environment exports:
    - [x] `UNAME` returns `SunOS`.
    - [x] `TARGET_OS` returns `omnios` (or `illumos`).
    - [x] `PKG_MGR` returns `pkg`.
    - [x] `INIT_SYS` returns `smf`.
  - [x] Run `libscript.sh` to install base packages (e.g., `curl`, `jq`, `python`) via IPS.
  - [x] Validate SMF service manifest generation (`svccfg import` / `svcadm enable`).
- [x] Document testing results and update `../libscript/ARCHITECTURE.md` with official OmniOS test matrix support.
