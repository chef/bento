os_name                 = "freebsd"
os_version              = "14.2"
os_arch                 = "x86_64"
iso_url                 = "https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/14.2/FreeBSD-14.2-RELEASE-amd64-disc1.iso"
iso_checksum            = "file:https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/14.2/CHECKSUM.SHA256-FreeBSD-14.2-RELEASE-amd64"
parallels_guest_os_type = "freebsd"
vbox_guest_os_type      = "FreeBSD_64"
vmware_guest_os_type    = "freebsd-64"
default_boot_wait       = "60s"
# boot_command            = ["<esc><wait>boot -s<wait><enter><wait><wait10><wait10>/bin/sh<enter><wait>mdmfs -s 100m md1 /tmp<enter><wait>mdmfs -s 100m md2 /mnt<enter><wait>dhclient -p /tmp/dhclient.em0.pid -l /tmp/dhclient.lease.em0 em0<enter><wait><wait5>fetch -o /tmp/installerconfig http://{{ .HTTPIP }}:{{ .HTTPPort }}/freebsd/installerconfig && bsdinstall script /tmp/installerconfig<enter><wait>"]
boot_command = [
  "<wait><enter><wait>",                                         # Start install
  "<enter><wait>",                                               # Select keyboard layout
  "freebsd<enter><wait>",                                        # Enter hostname
  "<down><spacebar><enter><wait>",                               # Remove kernel-dbg
  "<enter><wait2>",                                              # Select Auto ZFS
  "<enter><wait>",                                               # Proceed with install
  "<enter><wait5>",                                              # Select stripe
  "<spacebar><wait><enter><wait>",                               # Select disk
  "<left><enter><wait30>",                                       # Confirm disk
  "vagrant<enter><wait>",                                        # Enter root password
  "vagrant<enter><wait>",                                        # Confirm root password
  "<enter><wait>",                                               # Select network interface
  "<enter><wait>",                                               # Confirm IPv4
  "<enter><wait>",                                               # Confirm DHCP
  "<enter><wait>",                                               # Confirm IPv6
  "<enter><wait10>",                                             # Confirm SLAAC
  "<enter><wait>",                                               # Confirm resolver configuration
  "<enter><wait>",                                               # Confirm system clock on UTC
  "0<enter><wait>",                                              # Select UTC timezone
  "<left><enter><wait>",                                         # Confirm UTC timezone
  "<left><enter><wait>",                                         # Set Date
  "<left><enter><wait>",                                         # Set Time
  "<down><down><down><down><down><down><spacebar><enter><wait>", # Disable kernel crash dumps
  "<enter><wait10>",                                             # Confirm no system hardening
  "<enter><wait>",                                               # Add User
  "vagrant<enter><wait>",                                        # Enter username
  "vagrant<enter><wait>",                                        # Confirm username
  "<enter><wait>",                                               # Confirm user UID
  "<enter><wait>",                                               # Confirm user group
  "wheel<enter><wait>",                                          # Add user to wheel group
  "<enter><wait>",                                               # Confirm user login class
  "<enter><wait>",                                               # Confirm user shell
  "<enter><wait>",                                               # Confirm user home directory
  "<enter><wait>",                                               # Confirm user home directory permissions
  "<enter><wait>",                                               # Confirm user home directory not encryption
  "<enter><wait>",                                               # Confirm user password authentication
  "<enter><wait>",                                               # Confirm user password is not empty
  "<enter><wait>",                                               # Confirm user password is not random
  "vagrant<enter><wait>",                                        # Enter password
  "vagrant<enter><wait>",                                        # Confirm password
  "<enter><wait>",                                               # Confirm user account isn't locked out after creation
  "<enter><wait>",                                               # Confirm account creation
  "<enter><wait>",                                               # Confirm do not add another account
  "<enter><wait>",                                               # Confirm exit installer and apply configuration
  "<enter><wait>",                                               # Confirm do not open shell
  "<enter><wait>",                                               # Confirm reboot system
]
