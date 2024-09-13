#!/bin/sh

echo "Downloading and installing system updates..."
softwareupdate -i -a -R

echo 'Disable automatic updates'
# TOGGLE ALL OFF (auto checking is on to show other prefs are toggled off)
# before setting values quit system preferences & stop software update - stops defaults cache breaking 'AutomaticCheckEnabled'
osascript -e "tell application \"System Preferences\" to quit"
softwareupdate --schedule off
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool No
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool NO
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool NO
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool NO
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool NO
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool NO
