source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Shell configuration"

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log_info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  log_success "Oh My Zsh installed"
else
  log_success "Oh My Zsh already installed"
fi

# Plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-vi-mode" ]]; then
  git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"
fi

log_success "Shell plugins installed"

# TPM (Tmux Plugin Manager)
if [[ ${DISTROMAC_NO_TMUX} != "1" ]]; then
  TPM_DIR="$HOME/.config/tmux/plugins/tpm"
  if [[ ! -d "$TPM_DIR" ]]; then
    log_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    log_success "TPM installed"
  else
    log_success "TPM already installed"
  fi

  # Install tmux plugins headlessly
  if [[ -f "$TPM_DIR/bin/install_plugins" ]]; then
    log_info "Installing tmux plugins..."
    "$TPM_DIR/bin/install_plugins" &>/dev/null || true
    log_success "Tmux plugins installed"
  fi
fi
