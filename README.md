# Bento

Bento is a project that encapsulates [Packer](https://www.packer.io/) templates for building [Vagrant](https://www.vagrantup.com/) base boxes. A subset of templates are built and published to the [bento org](https://app.vagrantup.com/bento) on Vagrant Cloud. These published boxes serve as the default boxes for [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant/).

### Using Public Boxes

Adding a bento box to Vagrant

```
$ vagrant box add bento/ubuntu-18.04
```

Using a bento box in a Vagrantfile

```
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
end
```

### Building Boxes

#### Requirements

- [Packer](https://www.packer.io/)
- [Vagrant](https://www.vagrantup.com/)
- At least one of the following virtualization providers:
  - [VirtualBox](https://www.virtualbox.org/)
  - [VMware Fusion](https://www.vmware.com/products/fusion.html)
  - [VMware Workstation](https://www.vmware.com/products/workstation-pro.html)
  - [Parallels Desktop](https://www.parallels.com/products/desktop/) also requires [Parallels Virtualization SDK](https://www.parallels.com/products/desktop/download/)
  - [KVM](https://www.linux-kvm.org/page/Main_Page) *
  - [Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/) *

\***NOTE:** support for these providers is considered experimental and corresponding Vagrant Cloud images may or may not exist.

#### Using `bento` executable
To build a Debian vagrant box using the bento tool with the template available in the `packer_templates` dir, we can use the following command:

```
bento build --cpus 2 packer_templates/debian/debian-11.6-i386.json
```

Other available options:
- cpus - Specify the number of CPUs needed in the new build.
- mem - Specify the memory
- mirror - The template will have a default mirror link, if you wish to use an alternative one, you can utilise this configuration.
- dry-run - This will not create any build, but will create a metadata file for reference.
- debug - Print the debug logs
- headed - Packer will be building VirtualBox virtual machines by launching a GUI that shows the console of the machine being built. This option is false by default
- single - This can be used to disable the parallel builds.

#### Using `packer`

To build an Ubuntu 18.04 box for only the VirtualBox provider

```
$ cd packer_templates/ubuntu
$ packer build -only=virtualbox-iso ubuntu-18.04-amd64.json
```

To build Debian 11.6 32bit boxes for all possible providers (simultaneously)

```
$ cd packer_templates/debian
$ packer build debian-11.6-i386.json
```

To build CentOS 7.7 boxes for all providers except VMware and Parallels

```
$ cd packer_templates/centos
$ packer build -except=parallels-iso,vmware-iso centos-7.7-x86_64.json
```

To use an alternate mirror

```
$ cd packer_templates/fedora
$ packer build -var 'mirror=http://mirror.utexas.edu/fedora/linux' fedora-31-x86_64.json
```

To build a Windows 10 Enterprise Gen 2 box for the Hyper-V provider

```
$ cd packer_templates/windows
$ packer build windows-10gen2.json
```

If the build is successful, your box files will be in the `builds` directory at the root of the repository.

\***NOTE:** box_basename can be overridden like other Packer vars with `-var 'box_basename=ubuntu-18.04'`

#### KVM/qemu support for Windows

You must download [the iso image with the Windows drivers for paravirtualized KVM/qemu hardware](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso). You can do this from the command line: `wget -nv -nc https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O virtio-win.iso`.

You can use the following sample command to build a KVM/qemu Windows box:

```
packer build --only=qemu --var virtio_win_iso=~/virtio-win.iso windows-2019.json
```

### Proprietary Templates

Templates for operating systems only available via license or subscription are also available in the repository, these include but are not limited to: Red Hat Enterprise Linux, and SUSE Linux Enterprise. As the ISOs are not publicly available the URL values will need to be overridden as appropriate. We rely on the efforts of those with access to licensed versions of the operating systems to keep these up-to-date.

### Networking/Firewalls

Most of the providers expect unrestricted access to networking in order to build as expected. We can't enumerate all possible firewall configurations but include some snippets below that might be useful to users.

#### Windows

```powershell
$VS = "Standardswitch"
$IF_ALIAS = (Get-NetAdapter -Name "vEthernet ($VS)").ifAlias
New-NetFirewallRule -Displayname "Allow incomming from $VS" -Direction Inbound -InterfaceAlias $IF_ALIAS -Action Allow
```

#### Hyper-V Generation 2 VM's

Hyper-V Gen 2 VMs do not support floppy drives. If you previously provided resources using a floppy drive, you must add those files to your Gen 2 iso images, in particular:

- `autounattend.xml`: The Gen 2 `autounattend.xml` file supports EFI partitions. Update the `autounattend.xml` with the correct Windows version for your systems and ensure that the partitions are correct for your situation. You also need to manage the driver disk that holds the hyper-v guest services drivers and adjust the `autounattend.xml` file as appropriate.
- `base_setup.ps1`

### Testing the build with the test-kitchen
If you have successfully built a vagrant box using the bento tool, you should have the vagrant box and a metadata file in the `builds` folder. You can use these files to test the build with a test-kitchen configuration. Place your `kitchen.yml.erb` and `bootstrap.sh.erb` files inside the `templates` directory and run the following command to test the build.

```
bento test
```

## Bugs and Issues

Please use GitHub issues to report bugs, features, or other problems.

## Related projects

A huge thank you to these related projects from which we've taken inspiration and often used as a source for workarounds in complex world of base box building.

* https://github.com/boxcutter
* https://github.com/lavabit/robox
* https://github.com/mcandre/packer-templates
* https://github.com/timsutton/osx-vm-templates
* https://github.com/ferventcoder/vagrant-windows-puppet/tree/master/baseboxes

## License & Authors

These basebox templates were converted from [veewee](https://github.com/jedi4ever/veewee) definitions originally based on [work done by Tim Dysinger](https://github.com/dysinger/basebox) to make "Don't Repeat Yourself" (DRY) modular baseboxes. Thanks Tim!

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

```text
Copyright 2012-2021, Chef Software, Inc. (<legal@chef.io>)
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
