source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "GUI Apps (Homebrew Casks)"

# Always-install casks
distromac-cask-install google-chrome

# Optional casks gated by --no-<app> flags
[[ ${DISTROMAC_NO_GHOSTTY} != "1" ]]  && distromac-cask-install ghostty
[[ ${DISTROMAC_NO_RAYCAST} != "1" ]]  && distromac-cask-install raycast
[[ ${DISTROMAC_NO_SPOTIFY} != "1" ]]  && distromac-cask-install spotify

log_success "GUI apps installed"
