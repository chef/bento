require File.dirname(__FILE__) + "/../.debian/session.rb"

version = "6.0.6"
iso = "debian-#{version}-i386-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :os_type_id => 'Debian',
                        :iso_file => iso,
                        :iso_md5 => "0d3c0c68aecfb7fa1ac629777d882573",
                        :iso_src => "http://cdimage.debian.org/debian-cd/#{version}/i386/iso-cd/#{iso}")

Veewee::Session.declare session
