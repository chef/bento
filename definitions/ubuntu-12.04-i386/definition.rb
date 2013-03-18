require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-12.04.2-server-i386.iso"

session =
  UBUNTU_SESSION.merge( :os_type_id => 'Ubuntu',
                        :iso_file => iso,
                        :iso_md5 => "7d186655efe871ea1a1492faf635beee",
                        :iso_src => "http://releases.ubuntu.com/12.04/#{iso}" )

Veewee::Session.declare session
