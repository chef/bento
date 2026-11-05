#!/bin/sh

set -eu

echo 'Disable automatic updates'
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

softwareupdate --schedule off 2>/dev/null || true
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool false
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool false
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool false
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool false
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool false
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool false
