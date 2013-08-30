require File.dirname(__FILE__) + "/../.debian/session.rb"

iso = "debian-7.1.0-amd64-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "6813af64cc9487099210afed14a080e0",
                        :iso_src => "http://cdimage.debian.org/debian-cd/7.1.0/amd64/iso-cd/#{iso}")

Veewee::Session.declare session
