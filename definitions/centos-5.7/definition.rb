require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-5.7-x86_64-bin-DVD-1of2.iso"

session =
  CENTOS_SESSION.merge({ :iso_file => iso,
                         :iso_md5 => "55eadec0a6e87c5f2883f734d43fdb58",
                         :iso_src => "http://vault.centos.org/5.7/isos/x86_64/#{iso}" })

Veewee::Session.declare session
