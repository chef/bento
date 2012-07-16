require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-10.10-server-amd64.iso"

session =
  UBUNTU_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "ab66a1d59a8d78e9ea8ef9b021d6574a",
                        :iso_src => "http://releases.ubuntu.com/10.10/#{iso}" )

Veewee::Session.declare session
