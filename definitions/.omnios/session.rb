require File.dirname(__FILE__) + "/../.common/session.rb"

OMNIOS_SESSION =
  COMMON_SESSION.merge({
                         :os_type_id => 'OpenSolaris_64',
                         :memory_size => '1024',
                         :disk_size => '40960',
                         :postinstall_files => [
                            "guest-additions.sh",
                            "vagrant.sh",
                            "chef-solo.sh",
                            "cleanup.sh",
                            "zpool-data.sh"
                         ],
                         :kickstart_file => "",
                         :ssh_login_timeout => "10000",
                         :ssh_user => "root",
                         :ssh_password => "vagrant",
                         :ssh_key => "",
                         :sudo_cmd => "sh '%f'",
                         :shutdown_cmd => "/usr/sbin/shutdown -g 0 -y -i 5" })
