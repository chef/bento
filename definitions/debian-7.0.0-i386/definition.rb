require File.dirname(__FILE__) + "/../.debian/session.rb"

iso = "debian-7.0.0-i386-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :os_type_id => 'Debian',
                        :iso_file => iso,
                        :iso_md5 => "c438bb93ac988e3a763107ab484a8c86",
                        :iso_src => "http://cdimage.debian.org/debian-cd/7.0.0/i386/iso-cd/#{iso}")

Veewee::Session.declare session
