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

# User dotfiles: symlink ~/.config/distromac/dotfiles/* into $HOME
USER_DOTFILES="$HOME/.config/distromac/dotfiles"
if [[ -d $USER_DOTFILES ]]; then
  for src in "$USER_DOTFILES"/.*  "$USER_DOTFILES"/*; do
    [[ ! -e $src ]] && continue
    fname=$(basename "$src")
    # Skip . and ..
    [[ $fname == "." || $fname == ".." ]] && continue

    target="$HOME/$fname"

    # Backup existing (skip if already a symlink to the same source)
    if [[ -L $target ]] && [[ "$(readlink "$target")" == "$src" ]]; then
      continue
    fi
    if [[ -e $target ]]; then
      mv "$target" "${target}.distromac-backup.${TIMESTAMP}"
      log_info "Backed up ~/$fname"
    fi

    ln -s "$src" "$target"
    log_success "Linked ~/$fname → dotfiles/$fname"
  done
fi
