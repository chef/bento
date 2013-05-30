require File.dirname(__FILE__) + "/../.common/session.rb"

SUSE_SESSION =
  COMMON_SESSION.merge({ :boot_cmd_sequence => [
    				'<Esc><Enter>',
    				'linux netdevice=eth0 netsetup=dhcp install=cd:/',
    				' lang=en_US autoyast=http://%IP%:%PORT%/autoinst.xml',
    				' textmode=1',
    				'<Enter>'
  			 ],
                         # in here twice for a reason - YaST2 requests it twice
                         :kickstart_file => ["autoinst.xml", "autoinst.xml"],
                         :os_type_id => 'OpenSUSE_64',
                         :postinstall_files => [ "vagrant.sh",
                                                 "sshd.sh",
                                                 "cleanup.sh",
                                                 "minimize.sh" ],
                         :shutdown_cmd => "/sbin/halt -h -p" })
