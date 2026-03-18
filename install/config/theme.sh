source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Theme"

theme="${DISTROMAC_THEME:-catppuccin-mocha}"
log_info "Setting theme: $theme"
distromac-theme-set "$theme"
log_success "Theme applied: $theme"
