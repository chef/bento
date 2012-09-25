require File.dirname(__FILE__) + "/../.omnios/session.rb"

iso = "OmniOS_Text_r151002l.iso"

session = OMNIOS_SESSION.merge({
  :iso_file => iso,
  :iso_src  => "http://omnios.omniti.com/media/#{iso}",
  :iso_md5  => "f5d8f0c5531791b877a6f0d1986e4329",
  :iso_download_timeout => "1000",
  :boot_wait => "30",
  :boot_cmd_sequence => [
# Select language (47 = US-English)
    '47<Enter>',
    '<Wait>'*15,
# Enter Shell
    '3<Enter><Wait>',   
# Partition Disk
# Assumes 40GB disk (interactive partitioner in installer kept crashing)
    'format<Enter><Wait>',
    '0<Enter><Wait>',
    'fdisk<Enter><Wait>',
    'y<Enter><Wait>',
    'partition<Enter><Wait>',

    '0<Enter><Wait>',         # Select slice 0
    'root<Enter><Wait>',      # tag root
    '<Enter><Wait>',          # default flags
    '<Enter><Wait>',          # default start cyl
    '15.0gb<Enter><Wait>',    # 15GB slice 0

    '1<Enter><Wait>',         # Select slice 1
    'stand<Enter><Wait>',     # tag stand (shrug)
    '<Enter><Wait>',          # default flags
    '1960<Enter><Wait>',      # start on next avail cyl
    '5217e<Enter><Wait>',     # end on cyl 5217 (entire slice) slice 1

    'label<Enter><Wait>',     # Commit to disk
    'y<Enter><Wait>',         # really
    'quit<Enter><Wait>',      # quit format(1)                                            
    'quit<Enter><Wait>',      # quit format(1)                                            
    'exit<Enter><Wait>',      # exit shell
# Install
    '1<Enter>',
    '<Wait>'*10,
# Skip welcome message
    '<F2><Spacebar><Wait><Wait><Wait><Wait>',
# Select disk....
    '<F2><Spacebar><Wait>',
# Don't use whole disk - select partition (this will let us chose slice later)
    '<Tab><F2><Enter><Wait>',
# Select first partition
   '<F2><Enter><Wait>',
# Don't use whole partition - select slice (this will let us chose slice later)
   '<Tab><F2><Enter><Wait>',
# Select first slice
   '<F2><Enter><Wait>',
# Set hostname
    '<Backspace>'*7,
    'omnios-vagrant<F2><Wait>',
# Set timezone (UTC/GMT) and date (trust that host's clock is right)
    '<F2><Wait>'*2,
# Wait for install
    '<Wait>'*300,
# Reboot and enter shell with default no-passwd root
    '<F8>',
    '<Wait>'*45,
    '<Enter>',
    '<Wait>'*90,
    'root<Enter><Wait><Enter>',
    '<Wait>'*10,
# Update password so Vagrant can log in over SSH
    'passwd<Enter><Wait>',
    'vagrant<Enter><Wait>',
    'vagrant<Enter><Wait>',
# Create Vagrant user (and unlock the passwordless account)
    'useradd -m -k /etc/skel/ -b /export/home -s /usr/bin/bash vagrant<Enter>',
    '<Wait>'*10,
    'passwd -u vagrant<Enter><Wait>',
# Enable the first network device with dhcp
    'ipadm create-if e1000g0<Enter>',
    'ipadm create-addr -T dhcp e1000g0/v4<Enter>', 
    '<Wait>'*5,
    '<Enter>',
# Add Google public DNS
    'echo "nameserver 8.8.8.8" > /etc/resolv.conf<Enter>',
    'cp /etc/nsswitch.dns /etc/nsswitch.conf<Enter>',
# Allow root logins over ssh (at least for now, so we can set up vagrant stuff in the postinstall)
    'sed -i -e "s/PermitRootLogin no/PermitRootLogin yes/" /etc/ssh/sshd_config<Enter>',
    '<Wait>'*3,
# Reboot to ensure all services are cleanly started after network/ssh reconfigs
    '/usr/sbin/shutdown -g 0 -y -i 6<Enter>',
# Keep Vagrant from trying to ssh in too early (before system has started reboot)
    '<Wait>'*60,
  ]
})

Veewee::Session.declare session
