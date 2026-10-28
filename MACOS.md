# macOS Vagrant Box Support in Bento (UTM & Apple Silicon)

This document provides complete instructions, architectural specifications, and legal guidelines for building and running macOS Vagrant boxes with Bento using **UTM** on **Apple Silicon (`aarch64`)**.

---

## 1. Legal & Licensing Notice (Apple SLA Compliance)

Virtualization of macOS is governed by Apple Inc.'s **macOS Software License Agreement (SLA)** (specifically Section 2.B(iii)):

1. **Genuine Apple Hardware:** macOS virtual machines may only be created, installed, and run on **genuine Apple-branded hardware** running macOS.
2. **Instance Limit:** A licensee may run up to a maximum of **two (2) additional copies or instances** of macOS in virtual operating system environments on each physical Apple Mac computer owned or controlled.
3. **Authorized Use:** Virtualization is licensed strictly for purposes of:
   * Software development
   * Testing during software development
   * Using macOS Server
   * Personal, non-commercial use
4. **Prohibition of Public Redistribution:** Apple's SLA strictly prohibits the redistribution, hosting, publishing, or sharing of macOS disk images, pre-built VM bundles, or packaged Vagrant boxes (`.box` files) on public repositories (including Vagrant Cloud).
   * **Bento Enforcement:** Bento classifies `macos` under its internal `proprietary_os_list`. Bento's upload tools (`bento upload`) automatically block attempts to publish macOS boxes to Vagrant Cloud or public registries. All macOS boxes must be built and used locally within your own environment.

---

## 2. Architecture & Virtualization Overview

Modern macOS (macOS 14 Sonoma, macOS 15 Sequoia, and newer) on Apple Silicon utilizes Apple's native **`Virtualization.framework`** (`VZVirtualMachine`). Unlike legacy x86 operating systems that install from optical ISOs:

* **Restore Bundles (`.ipsw`):** macOS installations restore from official Apple `.ipsw` image files signed by Apple CDN.
* **Apple Backend in UTM:** UTM configures a dedicated `.utm` bundle utilizing the `Apple` virtualization backend, consisting of:
  * `config.plist`: Apple platform specification (vCPUs, RAM, dynamic display, network NAT, and shared folders).
  * `Data.img`: Sparse APFS virtual disk image.
  * `AuxiliaryStorage.bin`: Guest NVRAM storage.
  * `HardwareModel.bin`: Serialized hardware descriptor.
  * `MachineIdentifier.bin`: Unique guest machine identifier.
* **Vagrant Provider:** Box artifacts are packaged as `<os_name>-<version>-aarch64.utm.box` and executed via the open-source `vagrant_utm` Vagrant provider plugin with the native `:darwin` guest capability.

---

## 3. Host Prerequisites

Ensure your host environment meets the following requirements:

| Component | Minimum Requirement | Recommended |
| :--- | :--- | :--- |
| **Host Hardware** | Apple Silicon Mac (M1/M2/M3/M4) | M-series Pro/Max with >= 16 GB RAM |
| **Host Operating System** | macOS 14.0 (Sonoma) or newer | macOS 14.6+ or macOS 15.0+ |
| **Free Storage Space** | 80 GB free disk space | 120 GB (for IPSW cache and VM disk) |
| **Hypervisor** | UTM 4.5.0+ (`/Applications/UTM.app`) | Latest stable UTM release |
| **Vagrant** | Vagrant 2.3.0+ | Latest Vagrant release |
| **Vagrant Plugin** | `vagrant_utm` gem | Installed via `vagrant plugin install vagrant_utm` |

### Installing Required Tools

```bash
# Install UTM via Homebrew Cask (if not already installed)
brew install --cask utm

# Install Vagrant and the UTM provider plugin
brew install hashicorp/tap/hashicorp-vagrant
vagrant plugin install vagrant_utm
```

---

## 4. Building a macOS Box Locally

Bento provides the automated `macos-utm-builder.sh` script to manage IPSW acquisition, integrity verification, bundle generation, and packaging.

### Quick Start (macOS 14 Sonoma)

```bash
./macos-utm-builder.sh --version 14
```

### Building macOS 15 Sequoia

```bash
./macos-utm-builder.sh --version 15 --cpus 4 --memory 8192
```

