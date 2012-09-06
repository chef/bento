require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-10.04.4-server-i386.iso"

session =
  UBUNTU_SESSION.merge( :os_type_id => 'Ubuntu',
                        :iso_file => iso,
                        :iso_md5 => "fc08a01e78348e3918180ea91a6883bb",
                        :iso_src => "http://releases.ubuntu.com/10.04.4/#{iso}" )

Veewee::Session.declare session
