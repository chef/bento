require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-6.3-i386-bin-DVD1.iso"

session =
  CENTOS_SESSION.merge( :boot_cmd_sequence =>
                        [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                        :memory_size=> '480',
                        :os_type_id => 'Centos',
                        :iso_file => iso,
                        :iso_md5 => "0285160d8ba3cfc720ea55e98e464eac",
                        :iso_src => "http://mirrors.kernel.org/centos/6.3/isos/i386/#{iso}" )

Veewee::Session.declare session
