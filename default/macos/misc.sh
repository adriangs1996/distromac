# macOS Misc defaults
# Disable startup sound
sudo nvram SystemAudioVolume=" " 2>/dev/null || true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Disable "Are you sure you want to open this application?"
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Autohide native menu bar (replaced by Sketchybar)
defaults write NSGlobalDomain _HIHideMenuBar -bool true
