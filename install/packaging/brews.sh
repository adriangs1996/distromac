source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "CLI Tools (Homebrew)"

# Always-install CLI tools
core_brews=(bat lsd starship fzf ripgrep fd jq git gh)

for pkg in "${core_brews[@]}"; do
  distromac-brew-install "$pkg"
done

# Optional brews gated by --no-<app> flags
[[ ${DISTROMAC_NO_NVIM} != "1" ]]       && distromac-brew-install neovim
[[ ${DISTROMAC_NO_TMUX} != "1" ]]       && distromac-brew-install tmux
[[ ${DISTROMAC_NO_SKETCHYBAR} != "1" ]] && distromac-brew-install sketchybar
[[ ${DISTROMAC_NO_BORDERS} != "1" ]]    && distromac-brew-install borders
[[ ${DISTROMAC_NO_AEROSPACE} != "1" ]]  && distromac-brew-install aerospace

log_success "CLI tools installed"
