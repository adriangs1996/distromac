source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Language managers"

# rbenv (Ruby)
distromac-brew-install rbenv ruby-build
log_success "rbenv installed"

# uv (Python)
distromac-brew-install uv
log_success "uv installed"

# nvm (Node)
if [[ ! -d "$HOME/.nvm" ]]; then
  log_info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  log_success "nvm installed"
else
  log_success "nvm already installed"
fi

# bun
if ! command -v bun &>/dev/null; then
  log_info "Installing bun..."
  curl -fsSL https://bun.sh/install | bash
  log_success "bun installed"
else
  log_success "bun already installed"
fi

# Rust/Cargo
if ! command -v rustup &>/dev/null; then
  log_info "Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  log_success "rustup installed"
else
  log_success "rustup already installed"
fi
