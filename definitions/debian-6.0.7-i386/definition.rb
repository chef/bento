require File.dirname(__FILE__) + "/../.debian/session.rb"

iso = "debian-6.0.7-i386-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :os_type_id => 'Debian',
                        :iso_file => iso,
                        :iso_md5 => "4480eeae60213eb92e1fce15ebf2faf4",
                        :iso_src => "http://cdimage.debian.org/cdimage/archive/6.0.7/i386/iso-cd/#{iso}")

Veewee::Session.declare session
