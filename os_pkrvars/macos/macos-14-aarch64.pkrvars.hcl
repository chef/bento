os_name                 = "macos"
os_version              = "14.4.1"
os_arch                 = "aarch64"
parallels_ipsw_url      = "https://updates.cdn-apple.com/2024WinterFCS/fullrestores/052-77579/4569734E-120C-4F31-AD08-FC1FF825D059/UniversalMac_14.4.1_23E224_Restore.ipsw"
parallels_ipsw_checksum = "78b39816521a6eeaf29221a4e59e83dae98ef5f9e8e718b846f8faab540a48c1"
sources_enabled         = ["source.parallels-ipsw.vm"]
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
  "<tab><wait><tab><wait><tab><wait><spacebar><wait5s>",
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
  "<tab><wait><spacebar><wait5s>",
  # Select Your Time Zone
  "<tab><wait>UTC<wait><enter><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Analytics
  "<tab><wait><spacebar><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Screen Time
  "<tab><wait><spacebar><wait5s>",
  # Siri
  "<tab><wait><spacebar><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar><wait5s>",
  # Choose Your Look
  "<leftShiftOn><tab><leftShiftOff><wait><spacebar><wait30s>",
  # Enable keyboard navigation
  "<leftCtrlOn><f7><leftCtrlOff><wait2s>",
  # Open System Settings
  "<leftSuperOn><spacebar><leftSuperOff><wait>System<spacebar>Settings<wait><enter><wait5s>",
  # Enable Remote Management
  "<up><wait><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait><spacebar><wait5s>",
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
