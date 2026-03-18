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
