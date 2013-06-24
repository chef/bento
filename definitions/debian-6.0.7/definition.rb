require File.dirname(__FILE__) + "/../.debian/session.rb"

iso = "debian-6.0.7-amd64-CD-1.iso"

session =
  DEBIAN_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "8f0e86d19bc90768da08cdafb4f9edbb",
                        :iso_src => "http://cdimage.debian.org/cdimage/archive/6.0.7/amd64/iso-cd/#{iso}")

Veewee::Session.declare session
