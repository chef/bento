Bento is a project that encapsulates
[Veewee](https://github.com/jedi4ever/veewee/) definitions for
building [Vagrant](http://vagrantup.com) baseboxes. We use these boxes
internally at Opscode for testing Hosted Chef, Private Chef and
our open source [cookbooks](http://community.opscode.com/users/Opscode).

These basebox definitions are originally based on
[work done by Tim Dysinger](https://github.com/dysinger/basebox) to
make "Don't Repeat Yourself" (DRY) modular baseboxes. Thanks Tim!

## Current Baseboxes

The following baseboxes are publicly available and were built using
this project. Note that our baseboxes no longer include Chef Client.
Vagrant can be instructed to install Chef at runtime using the
[vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) plugin.

64-bit boxes:

* [opscode-centos-5.9](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.9_provisionerless.box)
* [opscode-centos-6.4](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box)
* [opscode-ubuntu-10.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_provisionerless.box)
* [opscode-ubuntu-12.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box)

32-bit boxes:

* [opscode-centos-5.9-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.9-i386_provisionerless.box)
* [opscode-centos-6.4-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4-i386_provisionerless.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_provisionerless.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_provisionerless.box)

## Older Baseboxes

Older baseboxes include Chef.

The following base boxes were built with Chef 11.4.4.

64-bit boxes:

* [opscode-centos-5.9](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.9_chef-11.4.4.box)
* [opscode-centos-6.4](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4_chef-11.4.4.box)
* [opscode-ubuntu-10.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-11.4.4.box)
* [opscode-ubuntu-12.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.4.4.box)

32-bit boxes:

* [opscode-centos-5.9-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.9-i386_chef-11.4.4.box)
* [opscode-centos-6.4-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4-i386_chef-11.4.4.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_chef-11.4.4.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_chef-11.4.4.box)

The following base boxes were built with Chef 11.4.0.

64-bit boxes:

* [opscode-centos-5.9](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.9_chef-11.4.0.box)
* [opscode-centos-6.4](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4_chef-11.4.0.box)
* [opscode-ubuntu-10.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-11.4.0.box)
* [opscode-ubuntu-12.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.4.0.box)

32-bit boxes:

* [opscode-centos-5.9-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.9-i386_chef-11.4.0.box)
* [opscode-centos-6.4-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4-i386_chef-11.4.0.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_chef-11.4.0.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_chef-11.4.0.box)

The following base boxes were built with Chef 11.2.0. (No 32-bit boxes were built for Chef 11.2.0.)

* [opscode-centos-5.8](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.8_chef-11.2.0.box)
* [opscode-centos-6.3](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.3_chef-11.2.0.box)
* [opscode-ubuntu-10.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-11.2.0.box)
* [opscode-ubuntu-12.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.2.0.box)

The following base boxes were built with Chef 10.18.2.

* [opscode-centos-5.8-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.8-i386_chef-10.18.2.box)
* [opscode-centos-5.8](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.8_chef-10.18.2.box)
* [opscode-centos-6.3-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.3-i386_chef-10.18.2.box)
* [opscode-centos-6.3](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.3_chef-10.18.2.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_chef-10.18.2.box)
* [opscode-ubuntu-10.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-10.18.2.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_chef-10.18.2.box)
* [opscode-ubuntu-12.04](https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-10.18.2.box)

The following base boxes were built with Chef 10.14.4.

* [opscode-centos-5.8-i386](https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-5.8-i386.box)
* [opscode-centos-5.8](https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-5.8.box)
* [opscode-centos-6.3-i386](https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3-i386.box)
* [opscode-centos-6.3](https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3.box)
* [opscode-ubuntu-10.04](https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-10.04.box)
* [opscode-ubuntu-10.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-10.04-i386.box)
* [opscode-ubuntu-12.04](https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box)
* [opscode-ubuntu-12.04-i386](https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04-i386.box)

# Getting Started

First, clone the project, then install the required Gems with Bundler.

    $ git clone git://github.com/opscode/bento.git
    $ cd bento
    $ bundle install

List available baseboxes that can be built:

    $ bundle exec veewee vbox list

Build, for example, the ubuntu-12.04 basebox.

    $ bundle exec veewee vbox build ubuntu-12.04

You can validate the basebox using Veewee's built in validator.
However note that the test for Ruby (and Puppet) will fail. The Ruby
installation is in `/opt/chef/embedded`, and we do not add the bin
directory to the `$PATH`, and we don't use Puppet internally.

    $ bundle exec veewee vbox validate ubuntu-12.04

Aside from that, the basebox should be ready to use. Export it:

    $ bundle exec veewee vbox export ubuntu-12.04

Congratulations! You now have `./ubuntu-12.04.box`, a fully functional
basebox that you can then add to Vagrant and start testing cookbooks.

# How It Works

Veewee reads the definition specified and automatically builds a
VirtualBox machine. The VirtualBox guest additions and the target OS
ISO are downloaded into the `iso/` directory.

We use Veewee version 0.3.0.alpha+ because it contains fixes for
building CentOS boxes under certain circumstances.

# Definitions

The definitions themselves are split up into directories that get
symlinked into specific basebox directories.

Most of the files are symlinked for a particular box. The one
exception is the `definition.rb` file, which contains the specific
configuration for the Veewee session for a basebox, including the ISO
filename, its source URL, and the MD5 checksum of the file.

## Common

* `chef-client.sh`: Installs Chef and Ruby with
  [Opscode's full stack installer](http://opscode.com/chef/install)
* `minimize.sh`: Zeroes out the root disk to reduce file size of the box
* `ruby.sh`: **Deprecated** Use `chef-client.sh`
* `session.rb`: Baseline session settings for Veewee
* `sshd.sh`: Adds some sshd configs to speed up vagrant
* `vagrant.sh`: Installs VirtualBox Guest Additions, adds the Vagrant
  SSH key

## CentOS

* `cleanup.sh`: Removes unneeded packages, cleans up package cache,
  and removes the VBox ISO and Chef rpm
* `ks.cfg`: Kickstart file for automated OS installation
* `session.rb`: General CentOS session settings for Veewee

## Ubuntu

* `cleanup.sh`: Removes unneeded packages, cleans up package cache,
  and removes the VBox ISO and Chef deb
* `networking.sh`: Removes networking setup like udev that may
  interfere with Vagrant network setup
* `preseed.cfg`: The Debian Preseed file for automated OS installation
* `session.rb`: General Ubuntu session settings for Veewee
* `sudoers.sh`: Customization for `/etc/sudoers`
* `update.sh`: Ensures that the OS installation is updated

## Windows

* `install-chef.bat`: Installs Chef and Ruby with
  [Opscode's full stack installer](http://opscode.com/chef/install)
* `oracle-cert.cer`: Needed for automated install via install-vbox.bat
* `install-vbox.bat`: Installs VirtualBox Guest Additions
* `mount-validation.bat`: Mounts the validation drive

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

Copyright:: 2012-2013, Opscode, Inc (<legal@opscode.com>)
Copyright:: 2011-2012, Tim Dysinger (<tim@dysinger.net>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
