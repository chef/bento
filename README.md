# Bento

Bento is a project that encapsulates [Packer](https://www.packer.io/) templates for building [Vagrant](https://www.vagrantup.com/) base boxes. A subset of templates are built and published to the [bento org](https://app.vagrantup.com/bento) on Vagrant Cloud. These published boxes serve as the default boxes for [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant/).

***NOTE:**

- Virutalbox 6.x requires disabling nat config that allows vbox 7.x guests to connect to the host. To use comment out lines #161 and #162 in bento/packer_templates/pkr-variables.pkr.hcl or add variable `vboxmanage = []` to os_pkrvars files.
- When running packer build command the output directory is relative to the working directory the command is currently running in. Suggest running packer build commands from bento root directory for build working files to be placed in bento/builds/(build_name) directory by default. If the output_directory variable isn't overwritten a directory called builds/(build_name) will be created in the current working directory that you are running the command from

## Using Public Boxes

Adding a bento box to Vagrant

```bash
vagrant box add bento/ubuntu-18.04
```

Using a bento box in a Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
end
```

### Building Boxes

#### Requirements

- [Packer](https://www.packer.io/) >= 1.7.0
- [Vagrant](https://www.vagrantup.com/)
- At least one of the following virtualization providers:
   - [VirtualBox](https://www.virtualbox.org/)
   - [VMware Fusion](https://www.vmware.com/products/fusion.html)
   - [VMware Workstation](https://www.vmware.com/products/workstation-pro.html)
   - [Parallels Desktop Pro](https://www.parallels.com/products/desktop/)*2 also requires [Parallels Virtualization SDK](https://www.parallels.com/products/desktop/download/) for versions < 19.x
   - [qemu](https://www.qemu.org/) *1
   - [Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/) *1

*1**NOTE:** support for these providers is considered experimental and corresponding Vagrant Cloud images may or may not exist.
*2**NOTE:** AARCH64 or ARM64 support is only guaranteed through parallels provider.

### Using `bento` executable

#### build

To build a Debian vagrant box using the bento tool with the template available in the `os_pkrvars` dir, we can use the following command:

```bash
bento build --cpus 2 os_pkrvars/debian/debian-12-x86_64.pkrvars.hcl
```

Other available options:

- cpus - Specify the number of CPUs needed in the new build
- mem - Specify the memory
- config - Use a configuration file other than default builds.yml
- vars - Comma seperated list of variable names equal values (ex: boot_wait="2s",ssh_timeout="5s")
- var_files - Comma seperated list of pkrvar.hcl files to include in the builds (ex: /path/to/var_file.pkrvars.hcl,/path/to/next/var_file2.pkrvars.hcl)
- metadata_only - Only generate the metadata json file
- mirror - The template will have a default mirror link, if you wish to use an alternative one, you can utilise this configuration
- dry-run - This will not create any build, but will create a metadata file for reference
- only - Only build some Packer builds (Default: parallels-iso.vm,virtualbox-iso.vm,vmware-iso.vm
- except - Build all Packer builds except these (ex: parallels-iso.vm,virtualbox-iso.vm,vmware-iso.vm)
- debug - Print the debug logs
- gui - Packer will be building VirtualBox virtual machines by launching a GUI that shows the console of the machine being built. This option is false by default
- single - This can be used to disable the parallel builds

#### list

Used to list all builds available for the workstations cpu architecture. This list is also filtered by the build.yml file do_not_build: section. All entries are matched via regex to filter out build templates from the list.

This only shows what would be built with `bento build` and no template is specified. If any template is specified even if it's in the build.yml to be filtered it'll override the filter.

```bash
bento list
```

#### test

If you have successfully built a vagrant box using the bento tool, you should have the vagrant box and a metadata file in the `builds` folder. You can use these files to test the build with a test-kitchen configuration. Run the following command to test the build.

```bash
bento test
```

#### upload

To upload boxes in the builds directory to your vagrant cloud account update the build.yml file to specify your account name and which OSs are going to be public.

Make sure you have configured the vagrant cli and logged into your account for the upload command to work.

```bash
bento upload
```

When running `bento upload` it'll read each <box_name>._metadata.json file and use the data provided to generate the `vagrant cloud publish` command with the descriptions, version, provider, and checksums all coming from the <box_name>._metadata.json file.

### Using `packer`

To build a Ubuntu 22.04 box for only the VirtualBox provider

```bash
cd <path/to>/bento
packer init -upgrade ./packer_templates
packer build -only=virtualbox-iso.vm -var-file=os_pkrvars/ubuntu/ubuntu-22.04-x86_64.pkrvars.hcl ./packer_templates
```

To build latest Debian 12 boxes for all possible providers (simultaneously)

```bash
cd <path/to>/bento
packer init -upgrade ./packer_templates
packer build -var-file=os_pkrvars/debian/debian-12-x86_64.pkrvars.hcl ./packer_templates
```

To build latest CentOS 7 boxes for all providers except VMware and Parallels

```bash
cd <path/to>/bento
packer init -upgrade ./packer_templates
packer build -except=parallels-iso.vm,vmware-iso.vm -var-file=os_pkrvars/centos/centos-7-x86_64.pkrvars.hcl ./packer_templates
```

To use an alternate url

````bash
cd <path/to>/bento
packer init -upgrade ./packer_templates
packer build -var 'iso_url=https://mirrors.rit.edu/fedora/fedora/linux/releases/39/Server/x86_64/iso/Fedora-Server-dvd-x86_64-39-1.5.iso' -var-file=os_pkrvars/fedora/fedora-39-x86_64.pkrvars.hcl ./packer_templates
````

If the build is successful, your box files will be in the `builds` directory at the root of the repository.

### KVM/qemu support for Windows

You must download [the iso image with the Windows drivers for paravirtualized KVM/qemu hardware](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso). You can do this from the command line: `wget -nv -nc https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O virtio-win.iso` and place it in the packer_templates/win_answer_files/ directory.

You can use the following sample command to build a KVM/qemu Windows box:

```bash
packer init -upgrade ./packer_templates
packer build --only=qemu.vm -var-file=os_pkrvars/windwos/windows-2022-x86_64.pkrvars.hcl ./packer_templates
```

### Proprietary Templates

Templates for operating systems only available via license or subscription are also available in the repository, these include but are not limited to: Red Hat Enterprise Linux, and SUSE Linux Enterprise. As the ISOs are not publicly available the URL values will need to be overridden as appropriate. We rely on the efforts of those with access to licensed versions of the operating systems to keep these up-to-date.

### Networking/Firewalls

Most of the providers expect unrestricted access to networking in order to build as expected. We can't enumerate all possible firewall configurations but include some snippets below that might be useful to users.

### Windows

```powershell
$VS = "Standardswitch"
$IF_ALIAS = (Get-NetAdapter -Name "vEthernet ($VS)").ifAlias
New-NetFirewallRule -Displayname "Allow incomming from $VS" -Direction Inbound -InterfaceAlias $IF_ALIAS -Action Allow
```

#### Hyper-V Generation 2 VM's

Hyper-V Gen 2 VMs do not support floppy drives. If you previously provided resources using a floppy drive, you must add those files to your Gen 2 iso images, in particular:

- `autounattend.xml`: The Gen 2 `autounattend.xml` file supports EFI partitions. Update the `autounattend.xml` with the correct Windows version for your systems and ensure that the partitions are correct for your situation. You also need to manage the driver disk that holds the hyper-v guest services drivers and adjust the `autounattend.xml` file as appropriate.

### Bugs and Issues

Please use GitHub issues to report bugs, features, or other problems.

## Related projects

A huge thank you to these related projects from which we've taken inspiration and often used as a source for workarounds in complex world of base box building.

- <https://github.com/boxcutter>
- <https://github.com/lavabit/robox>
- <https://github.com/mcandre/packer-templates>
- <https://github.com/timsutton/osx-vm-templates>
- <https://github.com/ferventcoder/vagrant-windows-puppet/tree/master/baseboxes>

## License & Authors

These basebox templates were converted from [veewee](https://github.com/jedi4ever/veewee) definitions originally based on [work done by Tim Dysinger](https://github.com/dysinger) to make "Don't Repeat Yourself" (DRY) modular baseboxes. Thanks Tim!

- Author: Chris McClimans ([chris@hippiehacker.org](mailto:chris@hippiehacker.org))
- Author: Fletcher Nichol ([fnichol@nichol.ca](mailto:fnichol@nichol.ca))
- Author: Joshua Timberman ([joshua@chef.io](mailto:joshua@chef.io))
- Author: Julian Dunn ([jdunn@chef.io](mailto:jdunn@chef.io))
- Author: Ross Timson ([ross@rosstimson.com](mailto:ross@rosstimson.com))
- Author: Seth Chisamore ([schisamo@chef.io](mailto:schisamo@chef.io))
- Author: Stephen Delano ([stephen@chef.io](mailto:stephen@chef.io))
- Author: Tim Dysinger ([tim@dysinger.net](mailto:tim@dysinger.net))
- Author: Tim Smith ([tsmith@chef.io](mailto:tsmith@chef.io))
- Author: Tom Duffield ([tom@chef.io](mailto:tom@chef.io))
- Author: Corey Hemminger ([corey.hemminger@progress.com](mailto:corey.hemminger@progress.com))

```text
Copyright 2012-2023, Progress Software, Inc. (<legal@chef.io>)
Copyright 2011-2012, Tim Dysinger (<tim@dysinger.net>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
