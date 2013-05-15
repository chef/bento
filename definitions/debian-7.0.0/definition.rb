require File.dirname(__FILE__) + "/../.debian/session.rb"

iso = "debian-7.0.0-amd64-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "5f9aea239b122454dc360d52e85d6bf8",
                        :iso_src => "http://cdimage.debian.org/debian-cd/7.0.0/amd64/iso-cd/#{iso}")

Veewee::Session.declare session
