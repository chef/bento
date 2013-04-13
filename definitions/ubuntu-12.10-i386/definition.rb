require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-12.10-server-i386.iso"

session =
  UBUNTU_SESSION.merge( :os_type_id => 'Ubuntu',
                        :iso_file => iso,
                        :iso_md5 => "b3d4d4edfc8f291af0b83f8a2ba19a2f",
                        :iso_src => "http://releases.ubuntu.com/12.10/#{iso}" )

Veewee::Session.declare session
