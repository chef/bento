require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-12.04.3-server-i386.iso"

session =
  UBUNTU_SESSION.merge( :os_type_id => 'Ubuntu',
                        :iso_file => iso,
                        :iso_md5 => "e7917ff0543d8248d00ffb166def849e",
                        :iso_src => "http://releases.ubuntu.com/12.04/#{iso}" )

Veewee::Session.declare session
