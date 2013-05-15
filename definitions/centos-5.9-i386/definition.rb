require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-5.9-i386-bin-DVD-1of2.iso"

session =
  CENTOS_SESSION.merge({ :os_type_id => 'RedHat',
                         :iso_file => iso,
                         :iso_md5 => "c8caaa18400dfde2065d8ef58eb9e9bf",
                         :iso_src => "http://mirror.stanford.edu/yum/pub/centos/5.9/isos/i386/#{iso}" })

Veewee::Session.declare session
