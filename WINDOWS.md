# Windows 11 Bento Support & Optimization Guide

This document details the automated build, runtime lifecycle, serial debugging, and multi-stage disk minification pipeline for Windows 11 (x86_64 and ARM64) within Bento.

---

## 1. Minification & Size Reduction Pipeline

Standard Windows 11 Enterprise virtual machine installations typically consume **16–20+ GB** of disk space, producing excessively large Vagrant `.box` archives that are slow to download, cache, and deploy.

Through an aggressive, multi-layered optimization pipeline applied across the Guest OS, NTFS filesystem, hypervisor block layer, and archive compression, the final `.box` size is reduced by over **50%**.

### Size Comparison

| Stage / Metric | Unoptimized Baseline | Optimized Bento Windows 11 | Reduction |
|---|---|---|---|
| **Guest In-OS Used Space** | ~28–32 GB | **~10.5 GB** | **-65%** |
| **Raw / Expanded Disk** | 64 GB virtual | 64 GB virtual (sparse) | — |
| **QEMU QCOW2 Disk Image** | ~16–18 GB | **~9.1 GB** | **-47%** |
| **Final Vagrant `.box` Size** | **16.0–20.0+ GB** | **9.0 GB** (9,556,865,385 bytes) | **>50% Reclaimed** |

---

### Multi-Layer Optimization Techniques

| Layer | Technique | Mechanism & Command | Impact |
|---|---|---|---|
| **In-Guest OS** | **Disable Reserved Storage** | `DISM.exe /Online /Set-ReservedStorageState /State:Disabled`<br>`HKLM\...\ReserveManager\ShippedWithReserves = 0` | Reclaims **~7 GB** |
| **In-Guest OS** | **Disable Hibernation** | `powercfg.exe /hibernate off`<br>Deletes `hiberfil.sys` | Reclaims **4–6 GB** |
| **In-Guest OS** | **Purge Windows Recovery** | `reagentc.exe /disable`<br>Purges `C:\Recovery` and `Winre.wim` | Reclaims **~500 MB–1 GB** |
| **In-Guest OS** | **Aggressive AppX Debloat** | Purges provisioned and user packages (Xbox, Clipchamp, Copilot, Teams, OneDrive, Widgets, Bing, Solitaire) | Reclaims **~2 GB** |
| **In-Guest OS** | **Component Store Reset** | `dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase`<br>`dism.exe /Online /Cleanup-Image /SPSuperseded` | Reclaims **1.5–2.5 GB** |
| **In-Guest OS** | **Disabled Features Removal** | `Get-WindowsOptionalFeature \| Where {$_.State -eq 'Disabled'} \| Disable-Feature ... /Remove` | Reclaims **~500 MB** |
| **In-Guest OS** | **CleanMgr Automation** | `cleanmgr.exe /sagerun:1`<br>Cleans update logs, Delivery Optimization cache, error reports, thumbnails | Reclaims **~1–2 GB** |
| **Filesystem** | **CompactOS Compression** | `compact.exe /compactOS:always`<br>Compresses all OS system binaries via kernel XPRESS algorithm | Shrinks OS footprint by **3–4 GB** |
| **Filesystem** | **LZX Application Compression** | `compact.exe /c /s /a /i /exe:lzx "C:\Program Files\*"`<br>`compact.exe /c /s /a /i /exe:lzx "C:\Program Files (x86)\*"` | Shrinks program files by **30–50%** |
| **Disk Blocks** | **Free-Space Zero Fill** | Streams `0x00` zero bytes to `C:\zero.tmp` until drive full, then deletes it | Converts all free sectors to zero |
| **Disk Blocks** | **Hypervisor ReTrim** | `Optimize-Volume -DriveLetter C -ReTrim`<br>Discards unused clusters via VirtIO SCSI discard | Unmaps empty blocks at block layer |
| **Disk Image** | **Multi-Threaded Sparsification** | `qemu-img convert -p -m 16 -W -O qcow2 -c -S 4k`<br>Discards 4KB zero blocks and applies zlib cluster compression | Compresses 11 GB disk to **~9.1 GB** in seconds |
| **Box Archive** | **Sparse Tar with Parallel Pigz** | `tar --sparse -I 'pigz -9'`<br>Preserves sparse hole maps and compresses using all CPU cores | Maximally compresses `.box` without expanding holes |

---

## 2. Vagrant Lifecycle Operations

The generated Windows 11 box supports the complete Vagrant lifecycle:

### `vagrant up`
- Boots under UEFI firmware (`OVMF_CODE.fd`).
- Configures user-mode networking with DHCP IP allocation.
- Automatically initializes WinRM HTTP listener on port 5985.
- Communicator: `config.vm.communicator = "winrm"`
- Credentials: user `vagrant`, password `vagrant`.

