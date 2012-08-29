require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-12.04.1-server-i386.iso"

session =
  UBUNTU_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "32184a83c8b5e6031e1264e5c499bc03",
                        :iso_src => "http://releases.ubuntu.com/12.04/#{iso}" )

Veewee::Session.declare session
