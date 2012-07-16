require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-6.2-i386-bin-DVD1.iso"

session =
  CENTOS_SESSION.merge( :boot_cmd_sequence =>
                        [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                        :memory_size=> '480',
                        :os_type_id => 'RedHat',
                        :iso_file => iso,
                        :iso_md5 => "8c976288ed53dc97439f7ab5854f2648",
                        :iso_src => "http://mirrors.kernel.org/centos/6.2/isos/i386/#{iso}" )

Veewee::Session.declare session
