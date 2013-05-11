require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-12.10-server-amd64.iso"

session =
  UBUNTU_SESSION.merge( :os_type_id => 'Ubuntu',
                        :iso_file => iso,
                        :iso_md5 => "4bd3270bde86d7e4e017e3847a4af485",
                        :iso_src => "http://releases.ubuntu.com/12.10/#{iso}" )

Veewee::Session.declare session
