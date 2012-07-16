require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-6.3-x86_64-bin-DVD1.iso"

session =
  CENTOS_SESSION.merge( :boot_cmd_sequence =>
                        [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                        :memory_size=> '480',
                        :iso_file => iso,
                        :iso_md5 => "a991defc0a602d04f064c43290df0131",
                        :iso_src => "http://mirrors.kernel.org/centos/6.3/isos/x86_64/#{iso}" )

Veewee::Session.declare session
