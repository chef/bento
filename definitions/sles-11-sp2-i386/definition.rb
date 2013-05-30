require File.dirname(__FILE__) + "/../.suse/session.rb"

iso = "SLES-11-SP2-DVD-i586-GM-DVD1.iso"

session =
  SUSE_SESSION.merge( :memory_size=> '480',
                      :iso_download_instructions => "Download evaluation version from http://download.novell.com/Download?buildid=FkjGyLMMiss~",
                      :iso_file => iso,
                      :iso_md5 => "a0b34f6237b2b2a6b2174c82b40ed326",
                      :iso_src => "")

Veewee::Session.declare session
