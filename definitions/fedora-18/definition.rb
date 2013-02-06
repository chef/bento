require File.dirname(__FILE__) + "/../.fedora/session.rb"

iso = "Fedora-18-x86_64-DVD.iso"

session =
  FEDORA_SESSION.merge( :iso_file => iso,
                        :iso_md5 => "17d5c860bf9dc83e035882a7b33ffc77",
                        :iso_src => "http://mirrors.kernel.org/fedora/releases/18/Fedora/x86_64/iso/#{iso}"
)

Veewee::Session.declare session
