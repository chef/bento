os_name                 = "macos"
os_version              = "14.4.1"
os_arch                 = "x86_64"
parallels_ipsw_url      = "https://updates.cdn-apple.com/2024WinterFCS/fullrestores/052-77579/4569734E-120C-4F31-AD08-FC1FF825D059/UniversalMac_14.4.1_23E224_Restore.ipsw"
parallels_ipsw_checksum = "78b39816521a6eeaf29221a4e59e83dae98ef5f9e8e718b846f8faab540a48c1"
sources_enabled         = ["source.parallels-ipsw.vm"]
headless                = false
boot_command = [
  # hello, hola, bonjour, etc.
  "<wait><spacebar>",
  # Language: most of the times we have a list of "English"[1], "English (UK)", etc. with
  # "English" language already selected. If we type "english", it'll cause us to switch
  # to the "English (UK)", which is not what we want. To solve this, we switch to some other
  # language first, e.g. "Italiano" and then switch back to "English". We'll then jump to the
  # first entry in a list of "english"-prefixed items, which will be "English".
  #
  # [1]: should be named "English (US)", but oh well 🤷
  "<wait5s>italiano<wait>english<wait><enter>",
  # Select Your Country and Region
  "<wait10s>united states<wait><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Written and Spoken Languages
  "<wait5s><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Accessibility
  "<wait5s><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Data & Privacy
  "<wait5s><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Migration Assistant
  "<wait5s><tab><wait><tab><wait><tab><wait><spacebar>",
  # Sign In with Your Apple ID
  "<wait5s><leftShiftOn><tab><leftShiftOff><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Are you sure you want to skip signing in with an Apple ID?
  "<wait5s><tab><wait><spacebar>",
  # Terms and Conditions
  "<wait5s><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # I have read and agree to the macOS Software License Agreement
  "<wait5s><tab><wait><spacebar>",
  # Create a Computer Account
  "<wait5s>vagrant<wait><tab><wait><tab><wait>vagrant<wait><tab><wait>vagrant<wait><tab><wait><tab><wait><tab><wait><spacebar>",
  # Enable Location Services
  "<wait35s><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Are you sure you don't want to use Location Services?
  "<wait5s><tab><wait><spacebar>",
  # Select Your Time Zone
  "<wait5s><tab><wait>UTC<wait><enter><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Analytics
  "<wait5s><tab><wait><spacebar><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Screen Time
  "<wait5s><tab><wait><spacebar>",
  # Siri
  "<wait5s><tab><wait><spacebar><wait><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Choose Your Look
  "<wait5s><leftShiftOn><tab><leftShiftOff><wait><spacebar>",
  # Enable Voice Over for keyboard access to the UI switches
  "<wait5s><leftSuperOn><f5><leftSuperOff><wait5s>v",
  # Open System Settings
  "<wait5s><leftSuperOn><spacebar><leftSuperOff><wait>system settings<wait><enter>",
  # Enable Remote Management
  "<wait5s><up><wait><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait><spacebar>",
  "<wait5s><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait><spacebar>",
  # Enable Remote Login
  "<wait5s><tab><tab><wait><spacebar>",
  # Close System Preferences
  "<wait5s><leftSuperOn>q<leftSuperOff>",
  # Disable Voice Over
  "<wait5s><leftSuperOn><f5><leftSuperOff>",
  # Open Terminal
  "<wait5s><leftSuperOn><spacebar><leftSuperOff><wait>terminal<wait><enter>",
  # Add vagrant user to sudoers
  "<wait5s>echo 'vagrant' | sudo -S sh -c 'echo \"vagrant ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/vagrant'<wait><enter>",
  # Set Auto login for vagrant
  "<wait5s>sudo sysadminctl -autologin set -userName vagrant -password vagrant<wait><enter>",
  # Disable screen lock
  "<wait5s>sudo sysadminctl -screenLock off -password vagrant<wait><enter>",
  # Install Parallels Tools
  "<wait5s>sudo installer -pkg /Volumes/Parallels\\ Tools/Install.app/Contents/Resources/Install.mpkg -target /<wait><enter>",
  # Reboot
  "<wait5s>sudo shutdown -r +15s<wait><enter>",
  "<wait5s>exit<enter>",
  "<wait5s><leftSuperOn>q<leftSuperOff>"
]
