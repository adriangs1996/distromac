# macOS Screenshots defaults
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
killall SystemUIServer 2>/dev/null || true
