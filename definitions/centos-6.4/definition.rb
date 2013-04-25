require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-6.4-x86_64-bin-DVD1.iso"

session =
  CENTOS_SESSION.merge( :boot_cmd_sequence =>
                        [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                        :memory_size=> '480',
<<<<<<< HEAD
=======
                        :os_type_id => 'RedHat_64',
>>>>>>> updated/develop
                        :iso_file => iso,
                        :iso_md5 => "0128cfc7c86072b13ee80dd013e0e5d7",
                        :iso_src => "http://mirrors.kernel.org/centos/6.4/isos/x86_64/#{iso}" )

Veewee::Session.declare session