### Available Command-Line Options

```
Usage: ./macos-utm-builder.sh [OPTIONS]

Options:
  --version <14|15>    Target macOS version (default: 14)
  --cpus <count>       Number of vCPUs to allocate (default: 4)
  --memory <MB>        Memory in MB to allocate (default: 4096)
  --disk-size <GB>     Disk image size in GB (default: 64)
  --dry-run            Simulate operations without downloading or running
  -h, --help           Display usage information
```

The completed Vagrant box will be written to:
`builds/build_complete/macos-<version>-aarch64.utm.box`

---

## 5. Using the Built Box with Vagrant

### Adding the Box to Vagrant

```bash
vagrant box add --name bento/macos-14-arm64 builds/build_complete/macos-14-aarch64.utm.box
```

### Initializing a Vagrant Project

Create a `Vagrantfile` in a test directory:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "bento/macos-14-arm64"
  config.vm.guest = :darwin
  config.vm.communicator = "ssh"

  # Use rsync for directory synchronization
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.provider "utm" do |utm|
    utm.cpus = 4
    utm.memory = 4096
  end
end
```

### Starting and Connecting to the Guest

```bash
# Start the macOS guest VM
vagrant up --provider utm

# Connect via SSH
vagrant ssh

# Verify guest OS and architecture
sw_vers
uname -m  # Expected: arm64
whoami    # Expected: vagrant
sudo whoami # Expected: root (passwordless sudo)

# Halt (bring down) and destroy when finished
vagrant halt      # Stops the guest VM cleanly (standard Vagrant equivalent of "down")
vagrant destroy -f # Tears down and removes the guest VM completely
```

---

## 6. Vagrant Commands & Capabilities Verification Matrix

| Command / Feature | Supported? | Status & Technical Implementation |
| :--- | :---: | :--- |
| **`vagrant up`** | **YES** | Starts the UTM macOS VM via `utmctl start`, detects the dynamically assigned IP, and waits for SSH availability. |
| **`vagrant down`** | **NOTE** | `down` is not a standard Vagrant subcommand. In Vagrant, use **`vagrant halt`** to gracefully shut down the machine, or **`vagrant destroy`** to delete the VM instance. |
| **`vagrant ssh`** | **YES** | Connects to the guest via standard OpenSSH. The `vagrant` user has public keys configured in `/Users/vagrant/.ssh/authorized_keys` and passwordless `sudo` privileges. |
| **`vagrant snapshot`** | **YES (NATIVE CLI)** | Native `vagrant snapshot save / restore / list / delete` is fully supported via Bento's driver extension (`Bento::VagrantUtmMacosSnapshot`). It transparently intercepts snapshot commands on Apple backend guests and uses `utmctl clone` / APFS copy-on-write, bypassing `qemu-img` limitations. |
| **Shared Directory** | **YES (VirtioFS & `rsync`)** | Near-native memory-mapped bidirectional sync via Apple's native **VirtioFS** (`directory_share_mode = "virtFS"`), automatically mapped from `/Volumes/My Shared Files` to `/vagrant`. Fallback `rsync` synchronization over SSH is also supported. |

---

## 7. Synced Folders & Optimization Notes

* **VirtioFS Bidirectional Sync:** Apple Silicon macOS guests on UTM use Apple's `Virtualization.framework` VirtioFS file system device (`directory_share_mode = "virtFS"`). The host project directory is mapped with native filesystem performance and true bidirectional synchronization. Changes made inside the guest immediately reflect on the host, and vice-versa.
* **rsync Fallback:** `type: "rsync"` is configured as initial sync to ensure files exist at boot time even before the VirtioFS kernel filesystem driver automounts the volume.
* **Power Management:** System sleep, display sleep, and screensavers are disabled by default via `systemsetup` and `PlistBuddy` during provisioning to prevent automated CI / development tasks from stalling.
* **Auto-Login:** The `vagrant` account has auto-login configured to allow testing GUI workflows when needed.
* **Screen Capturing:** Native screenshotting can be invoked over SSH at any time via `vagrant ssh -c "screencapture -x /vagrant/screenshot.png"`. Because `/vagrant` uses VirtioFS, the captured image immediately appears on the host Mac.
