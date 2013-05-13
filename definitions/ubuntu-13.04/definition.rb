require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-13.04-server-amd64.iso"

session =
  UBUNTU_SESSION.merge( :os_type_id => 'Ubuntu',
                        :iso_file => iso,
                        :iso_md5 => "7d335ca541fc4945b674459cde7bffb9",
                        :iso_src => "http://releases.ubuntu.com/13.04/#{iso}" )

Veewee::Session.declare session
