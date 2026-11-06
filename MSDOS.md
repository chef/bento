# Microsoft MS-DOS (1.25 / 2.0 / 4.0) Standalone Bento Builder & Vagrant Plugin Guide (`MSDOS.md`)

This guide explains how to build, package, sync, and control standalone **Microsoft MS-DOS (1.25, 2.0, and 4.00)** virtual machine images from the official [`microsoft/ms-dos`](https://github.com/microsoft/ms-dos) open-source repository across **both `aarch64` (Apple Silicon / ARM64) and `x86_64` (Intel / AMD64) hosts** using Bento and Vagrant.

---

## 1. Architecture & Supported MS-DOS Versions

1. **Multi-Version `microsoft/ms-dos` Support**:
   - **MS-DOS 1.25 (`v1.25/bin` & `v1.25/source`)**:
     - Classic flat FAT12 directory layout (`COMMAND.COM`, `SYS.COM`, `FORMAT.COM`, `CHKDSK.COM`, `DEBUG.COM`, `EDLIN.COM`, `LINK.EXE`, `EXE2BIN.EXE`, `BASIC.COM`, `BASICA.COM`, `DONKEY.BAS`).
     - Automatic flat 8.3 path mapping (`Bento::VagrantMsdos::Config#supports_subdirectories? == false`) so host files in nested directories are staged cleanly onto the root of `D:`.
   - **MS-DOS 2.0 (`v2.0/bin` & `v2.0/source`)**:
     - Introduces hierarchical subdirectories (`MKDIR`, `CHDIR`, `RMDIR`), `CONFIG.SYS`, and hard-disk support (`MSDOS.SYS`, `COMMAND.COM`, `MASM.EXE`, `LINK.EXE`, `EXE2BIN.EXE`, `DEBUG.COM`, `MORE.COM`, `FIND.EXE`, `SORT.EXE`, `FC.EXE`).
   - **MS-DOS 4.0 (`v4.0/src` & `v4.0/src/TOOLS/BLD/BIN`)**:
     - Full source release with bundled 16-bit Microsoft development tools (`MASM.EXE`, `CL.EXE`, `LINK.EXE`, `NMAKE.EXE`, `EXE2BIN.EXE`, `LIB.EXE`) staged in `C:\TOOLS\BIN`.
     - `packer_templates/scripts/msdos/build_msdos_from_source.sh` automatically normalizes line endings (`LF` -> `CRLF`) and strips stray `0x1A` (`Ctrl-Z`) EOF markers across `v4.0/src`.
2. **Cross-Architecture Execution (`aarch64` & `x86_64`)**:
   - On `aarch64` hosts (Apple Silicon macOS / Linux ARM64), `qemu-system-i386` and UTM run the 16-bit x86 MS-DOS guest via TCG software emulation (`accel=tcg`).
   - On `x86_64` hosts, QEMU/VirtualBox uses hardware acceleration (`hvf:tcg`, `kvm:tcg`, `whpx`) or TCG.
3. **Zero-Memory Serial/Telnet Guest Agent (`COM1`)**:
   - QEMU/UTM/VirtualBox bridges `COM1` (`0x3F8`, IRQ 4) to TCP Telnet (`127.0.0.1:2324` by default) or a Unix domain socket (`/tmp/msdos-serial.sock`).
   - Inside MS-DOS, `C:\AUTOEXEC.BAT` executes `SERINIT.COM` (`115200,N,8,1`) and `C:\BENTO\VAGAGENT.BAT` (`CTTY COM1`), printing `===BENTO_MSDOS_READY===`.
   - `C:\BENTO\SHUTDOWN.COM` (43-byte 8086 real-mode binary) performs APM 1.2 (`INT 15h AX=5307h`) and QEMU/Bochs/VirtualBox ACPI port poweroff (`0x604`, `0xB004`, `0x4004`) when `vagrant halt` runs.

---

## 2. Quick Start with `msdos-builder.sh`

```sh
# 1. Fetch microsoft/ms-dos, build MS-DOS 4.0 image, package .box files, and register in Vagrant
./msdos-builder.sh all

# Build MS-DOS 2.0 or MS-DOS 1.25 specifically:
MSDOS_VERSION=2.0 ./msdos-builder.sh all
MSDOS_VERSION=1.25 ./msdos-builder.sh all

# 2. Boot standalone MS-DOS VM in the background
./msdos-builder.sh run

# 3. Execute one-shot DOS commands over the Serial/Telnet bridge
./msdos-builder.sh ssh -c "VER"
./msdos-builder.sh ssh -c "DIR C:"

# 4. Open an interactive MS-DOS console (press Ctrl+] to disconnect)
./msdos-builder.sh ssh

# 5. Stop the standalone VM and clean sockets
./msdos-builder.sh clean
```

---

## 3. Using the `Bento::VagrantMsdos` Plugin Suite in a `Vagrantfile`

```ruby
require "bento/vagrant_msdos"

Vagrant.configure("2") do |config|
  config.vm.box = "bento/msdos-4.0"
  config.vm.guest = :msdos
  config.vm.communicator = :msdos
  config.ssh.insert_key = false

  config.msdos.host = "127.0.0.1"
  config.msdos.port = 2324
  config.msdos.dos_version = "4.0" # "1.25", "2.0", or "4.0"
  config.msdos.sync_drive = "D:"

  # Bidirectional Host <-> Guest folder synchronization
  config.vm.synced_folder ".", "/vagrant",
    type: :msdos_sync,
    drive: "D:",
    sync_direction: :bidirectional,
    crlf_convert: true
end
```

### Running Commands via `vagrant ssh` Polyfill (`Bento::VagrantMsdos::CommandSsh`)

```sh
# Non-interactive DOS command execution (returns DOS %ERRORLEVEL% and syncs D: back to host)
vagrant ssh -c "VER"
vagrant ssh -c "D:\BUILDMS.BAT"

# Interactive raw-TTY session connected to MS-DOS COM1 (C:\>)
vagrant ssh
```

### Syncing Directories (`Bento::VagrantMsdos::SyncedFolder` & `CommandSync`)

```sh
# Push host workspace files to MS-DOS D: drive (with LF -> CRLF conversion)
vagrant msdos-sync --to-guest --crlf --live

# Pull compiled .COM/.EXE/.OBJ/.TXT artifacts from MS-DOS D: back to host
vagrant msdos-sync --to-host --live
```
