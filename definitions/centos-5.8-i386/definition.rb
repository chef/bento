require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-5.8-i386-bin-DVD-1of2.iso"

session =
  CENTOS_SESSION.merge({ :os_type_id => 'RedHat',
                         :iso_file => iso,
                         :iso_md5 => "0fdd45c43b5d8fb9e05f4255c5855f9c",
                         :iso_src => "http://mirror.stanford.edu/yum/pub/centos/5.8/isos/i386/#{iso}" })

Veewee::Session.declare session
