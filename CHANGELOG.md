# Change Log

## [2.2.9](https://github.com/chef/bento/tree/2.2.9) (2016-08-01)
[Full Changelog](https://github.com/chef/bento/compare/2.2.8...2.2.9)

**Improvements:**

- OpenSUSE Leap 42.1: requires 768 Mb memory. [\#632](https://github.com/chef/bento/pull/632) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Update for 16.04.1 iso [\#629](https://github.com/chef/bento/pull/629)
- For reals fixed 16.04 pkg lock bug [\#637](https://github.com/chef/bento/pull/637) ([cheeseplus](https://github.com/cheeseplus))

**Fixed bugs:**

- VMware: HGFS not working - Ubuntu 16.04 [\#591](https://github.com/chef/bento/issues/591)

**EOL**

 - Fedora 22

 **Tool Versions:**

 - Packer 0.10.1
 - VirtualBox 5.0.26
 - VMware Fusion 8.1.1
 - VMware Workstation 12.1.1
 - Parallels Pro 11.2.1

## [2.2.8](https://github.com/chef/bento/tree/2.2.8) (2016-07-22)
[Full Changelog](https://github.com/chef/bento/compare/2.2.7...2.2.8)

**Improvements:**

- Archiving all non-current builds [\#622](https://github.com/chef/bento/pull/622) ([cheeseplus](https://github.com/cheeseplus))
- Add Fedora 24 and dedupe kickstart scripts [\#623](https://github.com/chef/bento/pull/623) ([tas50](https://github.com/tas50))
- 16.04 should use open-vm-tools [\#621](https://github.com/chef/bento/pull/621) ([cheeseplus](https://github.com/cheeseplus))
- Updated Debian 7 to 7.11 [\#608](https://github.com/chef/bento/pull/608) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Updated Debian 8 to 8.5 [\#607](https://github.com/chef/bento/pull/607) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Updated CentOS and RHEL to 6.8 [\#605](https://github.com/chef/bento/pull/605) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Disable automated package upgrades on Debian-like boxes [\#612](https://github.com/chef/bento/pull/612) ([jrb](https://github.com/jrb))
- Fix new-style device naming from Network Manager on RHEL/CentOS 7 [\#617](https://github.com/chef/bento/pull/617) ([legal90](https://github.com/legal90))
- update apt sources to use archive.debian.org for packages [\#614](https://github.com/chef/bento/pull/614) ([apollocatlin](https://github.com/apollocatlin))

**Fixed bugs:**

- apt.systemd.daily creates conflict in xenial64 box [\#616](https://github.com/chef/bento/issues/616)
- FreeBSD: Root password not set! [\#610](https://github.com/chef/bento/issues/610)
- ubuntu-16.04: unattended updates locking dpkg [\#609](https://github.com/chef/bento/issues/609)
- Fix vagrant.sh failing on Solaris nodes [\#606](https://github.com/chef/bento/pull/606) ([tas50](https://github.com/tas50))

**Tool Versions:**

- Packer 0.10.1
- VirtualBox 5.0.24
- VMware Fusion 8.1.1
- Parallels Pro 11.2.0

## [2.2.7](https://github.com/chef/bento/tree/2.2.7) (2016-05-20)
[Full Changelog](https://github.com/chef/bento/compare/2.2.6...2.2.7)

**Improvements:**

- Ubuntu: HWE BEGONE! pt 1 - Fix for VMware HGFS on 14.04 [\#584](https://github.com/chef/bento/pull/584) ([davidmnoriega](https://github.com/davidmnoriega))
- Ubuntu: HWE BEGONE! pt 2 - The Pangolining [\#587](https://github.com/chef/bento/pull/587) ([cheeseplus](https://github.com/cheeseplus))
- OpenSuSE: Switching to more reliable mirror [\#583](https://github.com/chef/bento/pull/583) ([cheeseplus](https://github.com/cheeseplus))
- Added "disk\_size" user variable [\#596](https://github.com/chef/bento/pull/596) ([svpace](https://github.com/svpace))

**Fixed bugs:**

- Ubuntu 16.04: 70-persistent-net.rules "hack" messes with update-initramfs triggers [\#592](https://github.com/chef/bento/issues/592)
- VMware: use correct script flags based on version [\#590](https://github.com/chef/bento/issues/590)

**Tool Versions:**

- Packer 0.10.1
- VirtualBox 5.0.20
- VMware Fusion 8.1.1
- VMware Workstation 12.1.1
- Parallels Pro 11.2.0

## [2.2.6](https://github.com/chef/bento/tree/2.2.6) (2016-04-28)
[Full Changelog](https://github.com/chef/bento/compare/2.2.5...2.2.6)

**Tool Versions:**

- Packer 0.10.0
- VirtualBox 5.0.16
- VMware Fusion 8.1.1
- Parallels Pro 11.1.3

**Added platforms:**

- Debian 8.4 [\#559](https://github.com/chef/bento/pull/559) ([kenhys](https://github.com/kenhys))
- Debian 7.10 [\#563](https://github.com/chef/bento/pull/563) ([kenhys](https://github.com/kenhys))
- FreeBSD 10.3 [\#557](https://github.com/chef/bento/pull/557) ([tas50](https://github.com/tas50))
- OmniOS 151018 [\#565](https://github.com/chef/bento/pull/565) ([tas50](https://github.com/tas50))
- Ubuntu 16.04 [\#545](https://github.com/chef/bento/pull/545) ([cheeseplus](https://github.com/cheeseplus))

**Fixed bugs:**

- VMWare: tie network device to pci slot 32 [\#566](https://github.com/chef/bento/pull/566) ([rmoriz](https://github.com/rmoriz))
- VMware: Fedora 23 box builds but can't connect [\#521](https://github.com/chef/bento/issues/521)
- Publish Ubuntu 15.10 boxes on Atlas [\#506](https://github.com/chef/bento/issues/506)

**Improvements:**

- Standardize on 512MB minimum memory [\#574](https://github.com/chef/bento/issues/574)
- Added headless option for QEMU builders [\#570](https://github.com/chef/bento/pull/570) ([jmatt](https://github.com/jmatt))

## [2.2.5](https://github.com/chef/bento/tree/2.2.5) (2016-03-29)
[Full Changelog](https://github.com/chef/bento/compare/2.2.4...2.2.5)

**Merged pull requests:**

- Ubuntu: use dist-upgrade and install build packages in preseed [\#551](https://github.com/chef/bento/pull/551) ([cheeseplus](https://github.com/cheeseplus))

## [2.2.4](https://github.com/chef/bento/tree/2.2.4) (2016-03-29)
[Full Changelog](https://github.com/chef/bento/compare/2.2.3...2.2.4)

**Closed issues:**

- CALL FOR MAINTAINERS [\#537](https://github.com/chef/bento/issues/537)
- Proposal: Move bento under test-kitchen org [\#536](https://github.com/chef/bento/issues/536)
- /tmp directory is cleaned upon restart? [\#535](https://github.com/chef/bento/issues/535)
- bento/centos-7.2 missing from atlas [\#524](https://github.com/chef/bento/issues/524)
- sles 12 mirror no more exist [\#520](https://github.com/chef/bento/issues/520)
- Pipeline: Update to VMware Fusion 8.1.0 [\#519](https://github.com/chef/bento/issues/519)
- error when building boxes with packer  [\#514](https://github.com/chef/bento/issues/514)
- Ubuntu 12.04 HGFS module failing in VMWare [\#512](https://github.com/chef/bento/issues/512)
- Uncompressed boxes for VMware and Parallels are to large [\#505](https://github.com/chef/bento/issues/505)
- OpenSUSE Leap \(and Tumbleweed\) [\#504](https://github.com/chef/bento/issues/504)
- Ubuntu 14.04 HGFS kernel module not working for VMWare 8.0.2 [\#496](https://github.com/chef/bento/issues/496)
- Any support \(or planned support\) for building Amazon AMIs? [\#490](https://github.com/chef/bento/issues/490)
- ARM builds [\#486](https://github.com/chef/bento/issues/486)
- Minimize script results in large \(non-sparse\) image file for QEMU builder [\#369](https://github.com/chef/bento/issues/369)

**Merged pull requests:**

- Cutting 2.2.4 [\#550](https://github.com/chef/bento/pull/550) ([cheeseplus](https://github.com/cheeseplus))
- Update mirror URL for Debian 8.2 [\#544](https://github.com/chef/bento/pull/544) ([legal90](https://github.com/legal90))
- Updating maintainers [\#543](https://github.com/chef/bento/pull/543) ([cheeseplus](https://github.com/cheeseplus))
- Updating for 14.04.4 release [\#542](https://github.com/chef/bento/pull/542) ([cheeseplus](https://github.com/cheeseplus))
- Update the packer download URL and use 0.9.0 [\#540](https://github.com/chef/bento/pull/540) ([tas50](https://github.com/tas50))
- Minor readme updates [\#539](https://github.com/chef/bento/pull/539) ([tas50](https://github.com/tas50))
- Fix guest\_os\_type for VirtualBox [\#534](https://github.com/chef/bento/pull/534) ([juliandunn](https://github.com/juliandunn))
- Sudo path changed [\#530](https://github.com/chef/bento/pull/530) ([scotthain](https://github.com/scotthain))
- update solaris 11 box to 11.3 [\#528](https://github.com/chef/bento/pull/528) ([chris-rock](https://github.com/chris-rock))
- update sha1 for omnios [\#527](https://github.com/chef/bento/pull/527) ([chris-rock](https://github.com/chris-rock))
- Add support for Debian GNU/Linux 8.3 [\#526](https://github.com/chef/bento/pull/526) ([kenhys](https://github.com/kenhys))
- simplify distro detection for RHEL-derivatives [\#525](https://github.com/chef/bento/pull/525) ([ceetav](https://github.com/ceetav))
- Add support for OpenSUSE Leap 42.1 - x86\_64 [\#523](https://github.com/chef/bento/pull/523) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Fix links to Fedora 23 boxes. [\#518](https://github.com/chef/bento/pull/518) ([juliandunn](https://github.com/juliandunn))
- Cutting 2.2.3 [\#515](https://github.com/chef/bento/pull/515) ([cheeseplus](https://github.com/cheeseplus))

## [2.2.3](https://github.com/chef/bento/tree/2.2.3) (2015-12-28)
[Full Changelog](https://github.com/chef/bento/compare/2.2.2...2.2.3)

**Fixed bugs:**

- minimize.sh fails with no swap partition [\#420](https://github.com/chef/bento/issues/420)
- Workstation 11.1.2 Tools incompatible with current builds [\#377](https://github.com/chef/bento/issues/377)

**Closed issues:**

- Debian cleanup script removes C/C++ compiler and therefore breaks DKMS support [\#509](https://github.com/chef/bento/issues/509)
- RHEL 6.7 image has wrong guest [\#501](https://github.com/chef/bento/issues/501)
- Fedora 23 x86\_64 and virtualbox: no vboxsf [\#500](https://github.com/chef/bento/issues/500)
- Broken url on description [\#493](https://github.com/chef/bento/issues/493)
- Porposal Fedora 23 [\#491](https://github.com/chef/bento/issues/491)
- Ubuntu 15.10 [\#482](https://github.com/chef/bento/issues/482)
- /dev/sr0 is readonly [\#480](https://github.com/chef/bento/issues/480)
- Ubuntu 14.04 Fails to build with bento/packer [\#477](https://github.com/chef/bento/issues/477)
- The download link to fedora 21 vmware 64 is broken [\#472](https://github.com/chef/bento/issues/472)
- Debian 8.2 vagrant box doesn't have HGFS kernel module [\#463](https://github.com/chef/bento/issues/463)
- Unable to have synced\_folder with Fedora 22 VirtualBox [\#459](https://github.com/chef/bento/issues/459)
- Fedora 22 VM Tools not installed [\#458](https://github.com/chef/bento/issues/458)
- Update Virtualbox Guest Addition from 5.0.2 to 5.0.4 [\#448](https://github.com/chef/bento/issues/448)
- Standardize iso\_checksum / iso\_checksum\_type on sha256 [\#440](https://github.com/chef/bento/issues/440)
- rhel/centos 6 and 7, virtualbox guest additions [\#412](https://github.com/chef/bento/issues/412)
- opscode-centos-7.1 Virtualbox box not able to NFS mount [\#388](https://github.com/chef/bento/issues/388)
- Vagrant public key file could be empty [\#258](https://github.com/chef/bento/issues/258)

**Merged pull requests:**

- Revert "fix or suppress all shellcheck warnings" [\#513](https://github.com/chef/bento/pull/513) ([cheeseplus](https://github.com/cheeseplus))
- Stops DKMS package from being removed. [\#510](https://github.com/chef/bento/pull/510) ([RobertDeRose](https://github.com/RobertDeRose))
- Enterprise Linux 7.2 \(RHEL/CentOS/OEL\) [\#508](https://github.com/chef/bento/pull/508) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Fix error in cleanup.sh script introduced in d01cb1d7 [\#507](https://github.com/chef/bento/pull/507) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Fix RHEL 6.7 guest type [\#503](https://github.com/chef/bento/pull/503) ([juliandunn](https://github.com/juliandunn))
- Fix dhcp settings cleanup in Ubuntu 12.04 and higher [\#498](https://github.com/chef/bento/pull/498) ([legal90](https://github.com/legal90))
- Disable automatic udev rules for network interfaces in CentOS [\#497](https://github.com/chef/bento/pull/497) ([legal90](https://github.com/legal90))
- Fix grep character class syntax in sshd.sh script [\#495](https://github.com/chef/bento/pull/495) ([legal90](https://github.com/legal90))
- fix or suppress all shellcheck warnings [\#494](https://github.com/chef/bento/pull/494) ([jhoblitt](https://github.com/jhoblitt))
- Support Fedora 23 [\#489](https://github.com/chef/bento/pull/489) ([rickard-von-essen](https://github.com/rickard-von-essen))
- attempt to manage sshd\_config in an \[more\] idempotent manner [\#487](https://github.com/chef/bento/pull/487) ([jhoblitt](https://github.com/jhoblitt))
- Add template for OS X 10.11 El Capitan [\#484](https://github.com/chef/bento/pull/484) ([legal90](https://github.com/legal90))
- Ubuntu 15.10 support [\#483](https://github.com/chef/bento/pull/483) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Support swapless builders in minimize.sh [\#479](https://github.com/chef/bento/pull/479) ([sheldonh](https://github.com/sheldonh))
- Be more aggressive about removing "bento-\*" vagrant boxes [\#476](https://github.com/chef/bento/pull/476) ([cheeseplus](https://github.com/cheeseplus))
- \[DRY\] up rhel [\#475](https://github.com/chef/bento/pull/475) ([cheeseplus](https://github.com/cheeseplus))
- \[DRY\] SLES [\#474](https://github.com/chef/bento/pull/474) ([cheeseplus](https://github.com/cheeseplus))
- \[DRY\] Oracle Linux [\#473](https://github.com/chef/bento/pull/473) ([cheeseplus](https://github.com/cheeseplus))
- Minimized AutoYaST profiles for SLES 11.3/12 to enhance readability [\#373](https://github.com/chef/bento/pull/373) ([mattiasgiese](https://github.com/mattiasgiese))

## [2.2.2](https://github.com/chef/bento/tree/2.2.2) (2015-10-07)
[Full Changelog](https://github.com/chef/bento/compare/2.2.1...2.2.2)

**Closed issues:**

- bento/centos-6.7 won't vagrant up after halt or reload [\#468](https://github.com/chef/bento/issues/468)
- Build process broken under VMware Workstation 11.1.2 [\#467](https://github.com/chef/bento/issues/467)
- minimize.sh leads to unexpected error in packer \(vagrant 1.7.2\) [\#320](https://github.com/chef/bento/issues/320)
- Ubuntu 14.04 VMware HGFS modules not loaded [\#283](https://github.com/chef/bento/issues/283)

**Merged pull requests:**

- Cutting 2.2.2 release [\#471](https://github.com/chef/bento/pull/471) ([cheeseplus](https://github.com/cheeseplus))
- The sha changed :/ [\#470](https://github.com/chef/bento/pull/470) ([cheeseplus](https://github.com/cheeseplus))
- Adding shared folder as part of test-kitchen run [\#469](https://github.com/chef/bento/pull/469) ([cheeseplus](https://github.com/cheeseplus))
- Adding OmniOS r151014 [\#466](https://github.com/chef/bento/pull/466) ([cheeseplus](https://github.com/cheeseplus))
- Fixing Fedora 22 build tools to fix vm tools [\#465](https://github.com/chef/bento/pull/465) ([cheeseplus](https://github.com/cheeseplus))
- Adds host only network for nano and enables file and printer sharing [\#464](https://github.com/chef/bento/pull/464) ([mwrock](https://github.com/mwrock))
- Windows Nano [\#462](https://github.com/chef/bento/pull/462) ([mwrock](https://github.com/mwrock))
- squashed commit to add qemu options for all boxes [\#461](https://github.com/chef/bento/pull/461) ([dmlb2000](https://github.com/dmlb2000))
- bento command needs two dashes [\#457](https://github.com/chef/bento/pull/457) ([mmckinst](https://github.com/mmckinst))
- remove duplicate auth/authconfig and use sha512 algorithm for password hashing [\#456](https://github.com/chef/bento/pull/456) ([mmckinst](https://github.com/mmckinst))
- Making upload/release optional [\#455](https://github.com/chef/bento/pull/455) ([cheeseplus](https://github.com/cheeseplus))
- use --force-install for VMware tools [\#454](https://github.com/chef/bento/pull/454) ([cheeseplus](https://github.com/cheeseplus))
- Fixing templates [\#453](https://github.com/chef/bento/pull/453) ([cheeseplus](https://github.com/cheeseplus))
- Remove the headless option for Parallels builder. [\#452](https://github.com/chef/bento/pull/452) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Adding verification \(tk\) stage to build process [\#451](https://github.com/chef/bento/pull/451) ([cheeseplus](https://github.com/cheeseplus))

## [2.2.1](https://github.com/chef/bento/tree/2.2.1) (2015-09-16)
[Full Changelog](https://github.com/chef/bento/compare/2.2.0...2.2.1)

**Closed issues:**

- Debian 7.9 [\#444](https://github.com/chef/bento/issues/444)
- Building boxes results in files with unhelpful names [\#433](https://github.com/chef/bento/issues/433)
- fedora-22 Bento Box Corruption? [\#432](https://github.com/chef/bento/issues/432)
- Manually building baseboxes [\#430](https://github.com/chef/bento/issues/430)
- Missing 13 Boxes [\#427](https://github.com/chef/bento/issues/427)
- "yum update" for RHEL/CentOS boxes [\#425](https://github.com/chef/bento/issues/425)
- We need fedora-22 for DNF testing [\#419](https://github.com/chef/bento/issues/419)
- Ubuntu 12.04 downloadable box up-to-date? [\#417](https://github.com/chef/bento/issues/417)
- Using bento boxes with Vagrant [\#410](https://github.com/chef/bento/issues/410)
- chef.github.io/bento is outdated [\#409](https://github.com/chef/bento/issues/409)
- vagrant box `chef/freebsd-10.0`: Unable to install packages [\#407](https://github.com/chef/bento/issues/407)
- debian-7.8 box broken by VMWare Fusion 7.1.1 to 7.1.2 update [\#397](https://github.com/chef/bento/issues/397)
- Parallels boxes? [\#371](https://github.com/chef/bento/issues/371)
- Building a Windows image [\#343](https://github.com/chef/bento/issues/343)
- chef/fedora-21 [\#333](https://github.com/chef/bento/issues/333)
- Ubuntu sudoers file only allows to run as root [\#302](https://github.com/chef/bento/issues/302)
- Puppet support in bento? [\#251](https://github.com/chef/bento/issues/251)
- rename box prefixes to bento- instead of opscode- [\#208](https://github.com/chef/bento/issues/208)

**Merged pull requests:**

- DRY up opensuse [\#450](https://github.com/chef/bento/pull/450) ([cheeseplus](https://github.com/cheeseplus))
- \[fedora-\*\] DRYness pass [\#449](https://github.com/chef/bento/pull/449) ([cheeseplus](https://github.com/cheeseplus))
- Updating platforms to use sha256 [\#447](https://github.com/chef/bento/pull/447) ([cheeseplus](https://github.com/cheeseplus))
- Add Debian 7.9 template [\#446](https://github.com/chef/bento/pull/446) ([cheeseplus](https://github.com/cheeseplus))
- Use bento prefix for box names in README [\#445](https://github.com/chef/bento/pull/445) ([leejones](https://github.com/leejones))
- Setting basename to a more sensible default [\#442](https://github.com/chef/bento/pull/442) ([cheeseplus](https://github.com/cheeseplus))
- Debian 8.2 [\#439](https://github.com/chef/bento/pull/439) ([cheeseplus](https://github.com/cheeseplus))
- Add "vm\_name" parameter to Mac OS X templates for Parallels builder [\#438](https://github.com/chef/bento/pull/438) ([legal90](https://github.com/legal90))
- Revert "Rename centos images for clarity" [\#437](https://github.com/chef/bento/pull/437) ([cheeseplus](https://github.com/cheeseplus))
- Add Parallels builder to Mac OS X templates [\#436](https://github.com/chef/bento/pull/436) ([legal90](https://github.com/legal90))
- Updating readme to reflect reality [\#434](https://github.com/chef/bento/pull/434) ([cheeseplus](https://github.com/cheeseplus))
- Add Fedora 22 box links [\#431](https://github.com/chef/bento/pull/431) ([cheeseplus](https://github.com/cheeseplus))
- Adding s3 upload to Rakefile and add buildkite shell script [\#429](https://github.com/chef/bento/pull/429) ([cheeseplus](https://github.com/cheeseplus))
- Adding Fedora 21 back to matrix [\#428](https://github.com/chef/bento/pull/428) ([cheeseplus](https://github.com/cheeseplus))
- Add Fedora 22 boxes [\#418](https://github.com/chef/bento/pull/418) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Enable key insertion on OS X [\#415](https://github.com/chef/bento/pull/415) ([tas50](https://github.com/tas50))
- Rename centos images for clarity [\#406](https://github.com/chef/bento/pull/406) ([patcon](https://github.com/patcon))
- CentOS kickstarts: Change sed to not rewrite sudo comments [\#326](https://github.com/chef/bento/pull/326) ([mvermaes](https://github.com/mvermaes))

## [2.2.0](https://github.com/chef/bento/tree/2.2.0) (2015-08-26)
[Full Changelog](https://github.com/chef/bento/compare/2.1.0...2.2.0)

**Merged pull requests:**

- Update Readme and small fixes/cleanup to Rake tasks [\#426](https://github.com/chef/bento/pull/426) ([cheeseplus](https://github.com/cheeseplus))
- Freebsd 10.2 [\#424](https://github.com/chef/bento/pull/424) ([geoffgarside](https://github.com/geoffgarside))
- CentOS 6.6 -\> 6.7 [\#423](https://github.com/chef/bento/pull/423) ([cheeseplus](https://github.com/cheeseplus))
- Update to Ubuntu 14.04.3. [\#421](https://github.com/chef/bento/pull/421) ([William-Yeh](https://github.com/William-Yeh))
- Opscode -\> Chefs and other minor stuff [\#414](https://github.com/chef/bento/pull/414) ([tas50](https://github.com/tas50))
- \[macosx-\*\] Increase disk\_size to ~40G from ~20G. [\#413](https://github.com/chef/bento/pull/413) ([fnichol](https://github.com/fnichol))

## [2.1.0](https://github.com/chef/bento/tree/2.1.0) (2015-08-07)
[Full Changelog](https://github.com/chef/bento/compare/2.0.0...2.1.0)

**Fixed bugs:**

- Shortening vm\_name to avoid Parallels box corruption [\#400](https://github.com/chef/bento/pull/400) ([cheeseplus](https://github.com/cheeseplus))

**Closed issues:**

- Debian 8.1 [\#379](https://github.com/chef/bento/issues/379)
- Chef on Centos boxes seems not be installed [\#352](https://github.com/chef/bento/issues/352)

**Merged pull requests:**

- \[debian-\*\] Improve DRYness, correctness, & speed of Debian templates. [\#404](https://github.com/chef/bento/pull/404) ([fnichol](https://github.com/fnichol))
- \[freebsd-\*\] Improve DRYness, correctness, & speed of FreeBSD templates. [\#403](https://github.com/chef/bento/pull/403) ([fnichol](https://github.com/fnichol))
- Fixing headless check [\#401](https://github.com/chef/bento/pull/401) ([cheeseplus](https://github.com/cheeseplus))
- Adding support for headless mode [\#399](https://github.com/chef/bento/pull/399) ([cheeseplus](https://github.com/cheeseplus))
- Box build pipeline [\#398](https://github.com/chef/bento/pull/398) ([cheeseplus](https://github.com/cheeseplus))
- \[centos-\*\] Improve DRYness, correctness, and speed of CentOS templates. [\#396](https://github.com/chef/bento/pull/396) ([fnichol](https://github.com/fnichol))
- \[macosx-\*, ubuntu-\*\] Remove name prefixes from templates. [\#395](https://github.com/chef/bento/pull/395) ([fnichol](https://github.com/fnichol))
- \[ubuntu-\*\] Improve DRYness, correctness, and speed of Ubuntu templates. [\#394](https://github.com/chef/bento/pull/394) ([fnichol](https://github.com/fnichol))
- Adding Debian 8.1 links, removing Debian 8.0 templates [\#393](https://github.com/chef/bento/pull/393) ([cheeseplus](https://github.com/cheeseplus))
- Add @cheeseplus to MAINTAINERS.md [\#392](https://github.com/chef/bento/pull/392) ([fnichol](https://github.com/fnichol))

## [2.0.0](https://github.com/chef/bento/tree/2.0.0) (2015-07-03)
**Fixed bugs:**

- Do not write metadata files when `bento build` is in dry run mode [\#368](https://github.com/chef/bento/issues/368)
- fix OmniOS build under VMWare [\#178](https://github.com/chef/bento/issues/178)
- Don't write metadata file in `bento build` dry run mode. [\#380](https://github.com/chef/bento/pull/380) ([fnichol](https://github.com/fnichol))

**Closed issues:**

- Release Debian 8.0 boxes [\#381](https://github.com/chef/bento/issues/381)
- Upload Ubuntu 15.04 to S3 Bucket [\#376](https://github.com/chef/bento/issues/376)
- Add build metadata to boxes and build artifacts [\#364](https://github.com/chef/bento/issues/364)
- Add support for Debian 8 [\#355](https://github.com/chef/bento/issues/355)
- centos-7.1 vmware box got uploaded as virtualbox [\#351](https://github.com/chef/bento/issues/351)
- chef/centos-7.1 on atlas [\#346](https://github.com/chef/bento/issues/346)
- Add support for Ubuntu 15.04 [\#345](https://github.com/chef/bento/issues/345)
- Why are definitions removed \(RHEL 7.0 was just removed\) [\#344](https://github.com/chef/bento/issues/344)
- Please fix CentOS 7 README links [\#340](https://github.com/chef/bento/issues/340)
- Latest Ubuntu 14.04 Fails to install kernel headers [\#335](https://github.com/chef/bento/issues/335)
- centos 7.1 image request [\#334](https://github.com/chef/bento/issues/334)
- Guest Additions are installed without dkms support [\#332](https://github.com/chef/bento/issues/332)
- need to get the correct cacert.pem for AWS on CentOS boxes [\#325](https://github.com/chef/bento/issues/325)
- Use the SATA HDD controller for faster disk IO speeds [\#324](https://github.com/chef/bento/issues/324)
- Better package miror for Debian [\#322](https://github.com/chef/bento/issues/322)
- Error building debian7.8-amd-64 [\#319](https://github.com/chef/bento/issues/319)
- Fedora kickstart script downloads CA cert bundle over HTTP [\#318](https://github.com/chef/bento/issues/318)
- CentOS and Fedora boxes packed without docs? [\#317](https://github.com/chef/bento/issues/317)
- Create Fedora 21 box [\#312](https://github.com/chef/bento/issues/312)
- \[SLES\] zypper-locks.sh not working [\#309](https://github.com/chef/bento/issues/309)
- Upload Boxes for Parallels to Atlas [\#308](https://github.com/chef/bento/issues/308)
- Single disk configuration for VMware [\#307](https://github.com/chef/bento/issues/307)
- Build new boxes for VMware Fusion 7 [\#304](https://github.com/chef/bento/issues/304)
- FreeBSD 9.3 \(amd64\) box broken [\#301](https://github.com/chef/bento/issues/301)
- OpenSUSE 13.2 should specify netdevice=eth0 [\#299](https://github.com/chef/bento/issues/299)
- vagrant-vbguest plugin compatibility [\#297](https://github.com/chef/bento/issues/297)
- Ubuntu 14.04.1 [\#290](https://github.com/chef/bento/issues/290)
- Everything looks fine, but not able to mount the device?  [\#279](https://github.com/chef/bento/issues/279)
- opscode.github.io/bento is out-of-date \(centos-6.4\) [\#277](https://github.com/chef/bento/issues/277)
- sudo with SSH agent forwarding  [\#273](https://github.com/chef/bento/issues/273)
- Upload rhel-6.5 box to bento AWS repo [\#271](https://github.com/chef/bento/issues/271)
- Importing opscode-centos-6.4  fails with virtualbox error [\#264](https://github.com/chef/bento/issues/264)
- Chef should get permission to distribute proprietary boxes for testing use [\#261](https://github.com/chef/bento/issues/261)
- Should the CentOS 7.0 box be listed in the README? [\#260](https://github.com/chef/bento/issues/260)
- Chef binary not installed on FreeBSD 9.2 and 10.0 [\#250](https://github.com/chef/bento/issues/250)
- chef\debian-7.4 not able to run sudo apt-get update with error in description. [\#242](https://github.com/chef/bento/issues/242)
- Box chef/ubuntu-12.10 / 13.04 fails to install any packages  [\#240](https://github.com/chef/bento/issues/240)
- chef/ubuntu-13.10 no chef\_solo? [\#238](https://github.com/chef/bento/issues/238)
- virtualbox - opscode\_ubuntu-1204\_chef-provisionerless.box 404 [\#236](https://github.com/chef/bento/issues/236)
- VirtualBox: Mounting shared folder with vboxsf failed [\#234](https://github.com/chef/bento/issues/234)
- Ubuntu 14.04: No guest IP was given to the Vagrant core NFS helper [\#232](https://github.com/chef/bento/issues/232)
- VMware boxes claim to be built on VMware Fusion, but report VMware Desktop [\#231](https://github.com/chef/bento/issues/231)
- add more swap [\#228](https://github.com/chef/bento/issues/228)
- error processing drive [\#227](https://github.com/chef/bento/issues/227)
- centos-5.10 add net-tools [\#226](https://github.com/chef/bento/issues/226)
- merge bento and packer-windows [\#225](https://github.com/chef/bento/issues/225)
- Deploy all those boxes to vagrant cloud [\#224](https://github.com/chef/bento/issues/224)
- Example of establishing SSH keys [\#223](https://github.com/chef/bento/issues/223)
- \[Enhancement\] Packer template for Windows [\#222](https://github.com/chef/bento/issues/222)
- Missing credentials for root [\#217](https://github.com/chef/bento/issues/217)
- Virtualbox and debian-7.4: cannot download preseed.cfg [\#215](https://github.com/chef/bento/issues/215)
- Bug with minimize.sh \(Ubuntu 14.04 amd64\) [\#214](https://github.com/chef/bento/issues/214)
- Ubuntu 14.04 box vboxvfs broken? [\#207](https://github.com/chef/bento/issues/207)
- Can we disable SELinux in the CentOS box images? [\#200](https://github.com/chef/bento/issues/200)
- Debian 7.4 64bit [\#198](https://github.com/chef/bento/issues/198)
- Links for FreeBSD 10 boxes give NoSuchKey error \(HTTP 404\) [\#197](https://github.com/chef/bento/issues/197)
- Unable to provision a fedora-19 machine with private-network [\#196](https://github.com/chef/bento/issues/196)
- Vagrant 1.5.1 errors with opscode\_ubuntu-12.04\_chef-provisionerless.box [\#193](https://github.com/chef/bento/issues/193)
- Fixed size /tmp in Fedora 19 box [\#188](https://github.com/chef/bento/issues/188)
- Configure Oracle Linux boxes with an update source [\#186](https://github.com/chef/bento/issues/186)
- slim down CentOS/RHEL box builds with updated ks.cfg [\#179](https://github.com/chef/bento/issues/179)
- add Oracle Linux templates [\#177](https://github.com/chef/bento/issues/177)
- red hat linux 5.10 box cannot download packages [\#173](https://github.com/chef/bento/issues/173)
- 'Error downloading kickstart file' within Oracle VM VirtualBox [\#172](https://github.com/chef/bento/issues/172)
- move single-request-reopen from ks.cfg [\#171](https://github.com/chef/bento/issues/171)

**Merged pull requests:**

- \[macosx-\*\] Add support for {http,https,no}\_proxy environment variables. [\#391](https://github.com/chef/bento/pull/391) ([fnichol](https://github.com/fnichol))
- Remove files that are no longer referenced by any templates. [\#390](https://github.com/chef/bento/pull/390) ([fnichol](https://github.com/fnichol))
- \[macosx-\*\] Improve DRYness & correctness of Mac templates. [\#389](https://github.com/chef/bento/pull/389) ([fnichol](https://github.com/fnichol))
- Add provider metadata to metdata files on build. [\#387](https://github.com/chef/bento/pull/387) ([fnichol](https://github.com/fnichol))
- updated debian's download redirector address [\#386](https://github.com/chef/bento/pull/386) ([rmoriz](https://github.com/rmoriz))
- preliminary debian 8.1 templates [\#385](https://github.com/chef/bento/pull/385) ([rmoriz](https://github.com/rmoriz))
- Add Mac OS X 10.10 template. [\#384](https://github.com/chef/bento/pull/384) ([fnichol](https://github.com/fnichol))
- Update README with Debian 8.0 boxes. [\#383](https://github.com/chef/bento/pull/383) ([fnichol](https://github.com/fnichol))
- Add Debian 8.0 amd64/i386 templates. [\#382](https://github.com/chef/bento/pull/382) ([fnichol](https://github.com/fnichol))
- Update README with Ubuntu 15.04 boxes. [\#378](https://github.com/chef/bento/pull/378) ([fnichol](https://github.com/fnichol))
- Add Ubuntu 15.04 amd64/i386 templates. [\#375](https://github.com/chef/bento/pull/375) ([fnichol](https://github.com/fnichol))
- Add build metadata to boxes and build artifacts. [\#365](https://github.com/chef/bento/pull/365) ([fnichol](https://github.com/fnichol))
- Remove `chef\_version` user variable & remove Chef installation option. [\#362](https://github.com/chef/bento/pull/362) ([fnichol](https://github.com/fnichol))
- Normalize Bento templates [\#361](https://github.com/chef/bento/pull/361) ([fnichol](https://github.com/fnichol))
- TravisCI project updates [\#360](https://github.com/chef/bento/pull/360) ([fnichol](https://github.com/fnichol))
- \[ubuntu-12.04-\*\] Update URL paths to use 12.04.5. [\#359](https://github.com/chef/bento/pull/359) ([fnichol](https://github.com/fnichol))
- Remove VeeWee definitions from project [\#358](https://github.com/chef/bento/pull/358) ([fnichol](https://github.com/fnichol))
- Add packer/bin/bento for building templates. [\#357](https://github.com/chef/bento/pull/357) ([fnichol](https://github.com/fnichol))
- update README to point to Boxcutter intead of basebox [\#354](https://github.com/chef/bento/pull/354) ([OBrienCommaJosh](https://github.com/OBrienCommaJosh))
- Add MAINTAINERS.md file. [\#347](https://github.com/chef/bento/pull/347) ([fnichol](https://github.com/fnichol))
- Add RHEL 7.1 JSON file. [\#342](https://github.com/chef/bento/pull/342) ([lopaka](https://github.com/lopaka))
- Solaris 10u11 - zfs base box [\#341](https://github.com/chef/bento/pull/341) ([scotthain](https://github.com/scotthain))
- Updated README with CentOS 7.1 boxes [\#339](https://github.com/chef/bento/pull/339) ([juliandunn](https://github.com/juliandunn))
- Fix "sudoers.sh" for Ubuntu [\#338](https://github.com/chef/bento/pull/338) ([legal90](https://github.com/legal90))
- Switch to SATA HDD for Linux VMs on virtualbox [\#331](https://github.com/chef/bento/pull/331) ([irvingpop](https://github.com/irvingpop))
- Update to Ubuntu 14.04.2. [\#330](https://github.com/chef/bento/pull/330) ([juliandunn](https://github.com/juliandunn))
- Remove extraneous ks.cfg [\#329](https://github.com/chef/bento/pull/329) ([juliandunn](https://github.com/juliandunn))
- Fixes \#325, \#318 - don't download cacert.pem [\#328](https://github.com/chef/bento/pull/328) ([jtimberman](https://github.com/jtimberman))
- change mirror to http.debian.net, fixes \#322 [\#323](https://github.com/chef/bento/pull/323) ([rmoriz](https://github.com/rmoriz))
- Fix mac address issue for ens33 on centos 7 [\#321](https://github.com/chef/bento/pull/321) ([alappe](https://github.com/alappe))
- Update to Ubuntu 14.04.1 [\#315](https://github.com/chef/bento/pull/315) ([juliandunn](https://github.com/juliandunn))
- Update travis.yml for opscode to chef org rename [\#314](https://github.com/chef/bento/pull/314) ([cmluciano](https://github.com/cmluciano))
- Added Fedora 21 VB base boxes to README [\#313](https://github.com/chef/bento/pull/313) ([dfarrell07](https://github.com/dfarrell07))
- Remove EOL Fedora 19 content [\#311](https://github.com/chef/bento/pull/311) ([juliandunn](https://github.com/juliandunn))
- Make script zypper-locks.sh workable [\#310](https://github.com/chef/bento/pull/310) ([berendt](https://github.com/berendt))
- centos-6.6: Force to set SELinux to a permissive mode [\#306](https://github.com/chef/bento/pull/306) ([legal90](https://github.com/legal90))
- added Fedora 21 support [\#305](https://github.com/chef/bento/pull/305) ([juliandunn](https://github.com/juliandunn))
- Removed some more unnecessary firmware packages [\#303](https://github.com/chef/bento/pull/303) ([yves-vogl](https://github.com/yves-vogl))
- \#299 OpenSUSE 13.2 should specify netdevice=eth0 [\#300](https://github.com/chef/bento/pull/300) ([rickard-von-essen](https://github.com/rickard-von-essen))
- FreeBSD/i386: Fixed incorrect output filename. [\#293](https://github.com/chef/bento/pull/293) ([juliandunn](https://github.com/juliandunn))
- Minimal support for a compilation environment. [\#291](https://github.com/chef/bento/pull/291) ([yzl](https://github.com/yzl))
- Update all box links to latest [\#288](https://github.com/chef/bento/pull/288) ([nshemonsky](https://github.com/nshemonsky))
- Remove curl from CentOS boxes from here on in. [\#287](https://github.com/chef/bento/pull/287) ([juliandunn](https://github.com/juliandunn))
- adds ubuntu 14.10 configuration [\#286](https://github.com/chef/bento/pull/286) ([vincentaubert](https://github.com/vincentaubert))
- update debian packer json to 7.7  [\#285](https://github.com/chef/bento/pull/285) ([vincentaubert](https://github.com/vincentaubert))
- add note in readme about vmware fusion provider [\#284](https://github.com/chef/bento/pull/284) ([smith](https://github.com/smith))
- Reduce Linux box size by not packing a swap partition gubbish [\#281](https://github.com/chef/bento/pull/281) ([ceetav](https://github.com/ceetav))
- Parallels: Support of FreeBSD and OmniOS. Some fixes  [\#278](https://github.com/chef/bento/pull/278) ([legal90](https://github.com/legal90))
- Updated RHEL to 5.11. [\#276](https://github.com/chef/bento/pull/276) ([juliandunn](https://github.com/juliandunn))
- Updated Oracle Enterprise Linux definitions to 5.11 [\#275](https://github.com/chef/bento/pull/275) ([juliandunn](https://github.com/juliandunn))
- Upgrade CentOS 5 to 5.11 [\#274](https://github.com/chef/bento/pull/274) ([eshamow](https://github.com/eshamow))
- Fix syntax and typo share\_folder -\> synced\_folder of console message. [\#272](https://github.com/chef/bento/pull/272) ([jevonearth](https://github.com/jevonearth))
- Fix packer validation failures. [\#269](https://github.com/chef/bento/pull/269) ([juliandunn](https://github.com/juliandunn))
- Fix erroneous virtualbox output directory for vmware-iso build [\#267](https://github.com/chef/bento/pull/267) ([eshamow](https://github.com/eshamow))
- Remove EOL Ubuntu 12.10 [\#266](https://github.com/chef/bento/pull/266) ([eshamow](https://github.com/eshamow))
- Update 12.04 logic to handle outdated apt cache on distro [\#265](https://github.com/chef/bento/pull/265) ([eshamow](https://github.com/eshamow))
- Document CentOS 7.0 box. [\#262](https://github.com/chef/bento/pull/262) ([juliandunn](https://github.com/juliandunn))
- update to FreeBSD 9.3 [\#259](https://github.com/chef/bento/pull/259) ([juliandunn](https://github.com/juliandunn))
- Update README to reflect current Debian boxes and remove old Ubuntu [\#254](https://github.com/chef/bento/pull/254) ([juliandunn](https://github.com/juliandunn))
- Updated to Ubuntu 12.04.5 LTS. [\#253](https://github.com/chef/bento/pull/253) ([juliandunn](https://github.com/juliandunn))
- Update Debian 6.0.9 to 6.0.10 [\#252](https://github.com/chef/bento/pull/252) ([juliandunn](https://github.com/juliandunn))
- Update documentation [\#246](https://github.com/chef/bento/pull/246) ([juliandunn](https://github.com/juliandunn))
- Remove Ubuntu 13.10 as it is EOL as of July 17, 2014. [\#245](https://github.com/chef/bento/pull/245) ([juliandunn](https://github.com/juliandunn))
- Upgrade to OmniOS r151010j [\#244](https://github.com/chef/bento/pull/244) ([juliandunn](https://github.com/juliandunn))
- Fix bugs on building VMWare box [\#243](https://github.com/chef/bento/pull/243) ([juliandunn](https://github.com/juliandunn))
- Support OpenSUSE 13.1 [\#241](https://github.com/chef/bento/pull/241) ([simonoff](https://github.com/simonoff))
- Switch to newest Debian release \(7.5 -\> 7.6\) [\#239](https://github.com/chef/bento/pull/239) ([fadenb](https://github.com/fadenb))
- Support CentOS 7.0 [\#237](https://github.com/chef/bento/pull/237) ([andytson](https://github.com/andytson))
- Updated checksum and mirror to GA release [\#233](https://github.com/chef/bento/pull/233) ([juliandunn](https://github.com/juliandunn))
- fix vmware-vmx tools install [\#230](https://github.com/chef/bento/pull/230) ([rjocoleman](https://github.com/rjocoleman))
- Corrected some copy paste errors in SLES configuration. [\#221](https://github.com/chef/bento/pull/221) ([rickard-von-essen](https://github.com/rickard-von-essen))
- Cleanup the boxes to actually work [\#219](https://github.com/chef/bento/pull/219) ([sethvargo](https://github.com/sethvargo))
- Dependency Fix [\#218](https://github.com/chef/bento/pull/218) ([bdwyertech](https://github.com/bdwyertech))
- Update Debian Wheezy to 7.5 [\#216](https://github.com/chef/bento/pull/216) ([tmatilai](https://github.com/tmatilai))
- Update to OmniOS r151008t [\#212](https://github.com/chef/bento/pull/212) ([juliandunn](https://github.com/juliandunn))
- Support Red Hat Enterprise Linux 7 Release Candidate. [\#210](https://github.com/chef/bento/pull/210) ([juliandunn](https://github.com/juliandunn))
- Add links to new ubuntu images [\#209](https://github.com/chef/bento/pull/209) ([Maks3w](https://github.com/Maks3w))
- Cleanup inconsistencies in Ubuntu templates. [\#206](https://github.com/chef/bento/pull/206) ([juliandunn](https://github.com/juliandunn))
- Add templates for Ubuntu 14.04 [\#205](https://github.com/chef/bento/pull/205) ([rjocoleman](https://github.com/rjocoleman))
- Update vagrant.sh [\#204](https://github.com/chef/bento/pull/204) ([sbarber](https://github.com/sbarber))
- The wget failed in Debian distro [\#199](https://github.com/chef/bento/pull/199) ([rhacker](https://github.com/rhacker))
- Make sure to update checksums and ISOs for vmware-iso builder too. [\#191](https://github.com/chef/bento/pull/191) ([juliandunn](https://github.com/juliandunn))
- BENTO-116: use ISO for Ubuntu 12.04.04, not 12.04.03 [\#190](https://github.com/chef/bento/pull/190) ([client9](https://github.com/client9))
- Bugfixes for FreeBSD 10 [\#189](https://github.com/chef/bento/pull/189) ([juliandunn](https://github.com/juliandunn))
- slim down Fedora boxes using same ks.cfg minimizations as CentOS [\#187](https://github.com/chef/bento/pull/187) ([juliandunn](https://github.com/juliandunn))
- Remove Ubuntu 13.04: EOL as of January 27, 2014 [\#185](https://github.com/chef/bento/pull/185) ([juliandunn](https://github.com/juliandunn))
- Slim down box builds by removing unnecessary firmware and docs. [\#183](https://github.com/chef/bento/pull/183) ([juliandunn](https://github.com/juliandunn))
- Force CRLF on Autounattend files for Windows [\#175](https://github.com/chef/bento/pull/175) ([juliandunn](https://github.com/juliandunn))
- Update Debian 6.0.8 to 6.0.9 [\#170](https://github.com/chef/bento/pull/170) ([tmatilai](https://github.com/tmatilai))
- Updated to OmniOS r151008j [\#169](https://github.com/chef/bento/pull/169) ([juliandunn](https://github.com/juliandunn))
- End-of-life: Fedora 18 and Debian 7.2 [\#168](https://github.com/chef/bento/pull/168) ([juliandunn](https://github.com/juliandunn))
- BENTO-112 add single-request-reopen to resolv.conf [\#165](https://github.com/chef/bento/pull/165) ([rjocoleman](https://github.com/rjocoleman))
- Add Packer templates for Debian 7.4 [\#164](https://github.com/chef/bento/pull/164) ([tmatilai](https://github.com/tmatilai))
- Use sudoers.d in Debian [\#163](https://github.com/chef/bento/pull/163) ([tmatilai](https://github.com/tmatilai))
- Fix DHCP lease directory name in Debian [\#162](https://github.com/chef/bento/pull/162) ([tmatilai](https://github.com/tmatilai))
- Allow `packer\_cache` to be symlink [\#161](https://github.com/chef/bento/pull/161) ([tmatilai](https://github.com/tmatilai))
- Debian 7.3.0 support [\#160](https://github.com/chef/bento/pull/160) ([fadenb](https://github.com/fadenb))
- Finalize FreeBSD 10 support [\#159](https://github.com/chef/bento/pull/159) ([juliandunn](https://github.com/juliandunn))
- support mirror variable for iso\_url in all centos/vmware builders [\#158](https://github.com/chef/bento/pull/158) ([adler](https://github.com/adler))
- \[BENTO-111\] Added a .gitattributes and a note for Windows hosts [\#157](https://github.com/chef/bento/pull/157) ([maoueh](https://github.com/maoueh))
- Don't disable selinux on Fedora; just make it Permissive. [\#156](https://github.com/chef/bento/pull/156) ([juliandunn](https://github.com/juliandunn))
- Fixing outdated command in README [\#155](https://github.com/chef/bento/pull/155) ([apetresc](https://github.com/apetresc))
- Update vmtools branch logic to reflect new providers in packer 0.5.1- [\#154](https://github.com/chef/bento/pull/154) ([lwieske](https://github.com/lwieske))
- Repair FreeBSD definitions after they got corrupted by a Packer bug. [\#153](https://github.com/chef/bento/pull/153) ([juliandunn](https://github.com/juliandunn))
- Update to packer 0.5.1 [\#152](https://github.com/chef/bento/pull/152) ([lwieske](https://github.com/lwieske))
- Update sshd.sh [\#150](https://github.com/chef/bento/pull/150) ([sc0ttruss](https://github.com/sc0ttruss))
- Update to packer 0.4.1. [\#148](https://github.com/chef/bento/pull/148) ([juliandunn](https://github.com/juliandunn))
- Allow building provisionered OmniOS boxes. [\#146](https://github.com/chef/bento/pull/146) ([juliandunn](https://github.com/juliandunn))
- Rewrite chef.sh to be more cross-platform. [\#145](https://github.com/chef/bento/pull/145) ([juliandunn](https://github.com/juliandunn))
- Fix FreeBSD i386 not passing env vars through properly [\#141](https://github.com/chef/bento/pull/141) ([juliandunn](https://github.com/juliandunn))
- Update readme for CentOS 6.5 [\#137](https://github.com/chef/bento/pull/137) ([juliandunn](https://github.com/juliandunn))
- Make Thor actually exit non-zero when a validation error occurs. [\#136](https://github.com/chef/bento/pull/136) ([juliandunn](https://github.com/juliandunn))
- Fix broken CentOS 6.5 i386 template [\#135](https://github.com/chef/bento/pull/135) ([juliandunn](https://github.com/juliandunn))
- Allow RHEL mirror URL to be customized at box build time [\#134](https://github.com/chef/bento/pull/134) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-83\] Add working templates for SuSE Linux Enterprise Server 11 [\#132](https://github.com/chef/bento/pull/132) ([juliandunn](https://github.com/juliandunn))
- Reduce memory usage of FreeBSD box to 512M [\#129](https://github.com/chef/bento/pull/129) ([juliandunn](https://github.com/juliandunn))
- Repair incorrect SHA1 checksum on Ubuntu 12.04-i386 box [\#128](https://github.com/chef/bento/pull/128) ([juliandunn](https://github.com/juliandunn))
- Upgrade FreeBSD box to 9.2 [\#127](https://github.com/chef/bento/pull/127) ([juliandunn](https://github.com/juliandunn))
- Fix incorrect FreeBSD i386 guest\_os\_type [\#126](https://github.com/chef/bento/pull/126) ([juliandunn](https://github.com/juliandunn))
- Bash is dead, Long live Bash. [\#120](https://github.com/chef/bento/pull/120) ([petecheslock](https://github.com/petecheslock))
- Migrate to RHEL 6.5. Also be consistent about the output package name. [\#119](https://github.com/chef/bento/pull/119) ([juliandunn](https://github.com/juliandunn))
- Fix incorrect CPU type on Ubuntu 12.10. [\#117](https://github.com/chef/bento/pull/117) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-91\] Re-fix sudoers rules for Ubuntu \>= 12.04 [\#116](https://github.com/chef/bento/pull/116) ([juliandunn](https://github.com/juliandunn))
- BENTO-96 fix execute\_command for debian to include env vars [\#115](https://github.com/chef/bento/pull/115) ([fourseven](https://github.com/fourseven))
- BENTO-94 and BENTO-95 Fixes [\#114](https://github.com/chef/bento/pull/114) ([bflad](https://github.com/bflad))
- Fix documentation in README; add info on how to build legacy veewee base... [\#112](https://github.com/chef/bento/pull/112) ([juliandunn](https://github.com/juliandunn))
- Fix .gitignore for iso dir [\#110](https://github.com/chef/bento/pull/110) ([juliandunn](https://github.com/juliandunn))
- Add Windows 2012R2 server definitions. [\#107](https://github.com/chef/bento/pull/107) ([juliandunn](https://github.com/juliandunn))
- Added templates for RHEL. [\#106](https://github.com/chef/bento/pull/106) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-5\] Add NFS client capability to CentOS and Fedora templates. [\#105](https://github.com/chef/bento/pull/105) ([andytson](https://github.com/andytson))
- Fix all Packer validation errors [\#104](https://github.com/chef/bento/pull/104) ([juliandunn](https://github.com/juliandunn))
- CentOS 6.4 won't install with only 384MB of RAM [\#102](https://github.com/chef/bento/pull/102) ([juliandunn](https://github.com/juliandunn))
- Debian 6.0.8 [\#100](https://github.com/chef/bento/pull/100) ([someara](https://github.com/someara))
- Debian 7.2.0 [\#99](https://github.com/chef/bento/pull/99) ([someara](https://github.com/someara))
- Upgrade to CentOS 5.10 [\#97](https://github.com/chef/bento/pull/97) ([juliandunn](https://github.com/juliandunn))
- added ubuntu-13.10 packer templates w/debian sudoers scripts [\#96](https://github.com/chef/bento/pull/96) ([routelastresort](https://github.com/routelastresort))
- Use proper packer env var for checking VirtualBox [\#95](https://github.com/chef/bento/pull/95) ([juliandunn](https://github.com/juliandunn))
- fixing packer templates to work on vmware [\#93](https://github.com/chef/bento/pull/93) ([someara](https://github.com/someara))
- Fix box names [\#90](https://github.com/chef/bento/pull/90) ([tduffield](https://github.com/tduffield))
- Clean FreeBSD boxes to save space. [\#89](https://github.com/chef/bento/pull/89) ([juliandunn](https://github.com/juliandunn))
- Remove bash from the FreeBSD image. [\#88](https://github.com/chef/bento/pull/88) ([juliandunn](https://github.com/juliandunn))
- Cleanup shutdown scripts [\#87](https://github.com/chef/bento/pull/87) ([tduffield](https://github.com/tduffield))
- removed name field from all templates [\#86](https://github.com/chef/bento/pull/86) ([tduffield](https://github.com/tduffield))
- Since the 12.04 release, Ubuntu uses the more standard "sudo" group [\#84](https://github.com/chef/bento/pull/84) ([whiteley](https://github.com/whiteley))
- Fixup readme for packer [\#83](https://github.com/chef/bento/pull/83) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-84\] Update Ubuntu LTS definitions to 12.04.3 [\#81](https://github.com/chef/bento/pull/81) ([juliandunn](https://github.com/juliandunn))
- Updated to vagrant-windows that works under Vagrant 1.2 and 1.3 [\#80](https://github.com/chef/bento/pull/80) ([juliandunn](https://github.com/juliandunn))
- Added Fedora 19 to list of documented boxes. [\#78](https://github.com/chef/bento/pull/78) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-82\] Import same fix from PR\#72 to i386 box. [\#77](https://github.com/chef/bento/pull/77) ([juliandunn](https://github.com/juliandunn))
- Bump to Vagrant 1.2.7 [\#76](https://github.com/chef/bento/pull/76) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-13\] ensure `kudzu` is uninstalled on CentOS boxes [\#75](https://github.com/chef/bento/pull/75) ([schisamo](https://github.com/schisamo))
- Ensure /etc/sudoers sed replacement works for Debian 7.x. [\#73](https://github.com/chef/bento/pull/73) ([justsee](https://github.com/justsee))
- Add preseed command to comment out cdrom in /etc/apt/sources.list. [\#72](https://github.com/chef/bento/pull/72) ([justsee](https://github.com/justsee))
- \[BENTO-80\] Sudoer should use secure\_path by default [\#70](https://github.com/chef/bento/pull/70) ([jamesonjlee](https://github.com/jamesonjlee))
- Added definitions for SUSE Linux Enterprise Server 11 SP3. [\#68](https://github.com/chef/bento/pull/68) ([juliandunn](https://github.com/juliandunn))
- Added definitions for Fedora 19, Schrodinger's Cat [\#66](https://github.com/chef/bento/pull/66) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-58\] Switch to manual partitioning since autopart makes /tmp too small to actually run tests sensibly [\#65](https://github.com/chef/bento/pull/65) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-50\] Add documentation for all current baseboxes [\#64](https://github.com/chef/bento/pull/64) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-56\] Fix missing vagrant user in the sudoers file [\#63](https://github.com/chef/bento/pull/63) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-54\] Fix Debian 7 definitions [\#62](https://github.com/chef/bento/pull/62) ([vaskas](https://github.com/vaskas))
- \[BENTO-53\] Fixed paths for Debian 6.0.7 ISOs [\#61](https://github.com/chef/bento/pull/61) ([hectcastro](https://github.com/hectcastro))
- \[BENTO-49\] Debian 6 definitions broken: missing sshd.sh [\#60](https://github.com/chef/bento/pull/60) ([zuazo](https://github.com/zuazo))
- \[BENTO-48\] Add SLES11SP2 definitions [\#59](https://github.com/chef/bento/pull/59) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-47\] Regenerate Autounattend.xml for Windows 2012 to unbreak it. [\#57](https://github.com/chef/bento/pull/57) ([juliandunn](https://github.com/juliandunn))
- Fix Gemfile and Gemfile.lock. [\#55](https://github.com/chef/bento/pull/55) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-46\] Update centos 6.4 definitions to use the common components. [\#54](https://github.com/chef/bento/pull/54) ([lewg](https://github.com/lewg))
- \[BENTO-45\] Install vmware tools if on fusion provider. [\#53](https://github.com/chef/bento/pull/53) ([lewg](https://github.com/lewg))
- Fix PR\#33 - CentOS 5.8 is in the vault now. [\#52](https://github.com/chef/bento/pull/52) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-41\] Check to see if you're on VirtualBox [\#51](https://github.com/chef/bento/pull/51) ([lewg](https://github.com/lewg))
- \[BENTO-19\] Use the VirtualBox ISO that veewee attaches to the machine [\#50](https://github.com/chef/bento/pull/50) ([juliandunn](https://github.com/juliandunn))
- Upgrade to veewee that has hooks \(we may use them\) [\#49](https://github.com/chef/bento/pull/49) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-37\] Added definitions for ubuntu 13.04. [\#48](https://github.com/chef/bento/pull/48) ([juliandunn](https://github.com/juliandunn))
- Add Debian 7.0.0 definitions [\#47](https://github.com/chef/bento/pull/47) ([jtimberman](https://github.com/jtimberman))
- \[BENTO-35\] Do not ship Chef with our baseboxes anymore. [\#46](https://github.com/chef/bento/pull/46) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-10\] Add "UseDNS no" to all sshd configs [\#45](https://github.com/chef/bento/pull/45) ([juliandunn](https://github.com/juliandunn))
- Fix Windows 8 Enterprise box builds. [\#44](https://github.com/chef/bento/pull/44) ([juliandunn](https://github.com/juliandunn))
- Windows 8 and 2012 fixes [\#43](https://github.com/chef/bento/pull/43) ([juliandunn](https://github.com/juliandunn))
- Added ubuntu-12.10 definitions. [\#41](https://github.com/chef/bento/pull/41) ([johnbellone](https://github.com/johnbellone))
- Update documentation for Chef 11.4.4. Update Gemfile for vagrant 1.2.2. [\#40](https://github.com/chef/bento/pull/40) ([juliandunn](https://github.com/juliandunn))
- Add a task to update apt-get on boot in ubuntu. [\#39](https://github.com/chef/bento/pull/39) ([whilp](https://github.com/whilp))
- update build directions, new links for Chef 11.4.0 baseboxes [\#38](https://github.com/chef/bento/pull/38) ([juliandunn](https://github.com/juliandunn))
- fix Windows box builds for Vagrant 1.1 [\#37](https://github.com/chef/bento/pull/37) ([juliandunn](https://github.com/juliandunn))
- Added defs for CentOS 5.9 and 6.4 boxes. Bugfix CentOS 5.8 x86\_64 box. [\#36](https://github.com/chef/bento/pull/36) ([juliandunn](https://github.com/juliandunn))
- Repin gemset to Vagrant 1.1 versions and veewee head [\#35](https://github.com/chef/bento/pull/35) ([juliandunn](https://github.com/juliandunn))
- \[BENTO-31\] debian 6.0.5 is no longer available, change to 6.0.7 [\#32](https://github.com/chef/bento/pull/32) ([ctdk](https://github.com/ctdk))
- Vagrant11+2008 [\#30](https://github.com/chef/bento/pull/30) ([hh](https://github.com/hh))
- Windows+2012+8 [\#29](https://github.com/chef/bento/pull/29) ([hh](https://github.com/hh))
- \[BENTO-28\] Use Centos, not RedHat for os\_type\_id [\#27](https://github.com/chef/bento/pull/27) ([chulkilee](https://github.com/chulkilee))
- \[BENTO-24\] "\#" is not a valid comment character for Windows batch files [\#22](https://github.com/chef/bento/pull/22) ([juliandunn](https://github.com/juliandunn))
- Update to ubuntu 12.04.2 [\#20](https://github.com/chef/bento/pull/20) ([rnewson](https://github.com/rnewson))
- \[BENTO-20\] add fedora 18 support [\#17](https://github.com/chef/bento/pull/17) ([josephholsten](https://github.com/josephholsten))
- BENTO-17 passes validation for windows 7 and 2008R2 [\#15](https://github.com/chef/bento/pull/15) ([hh](https://github.com/hh))
- \[BENTO-2\] Update Ubuntu iso filenames, md5sums. [\#6](https://github.com/chef/bento/pull/6) ([torandu](https://github.com/torandu))
- \[BENTO-4\] Updated centos 6.2 iso urls to use the vault.centos.org url [\#4](https://github.com/chef/bento/pull/4) ([cburyta](https://github.com/cburyta))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
