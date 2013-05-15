require File.dirname(__FILE__) + "/../.common/session.rb"

DEBIAN_SESSION =
  COMMON_SESSION.merge({ :boot_cmd_sequence =>
                         [
                           '<Esc>',
                           'install ',
                           'preseed/url=http://%IP%:%PORT%/preseed.cfg ',
                           'debian-installer=en_US ',
                           'auto ',
                           'locale=en_US ',
                           'kbd-chooser/method=us ',
                           'keyboard-configuration/xkb-keymap=us ',
                           'netcfg/get_hostname=%NAME% ',
                           'netcfg/get_domain=vagrantup.com ',
                           'fb=false ',
                           'debconf/frontend=noninteractive ',
                           'console-setup/ask_detect=false ',
                           'console-keymaps-at/keymap=us ',
                           '<Enter>'
                         ],
                         :os_type_id => 'Debian_64',
                         :postinstall_files => [ "update.sh",
                                                 "vagrant.sh",
                                                 "sshd.sh",
                                                 "networking.sh",
                                                 "sudoers.sh",
                                                 "cleanup.sh",
                                                 "minimize.sh" ],
                         :kickstart_file => "preseed.cfg",
                         :shutdown_cmd => "/sbin/shutdown -h -P now" })
