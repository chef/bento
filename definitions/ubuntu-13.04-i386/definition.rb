require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-13.04-server-i386.iso"

session =
  UBUNTU_SESSION.merge( :os_type_id => 'Ubuntu',
                        :iso_file => iso,
                        :iso_md5 => "73d595b804149fca9547ed94db8ff44f",
                        :iso_src => "http://releases.ubuntu.com/13.04/#{iso}" )

Veewee::Session.declare session
