source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Homebrew"

if command -v brew &>/dev/null; then
  log_success "Already installed"
else
  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to path for the rest of this session
  eval "$(/opt/homebrew/bin/brew shellenv)"
  log_success "Installed"
fi

# Ensure brewed curl + CA certs are available for cask downloads.
# Fresh macOS installs (and VMs) may have outdated system CA certs
# causing SSL failures when downloading casks.
if ! brew list --formula curl &>/dev/null; then
  brew install curl >/dev/null 2>&1 || true
fi
export HOMEBREW_FORCE_BREWED_CURL=1
