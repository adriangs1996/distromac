source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
  log_success "Already installed"
else
  log_info "Installing Xcode Command Line Tools..."
  xcode-select --install
  log_info "Waiting for installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  log_success "Installed"
fi
