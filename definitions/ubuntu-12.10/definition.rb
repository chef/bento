require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-12.10-server-amd64.iso"

session =
  UBUNTU_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "7ad57cadae955bd04019389d4b9c1dcb",
                        :iso_src => "http://releases.ubuntu.com/12.10/#{iso}" )

Veewee::Session.declare session
