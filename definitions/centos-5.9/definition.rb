require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-5.9-x86_64-bin-DVD-1of2.iso"

session =
  CENTOS_SESSION.merge({ :os_type_id => 'RedHat_64',
                         :iso_file => iso,
                         :iso_md5 => "bb795391846e76a7071893cbdf6163c3",
                         :iso_src => "http://mirror.stanford.edu/yum/pub/centos/5.9/isos/x86_64/#{iso}" })

Veewee::Session.declare session
