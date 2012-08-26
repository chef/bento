require File.dirname(__FILE__) + "/../.common/session.rb"

FREEBSD_SESSION =
  COMMON_SESSION.merge({ :boot_cmd_sequence =>
                         [
                          '<Esc>',
                          'load geom_mbr',
                          '<Enter>',
                          'load zfs',
                          '<Enter>',
                          'boot -s',
                          '<Enter>',
                          '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
                          '/bin/sh<Enter>',
                          'mdmfs -s 10m md1 /tmp<Enter>',
                          'dhclient -l /tmp/dhclient.lease.em0 em0<Enter>',
                          '<Wait><Wait><Wait>',
                          'echo "Sleeping for 10 seconds, then running install script."<Enter>',
                          'sleep 10 ; fetch -o /tmp/install.sh http://%IP%:%PORT%/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh %NAME%<Enter>'
                         ],
                         :kickstart_file => "install.sh",
                         :memory_size=> "512",
                         :os_type_id => 'FreeBSD_64',
                         :postinstall_files => [
                           "update.sh",
                           "chef-client.sh",
                           "vagrant.sh",
                           "cleanup.sh"
                         ]
                        })
