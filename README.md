# Bento

Bento is a project that encapsulates [Packer](http://packer.io) templates for building
[Vagrant](http://vagrantup.com) baseboxes. We use these boxes internally at Opscode for
testing Hosted Enterprise Chef, Private Enterprise Chef and our open source [cookbooks](http://community.opscode.com/users/Opscode) via [test-kitchen](http://github.com/opscode/test-kitchen).

These basebox templates were converted from [veewee](https://github.com/jedi4ever/veewee)
definitions originally based on
[work done by Tim Dysinger](https://github.com/dysinger/basebox) to
make "Don't Repeat Yourself" (DRY) modular baseboxes. Thanks Tim!

## Current Baseboxes

The following baseboxes are publicly available and were built using
this project. Note that our baseboxes no longer include Chef Client.
Vagrant can be instructed to install Chef at runtime using the
[vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) plugin.

64-bit boxes:

* [opscode-centos-5.9](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.9_provisionerless.box)
* [opscode-centos-6.4](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box)
* [opscode-debian-7.1.0](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_debian-7.1.0_provisionerless.box)
* [opscode-fedora-18](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode-fedora-18_provisionerless.box)
* [opscode-fedora-19](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode-fedora-19_provisionerless.box)
* [opscode-ubuntu-10.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_provisionerless.box)
* [opscode-ubuntu-12.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box)
* [opscode-ubuntu-13.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-13.04_provisionerless.box)

32-bit boxes:

* [opscode-centos-5.9-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.9-i386_provisionerless.box)
* [opscode-centos-6.4-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4-i386_provisionerless.box)
* [opscode-debian-7.1.0-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_debian-7.1.0-i386_provisionerless.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_provisionerless.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_provisionerless.box)

## Older Baseboxes

Older baseboxes include Chef.

The following base boxes were built with Chef 11.4.4.

64-bit boxes:

* [opscode-centos-5.9](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.9_chef-11.4.4.box)
* [opscode-centos-6.4](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_chef-11.4.4.box)
* [opscode-ubuntu-10.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-11.4.4.box)
* [opscode-ubuntu-12.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.4.4.box)

32-bit boxes:

* [opscode-centos-5.9-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.9-i386_chef-11.4.4.box)
* [opscode-centos-6.4-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4-i386_chef-11.4.4.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_chef-11.4.4.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_chef-11.4.4.box)

The following base boxes were built with Chef 11.4.0.

64-bit boxes:

* [opscode-centos-5.9](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.9_chef-11.4.0.box)
* [opscode-centos-6.4](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_chef-11.4.0.box)
* [opscode-ubuntu-10.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-11.4.0.box)
* [opscode-ubuntu-12.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.4.0.box)

32-bit boxes:

* [opscode-centos-5.9-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.9-i386_chef-11.4.0.box)
* [opscode-centos-6.4-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4-i386_chef-11.4.0.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_chef-11.4.0.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_chef-11.4.0.box)

The following base boxes were built with Chef 11.2.0. (No 32-bit boxes were built for Chef 11.2.0.)

* [opscode-centos-5.8](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.8_chef-11.2.0.box)
* [opscode-centos-6.3](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.3_chef-11.2.0.box)
* [opscode-ubuntu-10.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-11.2.0.box)
* [opscode-ubuntu-12.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.2.0.box)

The following base boxes were built with Chef 10.18.2.

* [opscode-centos-5.8-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.8-i386_chef-10.18.2.box)
* [opscode-centos-5.8](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-5.8_chef-10.18.2.box)
* [opscode-centos-6.3-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.3-i386_chef-10.18.2.box)
* [opscode-centos-6.3](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.3_chef-10.18.2.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_chef-10.18.2.box)
* [opscode-ubuntu-10.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-10.18.2.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_chef-10.18.2.box)
* [opscode-ubuntu-12.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-10.18.2.box)

The following base boxes were built with Chef 10.14.4.

* [opscode-centos-5.8-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/boxes/opscode-centos-5.8-i386.box)
* [opscode-centos-5.8](https://opscode-vm-bento.s3.amazonaws.com/vagrant/boxes/opscode-centos-5.8.box)
* [opscode-centos-6.3-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3-i386.box)
* [opscode-centos-6.3](https://opscode-vm-bento.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3.box)
* [opscode-ubuntu-10.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-10.04.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-10.04-i386.box)
* [opscode-ubuntu-12.04](https://opscode-vm-bento.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm-bento.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04-i386.box)

# Getting Started

First, install [Packer](http://packer.io) and then clone this project.

Inside the ``packer`` directory, a JSON file describes each box that can be built. You can use ``packer build`` to build the
boxes.

    $ packer build debian-7.1.0-i386.json

If you only have VMware or VirtualBox available, you may also tell Packer to build only that box.

    $ packer build -only=virtualbox debian-7.1.0-i386.json

Congratulations! You now have `./debian-7.1.0-i386-virtualbox.box` and `./debian-7.1.0-i386-vmware.box`, fully-functional
baseboxes that you can then add to Vagrant and start testing cookbooks.

# Veewee Definitions

The legacy veewee definitions are still in the "definitions" directory. These are unsupported and will be removed in the future.

Packer does not yet support Windows, so the veewee definitions are still used for building those boxes. You must build these boxes yourself due to licensing constraints. You can build these as follows:

    $ bundle install
    $ bundle exec veewee vbox build [definition-name]

Bugs and Issues
===============

Use the
[issue tracker](http://tickets.opscode.com/browse/BENTO) to
report bugs, features or other issues.

Contributing
============

[How to contribute to Opscode open source software projects](http://wiki.opscode.com/display/chef/How+to+Contribute)

License and Authors
===================

- Author:: Seth Chisamore (<schisamo@opscode.com>)
- Author:: Stephen Delano (<stephen@opscode.com>)
- Author:: Joshua Timberman (<joshua@opscode.com>)
- Author:: Tim Dysinger (<tim@dysinger.net>)
- Author:: Chris McClimans (<chris@hippiehacker.org>)
- Author:: Julian Dunn (<jdunn@opscode.com>)
- Author:: Tom Duffield (<tom@opscode.com>)
- Author:: Ross Timson (<ross@rosstimson.com>)

* Copyright:: 2012-2013, Opscode, Inc (<legal@opscode.com>)
* Copyright:: 2011-2012, Tim Dysinger (<tim@dysinger.net>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
