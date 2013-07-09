require File.dirname(__FILE__) + "/../.suse/session.rb"

iso = "SLES-11-SP3-DVD-x86_64-GM-DVD1.iso"

session =
  SUSE_SESSION.merge( :memory_size=> '480',
                      :iso_download_instructions => "Download evaluation version from http://download.novell.com/protected/Summary.jsp?buildid=Q_VbW21BiB4~",
                      :iso_file => iso,
                      :iso_md5 => "480b70d50cbb538382dc2b9325221e1b",
                      :iso_src => "")

Veewee::Session.declare session
