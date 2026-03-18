source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "macOS Defaults"

if [[ ${DISTROMAC_NO_DEFAULTS} == "1" ]]; then
  log_info "Skipping macOS defaults (excluded)"
  return 0
fi

distromac-defaults-apply