### `vagrant ssh`
- OpenSSH Server is configured as an automatic service (`sshd`) listening on port 22.
- Default shell is set to PowerShell (`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`).
- Configured with `PubkeyAcceptedAlgorithms +ssh-rsa` and `StrictModes no` in `sshd_config`.
- HashiCorp's official standard insecure public key is installed in `C:\Users\vagrant\.ssh\authorized_keys`.
- Connects directly into PowerShell without password prompts.

### `vagrant halt` / `vagrant down`
- Executes an orderly, graceful shutdown via WinRM.
- Flushes NTFS filesystem buffers and transitions hypervisor domain to `shutoff`.

### `vagrant snapshot`
- Supports full hypervisor snapshot lifecycle:
  - `vagrant snapshot save [vm-name] <snapshot-name>`: Saves the VM disk and state.
  - `vagrant snapshot restore [vm-name] <snapshot-name>`: Restores to the named snapshot and reconnects communicator.
  - `vagrant snapshot list [vm-name]`: Displays existing snapshots.
  - `vagrant snapshot delete [vm-name] <snapshot-name>`: Removes snapshot checkpoints.
  - `vagrant snapshot push` / `vagrant snapshot pop`: Stack-based rapid save and restore.
- For crash-consistent and application-consistent live snapshots under libvirt and QEMU, VirtIO QEMU Guest Agent and VSS Provider are integrated.
- Taking snapshots during `vagrant halt` (clean shutdown) is recommended for instant restoration without NTFS journal replaying.

---

## 3. Shared Folders

### QEMU / Libvirt Provider
- **Out-of-the-Box RSync Sharing**: The box bundles portable `rsync.exe` directly inside `C:\Windows\System32`, providing fast, reliable, unprivileged host-guest file synchronization:
  ```ruby
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  ```
  Synchronizes during `vagrant up`, and can be triggered on-demand via `vagrant rsync` or automatically in background via `vagrant rsync-auto`.
- **Native SMB Sharing**: For bidirectional live network mount:
  ```ruby
  config.vm.synced_folder ".", "/vagrant", type: "smb", smb_host: "10.0.2.2"
  ```
  Windows automatically mounts the host SMB export using its built-in `LanmanWorkstation` CIFS client (requires host file sharing privileges).

### VirtualBox Provider
- VirtualBox Guest Additions shared folders (`vboxsf`) work out of the box:
  ```ruby
  config.vm.synced_folder ".", "/vagrant"
  ```

---

## 4. Serial Console & Real-Time Debugging

On Windows 11 client editions, Special Administration Console (`SacSvr`) does not exist (Windows Server only). Enabling kernel Emergency Management Services (`bcdedit /ems on`) locks `COM1` into exclusive kernel mode, causing `COM1` to become an unseekable phantom device (`CM_PROB_PHANTOM`).

To enable reliable real-time serial logging:
1. Kernel EMS is disabled in BCD (`bcdedit /ems {current} off` and `bcdedit /bootems off`).
2. Windows attaches `serial.sys` cleanly to `ACPI\PNP0501` (`COM1`).
3. Provisioning and cleanup scripts output real-time progress to `COM1` using `cmd.exe /c "echo [...] > COM1"`.
4. The host script connects to QEMU's serial chardev socket (`/tmp/windows-11-serial.sock`) via `serial_proxy.py` and logs to `serial.log`.

---

## 5. Tool Suite: `windows-11-builder.sh`

The all-in-one CLI script `windows-11-builder.sh` provides:

```bash
# 1. Build Windows 11 VM with Packer and automatically run box optimization
./windows-11-builder.sh build [--provider qemu|virtualbox] [--headless true|false] [--serial]

# 2. Run the VM directly with KVM, UEFI, serial console, and port forwarding
./windows-11-builder.sh run [--vnc 0] [--memory 6144] [--cpus 4]

# 3. Connect to the live serial console for debugging
./windows-11-builder.sh serial           # Interactive terminal session
./windows-11-builder.sh serial --watch   # Follow serial log stream
./windows-11-builder.sh serial --tail 50 # View recent log entries
./windows-11-builder.sh serial --send "dir C:"

# 4. Run the multi-stage aggressive box size reduction pipeline on existing disk
./windows-11-builder.sh box

# 5. Check environment, ISO, disk sizes, running VMs, and built boxes
./windows-11-builder.sh status

# 6. Clean up temporary sockets, locks, and background processes
./windows-11-builder.sh clean

# 7. Manage VM snapshots (live via QEMU monitor/VBoxManage, or offline)
./windows-11-builder.sh snapshot --create <name>   # Take a snapshot (default: snap_<timestamp>)
./windows-11-builder.sh snapshot --list            # List all available snapshots
./windows-11-builder.sh snapshot --restore <name>  # Revert VM to a snapshot
./windows-11-builder.sh snapshot --delete <name>   # Delete a snapshot
```
