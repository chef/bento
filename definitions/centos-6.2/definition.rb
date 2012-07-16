require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-6.2-x86_64-bin-DVD1.iso"

session =
  CENTOS_SESSION.merge( :boot_cmd_sequence =>
                        [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                        :memory_size=> '480',
                        :iso_file => iso,
                        :iso_md5 => "26fdf8c5a787a674f3219a3554b131ca",
                        :iso_src => "http://mirrors.kernel.org/centos/6.2/isos/x86_64/#{iso}" )

Veewee::Session.declare session
