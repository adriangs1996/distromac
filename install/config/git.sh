source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Git configuration"

# Set basic git config if not already set
if [[ -z $(git config --global user.name) ]]; then
  log_warn "Git user.name not set. Set it with: git config --global user.name 'Your Name'"
fi

if [[ -z $(git config --global user.email) ]]; then
  log_warn "Git user.email not set. Set it with: git config --global user.email 'you@example.com'"
fi

# Copy git ignore config
mkdir -p "$HOME/.config/git"
if [[ -f "$DISTROMAC_PATH/config/git/ignore" ]]; then
  cp "$DISTROMAC_PATH/config/git/ignore" "$HOME/.config/git/ignore"
fi

log_success "Git configured"
