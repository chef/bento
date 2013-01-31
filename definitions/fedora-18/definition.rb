require File.dirname(__FILE__) + "/../.fedora/session.rb"

iso = "Fedora-18-x86_64-DVD.iso"

session =
  FEDORA_SESSION.merge( # :boot_cmd_sequence =>
                        #[ '<Tab> linux text biosdevname=0 ks=http://%IP%:%PORT%/ks.cfg<Enter><Enter>' ],
                        #:memory_size=> '480',
                        :iso_file => iso,
                        #:iso_md5 => "a991defc0a602d04f064c43290df0131",
                        :iso_src => "http://mirrors.kernel.org/fedora/releases/18/Fedora/x86_64/iso/#{iso}"
                        # Minimum RAM requirement for installation is 512MB.
                        #:memory_size=> '512',
)

Veewee::Session.declare session
