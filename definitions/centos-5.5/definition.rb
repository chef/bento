require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-5.5-x86_64-bin-DVD-1of2.iso"

session =
  CENTOS_SESSION.merge({ :iso_file => iso,
                         :iso_md5 => "ac177a5476e3b255b89b659e5b10ba03",
                         :iso_src => "http://vault.centos.org/5.5/isos/x86_64/#{iso}" })

Veewee::Session.declare session
