# Bento

[![Build status](https://badge.buildkite.com/2d56b8ca08562a7d17fd25920a2e02079c5e6f28cbc6d426ee.svg?branch=master)](https://buildkite.com/chef-oss/chef-bento-master-verify)

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
- At least one of the following virtualization providers:
  - [VirtualBox](https://www.virtualbox.org)
  - [VMware Fusion](https://www.vmware.com/products/fusion.html)
  - [VMware Workstation](https://www.vmware.com/products/workstation.html)
  - [Parallels Desktop](http://www.parallels.com/products/desktop) also requires [Parallels Virtualization SDK](https://www.parallels.com/products/desktop/download/)
  - [KVM](https://www.linux-kvm.org/page/Main_Page) *
  - [Hyper-V](https://technet.microsoft.com/en-us/library/hh831531(v=ws.11).aspx) *

\***NOTE:** support for these providers is considered experimental and corresponding Vagrant Cloud images may or may not exist.

#### Using `packer`

To build an Ubuntu 18.04 box for only the VirtualBox provider

```
$ cd ubuntu
$ packer build -only=virtualbox-iso ubuntu-18.04-amd64.json
```

To build Debian 10.2 32bit boxes for all possible providers (simultaneously)

```
$ cd debian
$ packer build debian-10.2-i386.json
```

To build CentOS 7.7 boxes for all providers except VMware and Parallels

```
$ cd centos
$ packer build -except=parallels-iso,vmware-iso centos-7.7-x86_64.json
```

To use an alternate mirror

```
$ cd fedora
$ packer build -var 'mirror=http://mirror.utexas.edu/fedora/linux' fedora-31-x86_64.json
```

If the build is successful, ready to import box files will be in the `builds` directory at the root of the repository.

\***NOTE:** box_basename can be overridden like other Packer vars with `-var 'box_basename=ubuntu-18.04'`

#### KVM/qemu support for Windows

You must download [the iso image with the Windows drivers for paravirtualized KVM/qemu hardware](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso). You can do this from the command line: `wget -nv -nc https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O virtio-win.iso`.

You can use the following sample command to build a KVM/qemu Windows box:

```
packer build --only=qemu --var virtio_win_iso=~/virtio-win.iso windows-2019.json
```

### Proprietary Templates

Templates for operating systems only available via license or subscription are also available in the repository, these include but are not limited to: macOS, Red Hat Enterprise Linux, and SUSE Linux Enterprise. As the ISOs are not publicly available the URL values will need to be overridden as appropriate. We rely on the efforts of those with access to licensed versions of the operating systems to keep these up-to-date.

### Networking/Firewalls

Most of the providers expect unrestricted access to networking in order to build as expected. We can't enumerate all possible firewall configurations but include some snippets below that might be useful to users.

#### Windows

```
$VS = "Standardswitch"
$IF_ALIAS = (Get-NetAdapter -Name "vEthernet ($VS)").ifAlias
New-NetFirewallRule -Displayname "Allow incomming from $VS" -Direction Inbound -InterfaceAlias $IF_ALIAS -Action Allow
```

#### macOS / OSX

See this [wiki page](https://github.com/chef/bento/wiki/macOS)

## Bugs and Issues

Please use GitHub issues to report bugs, features, or other problems.

## Related projects

* https://github.com/boxcutter
* https://github.com/mcandre/packer-templates
* https://github.com/timsutton/osx-vm-templates
* https://github.com/ferventcoder/vagrant-windows-puppet/tree/master/baseboxes

## License & Authors

These basebox templates were converted from [veewee](https://github.com/jedi4ever/veewee) definitions originally based on [work done by Tim Dysinger](https://github.com/dysinger/basebox) to make "Don't Repeat Yourself" (DRY) modular baseboxes. Thanks Tim!

macOS templates were adopted wholesale from [Fletcher Nichol's packer templates](https://github.com/fnichol/packer-templates).

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
Copyright 2012-2019, Chef Software, Inc. (<legal@chef.io>)
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
