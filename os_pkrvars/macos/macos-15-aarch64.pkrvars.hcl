os_name    = "macos"
os_version = "15.7.2"
os_arch    = "aarch64"
# Download urls cn be foud at https://ipsw.me/VirtualMac2,1
parallels_ipsw_url      = "https://updates.cdn-apple.com/2025SummerFCS/fullrestores/093-10809/CFD6DD38-DAF0-40DA-854F-31AAD1294C6F/UniversalMac_15.6.1_24G90_Restore.ipsw"
parallels_ipsw_checksum = "3d87686b691ac765eb6a6b3082b2334e2af9710096a00432dd519af89ff2ea78"
utm_vm_icon             = "mac"
sources_enabled         = ["source.parallels-ipsw.vm"]
default_boot_wait       = "15s"
boot_command = [
  # hello, hola, bonjour, etc.
  "<wait><spacebar><wait5s>",
  # Select Language English (US)
  "<enter><wait10s>",
  # Select Your Country and Region
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait10s>",
  # Transfer your data to this Mac
  "<tab><wait><tab><wait><tab><wait><tab><wait><spacebar><wait><tab><wait><tab><wait><spacebar><wait5s>",
  # Written and Spoken Languages
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Accessibility
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Data & Privacy
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Create a Computer Account
  "vagrant<wait><tab><wait><tab><wait>vagrant<wait><tab><wait>vagrant<wait><tab><wait><tab><wait><spacebar><wait><tab><wait><tab><wait><spacebar><wait1m>",
  # Sign In with Your Apple ID
  "<leftShiftOn><tab><wait><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Are you sure you want to skip signing in with an Apple ID?
  "<tab><wait><spacebar><wait5s>",
  # Terms and Conditions
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # I have read and agree to the macOS Software License Agreement
  "<tab><wait><spacebar><wait5s>",
  # Enable Location Services
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Are you sure you don't want to use Location Services?
  "<tab><wait><spacebar><wait10s>",
  # Select Your Time Zone
  "<tab><wait><tab><wait>UTC<wait><enter><wait><leftShiftOn><tab><wait><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Analytics
  "<tab><wait><spacebar><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Screen Time
  "<tab><wait><spacebar><wait5s>",
  # Siri
  "<tab><wait><spacebar><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Choose Your Look
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Update mac
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait30s>",
  # Open Terminal
  "<spacebar><wait><leftSuperOn><spacebar><leftSuperOff><wait>terminal<wait><enter><wait5s>",
  # Add vagrant user to sudoers
  "echo 'vagrant' | sudo -S sh -c 'echo \"vagrant ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/vagrant'<wait><enter><wait5s>",
  # Set Auto login for vagrant
  "sudo sysadminctl -autologin set -userName vagrant -password vagrant<wait><enter><wait5s>",
  # Disable screen lock
  "sudo sysadminctl -screenLock off -password vagrant<wait><enter><wait5s>",
  # Close terminal
  "exit<enter><wait5s>",
  "<leftSuperOn>q<leftSuperOff>",
  # Enable keyboard navigation
  "<wait><leftCtrlOn><f7><leftCtrlOff><wait2s>",
  # Open System Settings
  "<leftSuperOn><spacebar><leftSuperOff><wait>System<spacebar>Settings<wait><enter><wait5s>",
  # Enable Remote Management
  "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait><spacebar><wait5s>",
  "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait><spacebar><wait5s>",
  # Enable Remote Login
  "<tab><tab><wait><spacebar><wait5s>",
  # Close System Preferences
  "<leftSuperOn>q<leftSuperOff><wait5s>",
  # Disable keyboard navigation
  "<leftCtrlOn><f7><leftCtrlOff><wait2s>",
]
