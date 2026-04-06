source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Dotfiles"

TIMESTAMP=$(date +%s)

# List of config directories to install
configs=(
  aerospace
  ghostty
  nvim
  sketchybar
  tmux
  starship
  bat
  borders
  lsd
  raycast
)

for app in "${configs[@]}"; do
  # Check if excluded via --no-<app> flag
  flag_var="DISTROMAC_NO_$(echo "$app" | tr '[:lower:]' '[:upper:]')"
  if [[ ${!flag_var} == "1" ]]; then
    log_info "Skipping $app (excluded)"
    continue
  fi

  source_dir="$DISTROMAC_PATH/config/$app"
  target_dir="$HOME/.config/$app"

  if [[ ! -d $source_dir ]]; then
    continue
  fi

  # Backup existing
  if [[ -d $target_dir ]]; then
    backup="${target_dir}.distromac-backup.${TIMESTAMP}"
    mv "$target_dir" "$backup"
    log_info "Backed up $app → $(basename "$backup")"
  fi

  # Copy
  cp -r "$source_dir" "$target_dir"
  log_success "$app configured"
done

# Handle .zshrc separately (lives in $HOME, not ~/.config/)
if [[ -f "$DISTROMAC_PATH/config/zsh/.zshrc" ]]; then
  if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.distromac-backup.${TIMESTAMP}"
    log_info "Backed up .zshrc"
  fi
  cp "$DISTROMAC_PATH/config/zsh/.zshrc" "$HOME/.zshrc"
  log_success ".zshrc configured"
fi

# Handle ~/.tmux.conf — tmux reads this before XDG config, so replace it
# with a redirect to the XDG location managed by distromac
if [[ -f "$HOME/.tmux.conf" ]]; then
  cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.distromac-backup.${TIMESTAMP}"
  log_info "Backed up .tmux.conf"
fi
echo 'source-file ~/.config/tmux/tmux.conf' > "$HOME/.tmux.conf"
log_success ".tmux.conf configured"

# User dotfiles: mirror ~/.config/distromac/dotfiles/ into $HOME
# Uses stow-like approach: directories are created, only leaf files are symlinked.
# This merges safely with distromac-managed configs (e.g., nvim, tmux).
USER_DOTFILES="$HOME/.config/distromac/dotfiles"
if [[ -d $USER_DOTFILES ]]; then
  _link_dotfiles() {
    local src_dir="$1" target_dir="$2"
    for src in "$src_dir"/.* "$src_dir"/*; do
      [[ ! -e $src ]] && continue
      local fname
      fname=$(basename "$src")
      [[ $fname == "." || $fname == ".." ]] && continue

      local target="$target_dir/$fname"

      if [[ -d $src ]]; then
        # Directory: create if needed, then recurse (never symlink dirs)
        mkdir -p "$target"
        _link_dotfiles "$src" "$target"
      else
        # File: symlink (skip if already correctly linked)
        if [[ -L $target ]] && [[ "$(readlink "$target")" == "$src" ]]; then
          continue
        fi
        if [[ -e $target ]]; then
          mv "$target" "${target}.distromac-backup.${TIMESTAMP}"
          local rel="${target#$HOME/}"
          log_info "Backed up ~/$rel"
        fi
        ln -s "$src" "$target"
        local rel="${target#$HOME/}"
        log_success "Linked ~/$rel"
      fi
    done
  }
  _link_dotfiles "$USER_DOTFILES" "$HOME"
fi
