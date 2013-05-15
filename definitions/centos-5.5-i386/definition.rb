require File.dirname(__FILE__) + "/../.centos/session.rb"

iso = "CentOS-5.5-i386-bin-DVD.iso"

session =
  CENTOS_SESSION.merge({ :os_type_id => 'Centos',
                         :iso_file => iso,
                         :iso_md5 => "75c92246479df172de41b14c9b966344",
                         :iso_src => "http://mirror.teklinks.com/centos/5.5/isos/i386/#{iso}" })

Veewee::Session.declare session
