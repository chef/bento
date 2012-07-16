require File.dirname(__FILE__) + "/../.common/session.rb"

CENTOS_SESSION =
  COMMON_SESSION.merge({ :boot_cmd_sequence =>
                         [ 'linux text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                         :kickstart_file => "ks.cfg",
                         :os_type_id => 'RedHat_64',
                         :postinstall_files => [ "chef-client.sh",
                                                 "vagrant.sh",
                                                 "cleanup.sh",
                                                 "minimize.sh" ],
                         :shutdown_cmd => "/sbin/halt -h -p" })
