require File.dirname(__FILE__) + "/../.ubuntu/session.rb"

iso = "ubuntu-13.10-server-i386.iso"

session =
  UBUNTU_SESSION.merge( :os_type_id => 'Ubuntu',
                        :iso_file => iso,
                        :iso_md5 => "77043904185d7efa0966b1c2c153805b",
                        :iso_src => "http://releases.ubuntu.com/13.10/#{iso}" )

Veewee::Session.declare session
