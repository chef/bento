require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-5.6-x86_64-bin-DVD-1of2.iso"

session =
  CENTOS_SESSION.merge({ :iso_file => iso,
                         :iso_md5 => "b37209879c0fb158fac25045527241ee",
                         :iso_src => "http://mirror.teklinks.com/centos/5.6/isos/x86_64/#{iso}" })

Veewee::Session.declare session
