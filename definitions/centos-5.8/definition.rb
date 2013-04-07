require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-5.8-x86_64-bin-DVD-1of2.iso"

session =
  CENTOS_SESSION.merge({ :os_type_id => 'RedHat',
                         :iso_file => iso,
                         :iso_md5 => "8a3bf0030f192022943f83fe6b2cf373",
                         :iso_src => "http://vault.centos.org/5.8/isos/x86_64/#{iso}" })

Veewee::Session.declare session
