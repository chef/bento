require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-9.0-RELEASE-amd64-disc1.iso"

session =
  FREEBSD_SESSION.merge( :iso_file => iso,
                         :iso_md5 => "b23ef73412bd50ed62ef8613ca1a4199",
                         :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/9.0/#{iso}" )

Veewee::Session.declare session
