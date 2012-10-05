require File.dirname(__FILE__) + "/../.debian/session.rb"

version = "6.0.6"
iso = "debian-#{version}-amd64-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "b81e837a5bc946c7af380c057afd2b46",
                        :iso_src => "http://cdimage.debian.org/debian-cd/#{version}/amd64/iso-cd/#{iso}")

Veewee::Session.declare session
