# Verify we're on macOS Sonoma (14.0) or later
source "$DISTROMAC_PATH/install/helpers/logging.sh"
source "$DISTROMAC_PATH/install/helpers/checks.sh"

log_step "Preflight checks"

if ! is_macos; then
  log_error "distromac requires macOS. Detected: $(uname -s)"
  exit 1
fi

major=$(macos_version_major)
if (( major < 14 )); then
  log_error "distromac requires macOS Sonoma (14.0) or later. Detected: $(macos_version)"
  exit 1
fi

log_success "macOS $(macos_version) — OK"
