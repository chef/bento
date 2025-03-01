os_name    = "macos"
os_version = "15.3.1"
os_arch    = "aarch64"
# Download urls cn be foud at https://ipsw.me/VirtualMac2,1
parallels_ipsw_url      = "https://updates.cdn-apple.com/2025WinterFCS/fullrestores/072-70618/42F1A8CC-7E07-4329-958A-757FF600C303/UniversalMac_15.3.1_24D70_Restore.ipsw"
parallels_ipsw_checksum = "559a78b75adc6bec77665b17db0e166eba326b04fc534e2a086253be92e043b0"
sources_enabled         = ["source.parallels-ipsw.vm"]
default_boot_wait       = "15s"
boot_command = [
  # hello, hola, bonjour, etc.
  "<wait><spacebar><wait5s>",
  # Select Language English (US)
  "<enter><wait10s>",
  # Select Your Country and Region
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Written and Spoken Languages
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Accessibility
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Data & Privacy
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Migration Assistant
  "<leftShiftOn><tab><wait><tab><wait><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Sign In with Your Apple ID
  "<leftShiftOn><tab><wait><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Are you sure you want to skip signing in with an Apple ID?
  "<tab><wait><spacebar><wait5s>",
  # Terms and Conditions
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # I have read and agree to the macOS Software License Agreement
  "<tab><wait><spacebar><wait5s>",
  # Create a Computer Account
  "vagrant<wait><tab><wait><tab><wait>vagrant<wait><tab><wait>vagrant<wait><tab><wait><tab><wait><tab><wait><spacebar><wait1m>",
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
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait30s>",
  # Enable keyboard navigation
  "<space><wait><leftCtrlOn><f7><leftCtrlOff><wait2s>",
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
  # Open Terminal
  "<leftSuperOn><spacebar><leftSuperOff><wait>terminal<wait><enter><wait5s>",
  # Add vagrant user to sudoers
  "echo 'vagrant' | sudo -S sh -c 'echo \"vagrant ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/vagrant'<wait><enter><wait5s>",
  # Set Auto login for vagrant
  "sudo sysadminctl -autologin set -userName vagrant -password vagrant<wait><enter><wait5s>",
  # Disable screen lock
  "sudo sysadminctl -screenLock off -password vagrant<wait><enter><wait5s>",
  # Install Parallels Tools
  "sudo installer -pkg /Volumes/Parallels\\ Tools/Install.app/Contents/Resources/Install.mpkg -target /<wait><enter><wait5s>",
  # Reboot
  "sudo shutdown -r +15s<wait><enter><wait5s>",
  "exit<enter><wait5s>",
  "<leftSuperOn>q<leftSuperOff>"
]
