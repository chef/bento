# Bento

Bento is a project that encapsulates [Packer](http://packer.io) templates for building
[Vagrant](http://vagrantup.com) baseboxes. We use these boxes internally at Opscode for
testing Hosted Enterprise Chef, Private Enterprise Chef and our open source [cookbooks](http://community.opscode.com/users/Opscode)
via [test-kitchen](http://github.com/opscode/test-kitchen).

## Current Baseboxes

The following baseboxes are publicly available and were built using
this project. Note that our baseboxes do not include Chef Client.
Vagrant can be instructed to install Chef at runtime using the
[vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) plugin.

### VirtualBox

These baseboxes were all built using a Mac OS X host running VirtualBox 4.3.2, and have that format of Guest Extensions.

* [opscode-centos-5.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-5.10-i386_chef-provisionerless.box)
* [opscode-centos-5.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-5.10_chef-provisionerless.box)
* [opscode-centos-6.4-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4-i386_chef-provisionerless.box)
* [opscode-centos-6.4](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4_chef-provisionerless.box)
* [opscode-debian-6.0.8-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-6.0.8-i386_chef-provisionerless.box)
* [opscode-debian-6.0.8](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-6.0.8_chef-provisionerless.box)
* [opscode-debian-7.2.0-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.2.0-i386_chef-provisionerless.box)
* [opscode-debian-7.2.0](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.2.0_chef-provisionerless.box)
* [opscode-fedora-18-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-18-i386_chef-provisionerless.box)
* [opscode-fedora-18](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-18_chef-provisionerless.box)
* [opscode-fedora-19-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-19-i386_chef-provisionerless.box)
* [opscode-fedora-19](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-19_chef-provisionerless.box)
* [opscode-fedora-20-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-20-i386_chef-provisionerless.box)
* [opscode-fedora-20](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-20_chef-provisionerless.box)
* [opscode-freebsd-9.2-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_freebsd-9.2-i386_chef-provisionerless.box)
* [opscode-freebsd-9.2](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_freebsd-9.2_chef-provisionerless.box)
* [opscode-ubuntu-10.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-10.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-10.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-10.04_chef-provisionerless.box)
* [opscode-ubuntu-12.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-12.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box)
* [opscode-ubuntu-12.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.10-i386_chef-provisionerless.box)
* [opscode-ubuntu-12.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.10_chef-provisionerless.box)
* [opscode-ubuntu-13.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-13.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.04_chef-provisionerless.box)
* [opscode-ubuntu-13.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.10-i386_chef-provisionerless.box)
* [opscode-ubuntu-13.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.10_chef-provisionerless.box)

### VMWare

These baseboxes were all built using a Mac OS X host running VMWare Fusion 6.0.2, and have that version of VMWare Tools.
The boxes should work unchanged in VMWare Workstation for Windows or Linux.

* [opscode-centos-5.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-5.10-i386_chef-provisionerless.box)
* [opscode-centos-5.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-5.10_chef-provisionerless.box)
* [opscode-centos-6.4-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-6.4-i386_chef-provisionerless.box)
* [opscode-centos-6.4](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-6.4_chef-provisionerless.box)
* [opscode-debian-6.0.8-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-6.0.8-i386_chef-provisionerless.box)
* [opscode-debian-6.0.8](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-6.0.8_chef-provisionerless.box)
* [opscode-debian-7.2.0-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-7.2.0-i386_chef-provisionerless.box)
* [opscode-debian-7.2.0](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-7.2.0_chef-provisionerless.box)
* [opscode-fedora-18-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-18-i386_chef-provisionerless.box)
* [opscode-fedora-18](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-18_chef-provisionerless.box)
* [opscode-fedora-19-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-19-i386_chef-provisionerless.box)
* [opscode-fedora-19](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-19_chef-provisionerless.box)
* [opscode-fedora-20-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-20-i386_chef-provisionerless.box)
* [opscode-fedora-20](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-20_chef-provisionerless.box)
* [opscode-freebsd-9.2-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_freebsd-9.2-i386_chef-provisionerless.box)
* [opscode-freebsd-9.2](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_freebsd-9.2_chef-provisionerless.box)
* [opscode-ubuntu-10.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-10.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-10.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-10.04_chef-provisionerless.box)
* [opscode-ubuntu-12.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-12.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-12.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-12.04_chef-provisionerless.box)
* [opscode-ubuntu-12.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-12.10-i386_chef-provisionerless.box)
* [opscode-ubuntu-12.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-12.10_chef-provisionerless.box)
* [opscode-ubuntu-13.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-13.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-13.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-13.04_chef-provisionerless.box)
* [opscode-ubuntu-13.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-13.10-i386_chef-provisionerless.box)
* [opscode-ubuntu-13.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-13.10_chef-provisionerless.box)

## Older Baseboxes

Older baseboxes include Chef and therefore are not compatible with some
new plugins. The full list of old boxes are available in the [old boxes file](https://github.com/opscode/bento/blob/master/OLD-BOXES.md).

## Build Your Own Boxes

First, install [Packer](http://packer.io) and then clone this project.

Inside the `packer` directory, a JSON file describes each box that can be built. You can use `packer build` to build the
boxes.

    $ packer build debian-7.2.0-i386.json

If you want to use a another mirror site, use mirror variable.

    $ packer build -var 'mirror=http://ftp.jaist.ac.jp/pub/Linux/debian-cdimage/release' debian-7.2.0-i386.json

If you only have VMware or VirtualBox available, you may also tell Packer to build only that box.

    $ packer build -only=virtualbox debian-7.2.0-i386.json

Congratulations! You now have box(es) in the ../builds directory that you can then add to Vagrant and start testing cookbooks.

### Proprietary Boxes

Red Hat Enterprise Linux and SUSE Linux Enterprise Server templates are provided; however, their ISOs are not publicly retrievable. The URLs in those templates are bogus; you should substitute your server where you host the ISOs, using the mirror variable as above.

### Veewee Definitions

Packer does not yet support Windows, so veewee definitions are still used for building those boxes. You must build these
boxes yourself due to licensing constraints. You can build these as follows:

    $ bundle install
    $ bundle exec veewee vbox build [definition-name]

## Bugs and Issues

Use the [issue tracker](http://tickets.opscode.com/browse/BENTO) to report
bugs, features or other issues.

## Contributing

[How to contribute to Opscode open source software projects](http://wiki.opscode.com/display/chef/How+to+Contribute)

## License & Authors

These basebox templates were converted from [veewee](https://github.com/jedi4ever/veewee)
definitions originally based on
[work done by Tim Dysinger](https://github.com/dysinger/basebox) to
make "Don't Repeat Yourself" (DRY) modular baseboxes. Thanks Tim!

- Author: Seth Chisamore (<schisamo@opscode.com>)
- Author: Stephen Delano (<stephen@opscode.com>)
- Author: Joshua Timberman (<joshua@opscode.com>)
- Author: Tim Dysinger (<tim@dysinger.net>)
- Author: Chris McClimans (<chris@hippiehacker.org>)
- Author: Julian Dunn (<jdunn@opscode.com>)
- Author: Tom Duffield (<tom@opscode.com>)
- Author: Ross Timson (<ross@rosstimson.com>)

```text
Copyright 2012-2013, Opscode, Inc. (<legal@opscode.com>)
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
