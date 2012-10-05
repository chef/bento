require File.dirname(__FILE__) + "/../.debian/session.rb"

version = "6.0.5"
iso = "debian-#{version}-amd64-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "bccf90bdaf352a554e8af99f0af6c655",
                        :iso_src => "http://cdimage.debian.org/debian-cd/#{version}/amd64/iso-cd/#{iso}")

Veewee::Session.declare session
