require File.dirname(__FILE__) + "/../.suse/session.rb"

iso = "SLES-11-SP3-DVD-i586-GM-DVD1.iso"

session =
  SUSE_SESSION.merge( :memory_size=> '480',
                      :iso_download_instructions => "Download 60-day evaluation from http://download.novell.com/protected/Summary.jsp?buildid=4uiuDMzX0ck~",
                      :iso_file => iso,
                      :iso_md5 => "5c30a409fc8fb3343b4dc90d93ff2c89",
                      :iso_src => "")

Veewee::Session.declare session
