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

### Building Templates

#### Requirements

- [Packer](https://www.packer.io/)
- At least one virtualization provider:
  - [VirtualBox](https://www.virtualbox.org/)
  - [VMware Fusion](https://www.vmware.com/products/fusion.html)
  - [Parallels Desktop](http://www.parallels.com/products/desktop/)

#### Using `packer`

To build a template for all providers simultaneously

```
$ packer build ubuntu-16.04-amd64.json
```

To build a template only for a list of specific providers

```
$ packer build -only=virtualbox-iso ubuntu-16.04-amd64.json
```

To build a template for all providers except a list of specific providers

```
$ packer build -except=parallels-iso,vmware-iso ubuntu-16.04-amd64.json
```

To use an alternate mirror

```
$ packer build -var 'mirror=http://ftp.jaist.ac.jp/pub/Linux/debian-cdimage/release' ubuntu-16.04-amd64.json
```

Congratulations! Ready to import box files should be in the ../builds directory.

Notes:

- The box_basename can be overridden like other Packer vars with `-var 'box_basename=ubuntu-16.04'`

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

