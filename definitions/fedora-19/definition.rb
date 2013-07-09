require File.dirname(__FILE__) + "/../.fedora/session.rb"

iso = "Fedora-19-x86_64-DVD.iso"

session =
  FEDORA_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "638d69c23621d5befc714bcd66b0611e",
                        :iso_src => "http://mirrors.kernel.org/fedora/releases/19/Fedora/x86_64/iso/#{iso}"
)

Veewee::Session.declare session
