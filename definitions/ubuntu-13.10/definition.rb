require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-13.10-server-amd64.iso"

session =
  UBUNTU_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "4d1a8b720cdd14b76ed9410c63a00d0e",
                        :iso_src => "http://releases.ubuntu.com/13.10/#{iso}" )

Veewee::Session.declare session
