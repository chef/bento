require File.dirname(__FILE__) + "/../.suse/session.rb"

iso = "SLES-11-SP2-DVD-x86_64-GM-DVD1.iso"

session =
  SUSE_SESSION.merge( :memory_size=> '480',
                      :iso_download_instructions => "Download evaluation version from http://download.novell.com/SummaryFree.jsp?buildid=h0AOp5AT-18~",
                      :iso_file => iso,
                      :iso_md5 => "461d82ae6e15062b0807c1338f040497",
                      :iso_src => "")

Veewee::Session.declare session
