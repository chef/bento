require File.dirname(__FILE__) + "/../.debian/session.rb"

iso = "debian-6.0.5-i386-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :os_type_id => 'Debian',
                        :iso_file => iso,
                        :iso_md5 => "fc9399969a435fe118d5605334477204",
                        :iso_src => "http://cdimage.debian.org/debian-cd/6.0.5/i386/iso-cd/#{iso}")

Veewee::Session.declare session
