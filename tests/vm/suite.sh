#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/distromac}"
export DISTROMAC_PATH

# Ensure brew-installed tools are in PATH (homebrew may not be in
# default PATH on a fresh VM until shell profile is reloaded)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$DISTROMAC_PATH/bin:$PATH"

# Source assertion library
source "$DISTROMAC_PATH/tests/vm/assert.sh"

# Ordered suite list
ALL_SUITES=(install themes commands update)

# Filter by DISTROMAC_TEST_SUITE if set
if [[ -n ${DISTROMAC_TEST_SUITE:-} ]]; then
  SUITES=("$DISTROMAC_TEST_SUITE")
else
  SUITES=("${ALL_SUITES[@]}")
fi

# Run each suite
for suite in "${SUITES[@]}"; do
  echo ""
  echo "[SUITE] $suite"
  source "$DISTROMAC_PATH/tests/vm/test_${suite}.sh"

  # After install suite, refresh PATH so brew-installed tools are found
  if [[ $suite == "install" && -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$DISTROMAC_PATH/bin:$PATH"
  fi
done

# Summary
echo ""
echo "=============================="
printf '  Results: %d passed, %d failed\n' "$ASSERT_PASS" "$ASSERT_FAIL"
echo "=============================="

if (( ASSERT_FAIL > 0 )); then
  exit 1
fi
