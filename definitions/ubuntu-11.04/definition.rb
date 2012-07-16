require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-11.04-server-amd64.iso"

session =
  UBUNTU_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "355ca2417522cb4a77e0295bf45c5cd5",
                        :iso_src => "http://releases.ubuntu.com/11.04/#{iso}" )

Veewee::Session.declare session
