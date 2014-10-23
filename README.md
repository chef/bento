# Bento

[![Build Status](http://img.shields.io/travis/opscode/bento.svg)][travis]

[travis]: https://travis-ci.org/opscode/bento

Bento is a project that encapsulates [Packer](http://packer.io) templates for building
[Vagrant](http://vagrantup.com) baseboxes. We use these boxes internally at Chef Software, Inc. for
testing Hosted Enterprise Chef, Private Enterprise Chef and our open source [cookbooks](https://supermarket.getchef.com/users/chef)
via [test-kitchen](http://kitchen.ci/).

This project is managed by the CHEF Release Engineering team. For more information on the Release Engineering team's contribution, triage, and release process, please consult the [CHEF Release Engineering OSS Management Guide](https://docs.google.com/a/opscode.com/document/d/1oJB0vZb_3bl7_ZU2YMDBkMFdL-EWplW1BJv_FXTUOzg/edit).

## Current Baseboxes

The following baseboxes are publicly available and were built using
this project. Note that our baseboxes do not include Chef Client.
Vagrant can be instructed to install Chef at runtime using the
[vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) plugin.

### VirtualBox

These baseboxes were all built using a Mac OS X host running VirtualBox 4.3.14, and have that format of Guest Extensions.

* [opscode-centos-5.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-5.10-i386_chef-provisionerless.box)
* [opscode-centos-5.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-5.10_chef-provisionerless.box)
* [opscode-centos-6.5-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5-i386_chef-provisionerless.box)
* [opscode-centos-6.5](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box)
* [opscode-centos-7.0](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.0_chef-provisionerless.box)
* [opscode-debian-6.0.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-6.0.10-i386_chef-provisionerless.box)
* [opscode-debian-6.0.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-6.0.10_chef-provisionerless.box)
* [opscode-debian-7.6-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.6-i386_chef-provisionerless.box)
* [opscode-debian-7.6](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.6_chef-provisionerless.box)
* [opscode-fedora-19-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-19-i386_chef-provisionerless.box)
* [opscode-fedora-19](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-19_chef-provisionerless.box)
* [opscode-fedora-20-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-20-i386_chef-provisionerless.box)
* [opscode-fedora-20](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-20_chef-provisionerless.box)
* [opscode-freebsd-9.2-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_freebsd-9.2-i386_chef-provisionerless.box)
* [opscode-freebsd-9.2](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_freebsd-9.2_chef-provisionerless.box)
* [opscode-freebsd-10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_freebsd-10.0_chef-provisionerless.box)
* [opscode-opensuse-13.1-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_opensuse-13.1-i386_chef-provisionerless.box)
* [opscode-opensuse-13.1](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_opensuse-13.1-x86_64_chef-provisionerless.box)
* [opscode-ubuntu-10.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-10.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-10.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-10.04_chef-provisionerless.box)
* [opscode-ubuntu-12.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-12.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box)
* [opscode-ubuntu-14.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-14.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box)

### VMWare

These baseboxes were all built using a Mac OS X host running VMWare Fusion 6.0.2, and have that version of VMWare Tools.
The boxes should work unchanged in VMWare Workstation for Windows or Linux.

If you're using the [Vagrant VMWare Fusion](https://www.vagrantup.com/vmware)
provider, using `vagrant box add --provider vmware_desktop ...` will work for
these boxes. Using `--provider vmware_fusion`, will not.

* [opscode-centos-5.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-5.10-i386_chef-provisionerless.box)
* [opscode-centos-5.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-5.10_chef-provisionerless.box)
* [opscode-centos-6.5-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-6.5-i386_chef-provisionerless.box)
* [opscode-centos-6.5](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-6.5_chef-provisionerless.box)
* [opscode-centos-7.0](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_centos-7.0_chef-provisionerless.box)
* [opscode-debian-6.0.10-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-6.0.10-i386_chef-provisionerless.box)
* [opscode-debian-6.0.10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-6.0.10_chef-provisionerless.box)
* [opscode-debian-7.6-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-7.6-i386_chef-provisionerless.box)
* [opscode-debian-7.6](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-7.6_chef-provisionerless.box)
* [opscode-fedora-19-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-19-i386_chef-provisionerless.box)
* [opscode-fedora-19](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-19_chef-provisionerless.box)
* [opscode-fedora-20-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-20-i386_chef-provisionerless.box)
* [opscode-fedora-20](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_fedora-20_chef-provisionerless.box)
* [opscode-freebsd-9.2-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_freebsd-9.2-i386_chef-provisionerless.box)
* [opscode-freebsd-9.2](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_freebsd-9.2_chef-provisionerless.box)
* [opscode-freebsd-10](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_freebsd-10.0_chef-provisionerless.box)
* [opscode-opensuse-13.1-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_opensuse-13.1-i386_chef-provisionerless.box)
* [opscode-opensuse-13.1](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_opensuse-13.1-x86_64_chef-provisionerless.box)
* [opscode-ubuntu-10.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-10.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-10.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-10.04_chef-provisionerless.box)
* [opscode-ubuntu-12.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-12.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-12.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-12.04_chef-provisionerless.box)
* [opscode-ubuntu-14.04-i386](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-14.04-i386_chef-provisionerless.box)
* [opscode-ubuntu-14.04](http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-14.04_chef-provisionerless.box)

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

    $ packer build -only=virtualbox-iso debian-7.2.0-i386.json

Congratulations! You now have box(es) in the ../builds directory that you can then add to Vagrant and start testing cookbooks.

### Proprietary Boxes

Mac OS X (10.7, 10.8, and 10.9), Red Hat Enterprise Linux, and SUSE Linux Enterprise Server templates are provided. However, their ISOs are not publicly retrievable and as such, the URLs in those templates are bogus. For RHEL and SLES, you should substitute your server where you host the ISOs, using the mirror variable as above.

#### Mac OS X Boxes

To build a Mac OS X box, you will need to start with an installer for your desired version of OS X.  You will then need to use [Tim Sutton's osx-vm-templates](https://github.com/timsutton/osx-vm-templates)/) to modify that installer for use by packer.  The output of that build will include the location of the ISO and its checksum, which you can substitute into your `packer build` command, e.g.:

    $ packer build -var 'iso_checksum=<checksum>' -var 'iso_url=<iso_url>' macosx-10.9.json

There is a known issue where [test-kitchen](http://kitchen.ci/) starts a Mac OS X box correctly, but `vagrant up` fails due to the absence of the HGFS kernel module.  This is due to a silent failure during the VMware tools installation and can be corrected by installing the VMware tools on the Mac OS X box manually.

Note that, while it is possible to build OS X boxes for VirtualBox, it may not be ideal. VirtualBox provides no "guest additions" for OS X. Boxes consequently have limited networking configurability and must rely on rsync for folder syncing. VMWare, when available, is generally preferred.

### Windows Boxes

Packer does not yet support Windows, so veewee definitions are still used for building those boxes. You must build these
boxes yourself due to licensing constraints. You can build these as follows:

    $ bundle install
    $ bundle exec veewee vbox build [definition-name]

These veewee definitions are lightly maintained. For other approaches to building Windows boxes, please see the following
community projects:

* [Mischa Taylor's basebox project](https://github.com/misheska/basebox-packer/)
* [Vagrant Windows Boxes and Puppet](https://github.com/ferventcoder/vagrant-windows-puppet/tree/master/baseboxes)

### Special Note About Building from Windows Hosts

When building boxes from a Windows host system, you must ensure that kickstart configuration files (`ks.cfg` for RHEL
based systems) and preseed files (`preseed.cfg` for Debian based systems) have Unix line endings (i.e. lines end with
LF character only). Moreover, it's also a good idea to have `*.sh` scripts with Unix line endings too.

When these files have Windows line endings, the group creation can fail in the pre-seed phase and in turn, prevents the
user `vagrant` to be created correctly. This ultimately results in Packer not being able to connect to the newly booted
up machine with an error message that looks like this:

```
==> virtualbox-iso: Waiting for SSH to become available...
==> virtualbox-iso: Error waiting for SSH: handshake failed: ssh: unable to authenticate, attempted methods [none password], no support
```

Since Packer tries to log in with user `vagrant` but it was not created successfully in the pre-seed phase, it is unable
to connect to the machine and the packaging process stops.

By default, when cloning this repository, git should normalize `ks.cfg`, `preseed.cfg` and `*.sh` to Unix line endings
and `*.bat` to Windows line endings, thanks to the [.gitattributes](.gitattributes) file in the repository. However, if
it's not the case because you have overridden line-ending conversion in your own git configuration, convert the offending files so they have the correct line endings.

## Bugs and Issues

Please use GitHub issues to report bugs, features, or other problems. Please note:
the [JIRA issue tracker](http://tickets.opscode.com/browse/BENTO) is no longer being used.

## License & Authors

These basebox templates were converted from [veewee](https://github.com/jedi4ever/veewee)
definitions originally based on
[work done by Tim Dysinger](https://github.com/dysinger/basebox) to
make "Don't Repeat Yourself" (DRY) modular baseboxes. Thanks Tim!

Mac OS X templates were adopted wholesale from [Fletcher Nichol's packer templates](https://github.com/fnichol/packer-templates).

- Author: Seth Chisamore (<schisamo@getchef.com>)
- Author: Stephen Delano (<stephen@getchef.com>)
- Author: Joshua Timberman (<joshua@getchef.com>)
- Author: Tim Dysinger (<tim@dysinger.net>)
- Author: Chris McClimans (<chris@hippiehacker.org>)
- Author: Julian Dunn (<jdunn@getchef.com>)
- Author: Tom Duffield (<tom@getchef.com>)
- Author: Ross Timson (<ross@rosstimson.com>)
- Author: Fletcher Nichol (<fnichol@nichol.ca>)

```text
Copyright 2012-2014, Chef Software, Inc. (<legal@getchef.com>)
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
