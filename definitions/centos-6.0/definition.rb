require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-6.0-x86_64-bin-DVD1.iso"

session =
  CENTOS_SESSION.merge( :boot_cmd_sequence =>
                        [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
                        :iso_file => iso,
                        :iso_md5 => "7c148e0a1b330186adef66ee3e2d433d",
                        :iso_src => "http://vault.centos.org/6.0/isos/x86_64/#{iso}" )

Veewee::Session.declare session
