require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-11.10-server-amd64.iso"

session =
  UBUNTU_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "f8a0112b7cb5dcd6d564dbe59f18c35f",
                        :iso_src => "http://releases.ubuntu.com/11.10/#{iso}" )

Veewee::Session.declare session
