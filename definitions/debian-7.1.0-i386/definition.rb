require File.dirname(__FILE__) + "/../.debian/session.rb"

iso = "debian-7.1.0-i386-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :os_type_id => 'Debian',
                        :iso_file => iso,
                        :iso_md5 => "c29ec2db6754dadd341b9763164aca9a",
                        :iso_src => "http://cdimage.debian.org/debian-cd/7.1.0/i386/iso-cd/#{iso}")

Veewee::Session.declare session
