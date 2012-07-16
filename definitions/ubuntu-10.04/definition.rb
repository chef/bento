require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-10.04.4-server-amd64.iso"

session =
  UBUNTU_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "9b218654cdcdf9722171648c52f8a088",
                        :iso_src => "http://releases.ubuntu.com/10.04.4/#{iso}" )

Veewee::Session.declare session
