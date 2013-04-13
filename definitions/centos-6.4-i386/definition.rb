require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-6.4-i386-bin-DVD1.iso"

session =
  CENTOS_SESSION.merge( :boot_cmd_sequence =>
                        [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                        :memory_size=> '480',
                        :os_type_id => 'RedHat',
                        :iso_file => iso,
                        :iso_md5 => "a6049df141579169b217cbb625da4c6d",
                        :iso_src => "http://mirrors.kernel.org/centos/6.4/isos/i386/#{iso}" )

Veewee::Session.declare session
