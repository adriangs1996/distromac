source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Fonts"

fonts=(
  font-jetbrains-mono-nerd-font
  font-cascadia-code-nerd-font
)

for font in "${fonts[@]}"; do
  distromac-cask-install "$font"
done

log_success "Fonts installed"
