# FreeDOS Standalone Bento Builder & Vagrant Plugin Guide (`FREEDOS.md`)

This guide explains how to build, package, sync, and control a standalone **FreeDOS (1.3 / 1.4)** virtual machine image across **both `aarch64` (Apple Silicon / ARM64 Linux) and `x86_64` hosts** using Bento, and how to compile and test **OpenWatcom v2** 16-bit and 32-bit DOS targets inside Vagrant.

---

## 1. Cross-Architecture Design (`aarch64` & `x86_64`)

A single FreeDOS `i386`/`x86_64` disk image runs across both host architectures:
- **On `aarch64` hosts**: QEMU (`qemu-system-i386` / `qemu-system-x86_64`) and UTM (`vm_backend = "qemu"`, `vm_arch = "x86_64"`) run FreeDOS using **TCG software emulation** (`accel=tcg`).
- **On `x86_64` hosts**: QEMU, UTM, and VirtualBox run the same FreeDOS image using hardware acceleration (`hvf` on macOS, `kvm` on Linux, `whpx` on Windows) or `tcg`.

### Packer Variable Definitions
- `os_pkrvars/freedos/freedos-1.3-aarch64.pkrvars.hcl`
- `os_pkrvars/freedos/freedos-1.3-x86_64.pkrvars.hcl`
- `os_pkrvars/freedos/freedos-1.4-aarch64.pkrvars.hcl`
- `os_pkrvars/freedos/freedos-1.4-x86_64.pkrvars.hcl`

---

## 2. Building & Running with `freedos-builder.sh`

```sh
# Check status of FreeDOS templates, ISOs, sync disks, and serial ports
./freedos-builder.sh status

# Build the standalone FreeDOS image via Packer
./freedos-builder.sh build

# Package into a minimal Vagrant .box archive (< 15 MB)
./freedos-builder.sh box

# Register with Vagrant as bento/freedos
./freedos-builder.sh register

# Boot standalone via QEMU on either aarch64 or x86_64
./freedos-builder.sh run

# Execute a one-shot DOS command over the Serial/Telnet bridge
./freedos-builder.sh ssh -c "VER"

# Connect interactively to FreeDOS COM1 console
./freedos-builder.sh ssh
```

---

## 3. Telnet / Serial Communicator & `vagrant ssh` Polyfill

Because DOS does not run an OpenSSH daemon and has a strict 640 KB conventional memory limit:
1. **QEMU / UTM / VirtualBox** bridges `COM1` (`0x3F8`, IRQ 4) to a host TCP Telnet server (`127.0.0.1:2323`) or Unix domain socket.
2. **FreeDOS `FDAUTO.BAT`** sets `MODE COM1:115200,N,8,1` and calls `C:\BENTO\VAGAGENT.BAT`, which redirects `COMMAND.COM` I/O via `CTTY COM1`.
3. **`Bento::VagrantFreedos::Communicator` (`config.vm.communicator = :freedos`)**:
   - Wraps every command with `===START_<ID>===` and `===EXIT_<ID>:%ERRORLEVEL%===` markers.
   - Streams live `stdout` back to Vagrant and returns the exact integer DOS `%ERRORLEVEL%`.
   - Transfers binary files (`.EXE`, `.COM`, `.OBJ`) over the serial link using `C:\BENTO\B64ENC.COM` and `C:\BENTO\B64DEC.COM`.
4. **`Bento::VagrantFreedos::CommandSsh` (`vagrant ssh` Polyfill)**:
   - **`vagrant ssh -c "D:\HELLO16.EXE"`**: Executes the DOS command non-interactively over the Telnet/Serial communicator, streams output, triggers Guest -> Host folder synchronization, and exits with the DOS `%ERRORLEVEL%`.
   - **`vagrant ssh`**: Opens an interactive raw-TTY terminal session connected directly to FreeDOS `C:\>` (`Ctrl+]` to disconnect).

---

## 4. Bidirectional Directory Synchronization (`:freedos_sync`)

Configured in `Vagrantfile` (`packer_templates/vagrantfile-freedos.template`):

```ruby
config.vm.synced_folder ".", "/vagrant",
  type: :freedos_sync,
  drive: "D:",
  sync_direction: :bidirectional,
  crlf_convert: true,
  exclude: [".git/", ".vagrant/", "builds/"]
```

- **Host -> Guest (`sync_to_guest`)**: Stages workspace files onto the secondary `D:` drive (`freedos_sync_d.raw` / live serial upload) with optional LF -> CRLF conversion for `.BAT`, `.C`, `.H`, `.WAT`, and `.MAK` files.
- **Guest -> Host (`sync_to_host`)**: Automatically pulls newly created or modified `.EXE`, `.COM`, `.OBJ`, `.MAP`, `.LOG`, and `.TXT` files from FreeDOS `D:` back into your host directory after `vagrant ssh -c`, on `vagrant halt`, or on demand via `vagrant freedos-sync --to-host`.

---

## 5. OpenWatcom v2 DOS Build & Test Workflow

Sample 16-bit (`HELLO16.C`) and 32-bit DOS/4GW (`HELLO32.C`) programs are included in `lib/bento/test_templates/freedos_openwatcom/`:

```sh
# 1. Cross-compile on host with OpenWatcom v2 (or compile inside FreeDOS via D:\BUILD.BAT)
wcl -q -bcl=dos -fe=HELLO16.EXE lib/bento/test_templates/freedos_openwatcom/HELLO16.C
wcl386 -q -bcl=dos4g -fe=HELLO32.EXE lib/bento/test_templates/freedos_openwatcom/HELLO32.C

# 2. Run inside FreeDOS via Vagrant and capture output back to the host workspace
vagrant ssh -c "D:\HELLO16.EXE > D:\OUT16.TXT"
vagrant ssh -c "C:\BENTO\DOS4GW.EXE D:\HELLO32.EXE > D:\OUT32.TXT"
```
