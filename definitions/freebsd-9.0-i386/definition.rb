require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-9.0-RELEASE-i386-disc1.iso"

session =
  FREEBSD_SESSION.merge( :iso_file => iso,
                         :iso_md5 => "5bf615f286ee6eeb3ecce45bd8d1622c",
                         :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/i386/i386/ISO-IMAGES/9.0/#{iso}",
                         :os_type_id => "FreeBSD" )

Veewee::Session.declare session
