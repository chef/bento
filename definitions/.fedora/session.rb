require File.dirname(__FILE__) + "/../.common/session.rb"

FEDORA_SESSION =
  COMMON_SESSION.merge({ :boot_cmd_sequence =>
                          [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                         :kickstart_file => "ks.cfg",
                         :os_type_id => 'Fedora_64',
                         :memory_size=> "512",
                         :postinstall_files => [ "vagrant.sh",
                                                 "sshd.sh",
                                                 "cleanup.sh",
                                                 "minimize.sh" ],
                         :shutdown_cmd => "/sbin/halt -h -p" })
