# Utility functions for the install pipeline
# Source this file, do not execute directly

is_macos() {
  [[ $(uname -s) == "Darwin" ]]
}

macos_version() {
  sw_vers -productVersion
}

macos_version_major() {
  sw_vers -productVersion | cut -d. -f1
}

command_exists() {
  command -v "$1" &>/dev/null
}

app_installed() {
  # Check if a macOS .app exists
  [[ -d "/Applications/$1.app" ]] || [[ -d "$HOME/Applications/$1.app" ]]
}
