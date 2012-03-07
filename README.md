We currently have the following 'official' Vagrant base boxes available for internal
usage:

* opscode-ubuntu-10.04 - http://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-10.04.box

Projects like [opscode-dev-vm](https://github.com/opscode/opscode-dev-vm) and
[opscode-omnibus](https://github.com/opscode/opscode-omnibus) are already taking
advantage of the above base boxes.  For many people these base boxes will be enough.
That being said, it is important to understand how we construct base boxes.  This
will be useful information if you ever have to create a new base box or rebuild
an existing one.

# Build a New Base Box

Building a new base box is a fairly painless affair.  This project uses
[Veewee](https://github.com/jedi4ever/veewee) to automate construction of a new
base boxes but replaces the crufty templates that ship with Veewee with a more
sane set of DRY, vetted definitions originally put together by Tim Dysinger.

First thing you need to do is checkout [bento](https://github.com/opscode/bento):

    $ git clone git@github.com:opscode/bento.git
    $ cd bento
    $ bundle install --binstubs

Next initialize the 'definitions' submodule:

    $ git submodule init
    $ git submodule update

Now we can easily list the available base box definitions:

    $ bundle exec vagrant basebox list
    The following defined baseboxes exist:
    - centos-5.5
    - centos-5.6
    - centos-5.7
    - centos-6.0
    - centos-6.2
    - LICENSE
    - README.org
    - ubuntu-10.04
    - ubuntu-10.10
    - ubuntu-11.04
    - ubuntu-11.10

Building a base box is one, simple command:

    $ bundle exec vagrant basebox build ubuntu-10.04
    Verifying the isofile ubuntu-10.04.4-server-amd64.iso is ok.
    Setting VM Flag ioapic to on
    Setting VM Flag pae to on
    Creating vm ubuntu-10.04 : 384M - 1 CPU - Ubuntu_64
    Creating new harddrive of size 10140
    VBoxManage createhd --filename '/Users/schisamo/VirtualBox VMs/ubuntu-10.04/ubuntu-10.04.vdi' --size '10140' --format vdi > /dev/null
    Attaching disk: /Users/schisamo/VirtualBox VMs/ubuntu-10.04/ubuntu-10.04.vdi
    Mounting cdrom: /Users/schisamo/dev/code/opscode/opscode-dev-vm/iso/ubuntu-10.04.4-server-amd64.iso
    Waiting for the machine to boot

    Typing:[1]: <Esc>
    Typing:[2]: <Esc>
    Typing:[3]: <Enter>
    Typing:[4]: /install/vmlinuz
    Typing:[5]:  auto
    ...

Go get some coffee and let Veewee work it's magic.  Once your base box is built, validate it...

    $ bundle exec vagrant basebox validate ubuntu-10.04
    Feature: vagrant box validation
      As a valid vagrant box
      I need to comply to a set of rules

      Scenario: Checking login

    ...

    7 scenarios (7 passed)
    21 steps (21 passed)
    0m8.622s

...and export it:


    $ bundle exec vagrant basebox export ubuntu-10.04
    Vagrant requires the box to be shutdown, before it can export
    Sudo also needs to work for user vagrant
    Performing a clean shutdown now.
    Executing command: sudo shutdown -P now

    Broadcast message from vagrant@vagrant
      (/dev/pts/0) at 0:19 ...

    The system is going down for power off NOW!
    ....
    Machine ubuntu-10.04 is powered off cleanly
    Executing vagrant voodoo:
    vagrant package --base 'ubuntu-10.04' --output 'ubuntu-10.04.box'

    To import it into vagrant type:
    vagrant box add 'ubuntu-10.04' 'ubuntu-10.04.box'

    To use it:
    vagrant init 'ubuntu-10.04'
    vagrant up
    vagrant ssh

For any base boxes you expect to share with the company as a whole be sure to
namespace the box with {{opscode-*}}:

    $ mv ubuntu-10.04 opscode-ubuntu-10.04

Now you have a few choices...you can import the base box into your local Vagrant
environment:

    $ bundle exec vagrant box add opscode-ubuntu-10.04 opscode-ubuntu-10.04.box

If it is a box you want to share with the company upload the box to the `opscode-vm`
bucket (vagrant/boxes folder) on our [preprod AWS account](https://wiki.corp.opscode.com/display/CORP/Summary+of+AWS+Accounts#SummaryofAWSAccounts-%22rspreprod%22)

# Individual Base Box Build Notes

## opscode-ubuntu-10.04

This box has an additional hard disk so we can properly emulate Private Chef HA
configurations.  There is no automated way to add this additional SATA drive.
After the initial basebox *build*, *validate* and *export* commands succeeds
open the VirtualBox settings for the {{ubuntu-10.04}} VM and create a second SATA
Hard Disk with the following settings:

*File Type:* VDI (VirtualBox Disk Image)
*Storage Details:* Dynamically allocated
*Location:* ubuntu-10.04-2.vdi
*Size*: 9.90 GB

Once this step is complete re-export the box.
