require File.dirname(__FILE__) + "/../.common/session.rb"

UBUNTU_SESSION =
  COMMON_SESSION.merge({ :boot_cmd_sequence =>
                         [
                          "<Esc>",
                          "<Esc>",
                          "<Enter>",
                          "/install/vmlinuz" ,
                          " auto",
                          " console-setup/ask_detect=false",
                          " console-setup/layoutcode=us",
                          " console-setup/modelcode=pc105",
                          " debconf/frontend=noninteractive",
                          " debian-installer=en_US",
                          " fb=false",
                          " initrd=/install/initrd.gz",
                          " kbd-chooser/method=us",
                          " keyboard-configuration/layout=USA",
                          " keyboard-configuration/variant=USA",
                          " locale=en_US",
                          " netcfg/get_domain=vm",
                          " netcfg/get_hostname=vagrant",
                          " noapic" ,
                          " preseed/url=http://%IP%:%PORT%/preseed.cfg",
                          " -- ",
                          "<Enter>"
                         ],
                         :os_type_id => 'Ubuntu_64',
                         :postinstall_files => [ "update.sh",
                                                 "chef-client.sh",
                                                 "vagrant.sh",
                                                 "networking.sh",
                                                 "sudoers.sh",
                                                 "cleanup.sh",
                                                 "minimize.sh" ],
                         :kickstart_file => "preseed.cfg",
                         :shutdown_cmd => "shutdown -P now" })
