# Bento

[![Build Status](http://img.shields.io/travis/chef/bento.svg)][travis]

Bento is a project that encapsulates [Packer](https://www.packer.io/) templates for building [Vagrant](https://www.vagrantup.com/) base boxes. A subset of templates are built and published to the [bento org](https://app.vagrantup.com/bento) on Vagrant Cloud. The boxes also serve as default boxes for [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant/).

### Using Public Boxes

Adding a bento box to Vagrant

```
$ vagrant box add bento/ubuntu-16.04
```

Using a bento box in a Vagrantfile

```
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-16.04"
end
```

### Building Boxes

#### Requirements

- [Packer](https://www.packer.io/)
- At least one of the following virtualization providers:
  - [VirtualBox](https://www.virtualbox.org)
  - [VMware Fusion](https://www.vmware.com/products/fusion.html)
  - [VMware Workstation](https://www.vmware.com/products/workstation.html)
  - [Parallels Desktop](http://www.parallels.com/products/desktop)
  - [KVM](https://www.linux-kvm.org/page/Main_Page) *
  - [Hyper-V](https://technet.microsoft.com/en-us/library/hh831531(v=ws.11).aspx) *

\***NOTE:** support for these providers is considered experimental and corresponding Vagrant Cloud images may or may not exist.

#### Using `packer`

To build an Ubuntu 16.04 box for only the VirtualBox provider

```
$ cd ubuntu
$ packer build -only=virtualbox-iso ubuntu-16.04-amd64.json
```

To build Debian 9.1 32bit boxes for all possible providers (simultaneously)

```
$ cd debian
$ packer build debian-9.1-i386.json
```

To build CentOS 7.3 boxes for all providers except VMware and Parallels

```
$ cd centos
$ packer build -except=parallels-iso,vmware-iso centos-7.3-x86_64.json
```

To use an alternate mirror

```
$ cd fedora
$ packer build -var 'mirror=http://mirror.utexas.edu/fedora/linux' fedora-26-x86_64.json
```

If the build is successful, ready to import box files will be in the `builds` directory at the root of the repository.

\***NOTE:** box_basename can be overridden like other Packer vars with `-var 'box_basename=ubuntu-16.04'`

### Proprietary Templates

Templates for operating systems only available via license or subscription are also available in the repository, these include but are not limited to: Mac OS X, Red Hat Enterprise Linux, and SUSE Linux Enterprise. As the ISOs are not publicly available the URL values will need to be overridden as appropriate. We rely on the efforts of those with access to licensed versions of the operating systems to keep these up-to-date.

#### macOS / OSX

See our [wiki page](https://github.com/chef/bento/wiki/macOS)

#### Windows

The project does not include many definitions for building Windows boxes. For other approaches to building Windows boxes, please see the following community projects:

- [Mischa Taylor's Boxcutter project](https://github.com/boxcutter)
- [Vagrant Windows Boxes and Puppet](https://github.com/ferventcoder/vagrant-windows-puppet/tree/master/baseboxes)

## Bugs and Issues

Please use GitHub issues to report bugs, features, or other problems.

## License & Authors

These basebox templates were converted from [veewee](https://github.com/jedi4ever/veewee) definitions originally based on [work done by Tim Dysinger](https://github.com/dysinger/basebox) to make "Don't Repeat Yourself" (DRY) modular baseboxes. Thanks Tim!

Mac OS X templates were adopted wholesale from [Fletcher Nichol's packer templates](https://github.com/fnichol/packer-templates).

- Author: Seth Chisamore ([schisamo@chef.io](mailto:schisamo@chef.io))
- Author: Stephen Delano ([stephen@chef.io](mailto:stephen@chef.io))
- Author: Joshua Timberman ([joshua@chef.io](mailto:joshua@chef.io))
- Author: Tim Dysinger ([tim@dysinger.net](mailto:tim@dysinger.net))
- Author: Chris McClimans ([chris@hippiehacker.org](mailto:chris@hippiehacker.org))
- Author: Julian Dunn ([jdunn@chef.io](mailto:jdunn@chef.io))
- Author: Tom Duffield ([tom@chef.io](mailto:tom@chef.io))
- Author: Ross Timson ([ross@rosstimson.com](mailto:ross@rosstimson.com))
- Author: Fletcher Nichol ([fnichol@nichol.ca](mailto:fnichol@nichol.ca))

```text
Copyright 2012-2017, Chef Software, Inc. (<legal@chef.io>)
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

[travis]: https://travis-ci.org/chef/bento

