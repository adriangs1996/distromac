#!/usr/bin/env bash
set -eEo pipefail

# distromac installer
# Usage: ./install.sh [--no-<app>] [--theme=<name>] [--no-defaults] [--no-fonts] [--no-languages] [--no-npm] [--minimal]

export DISTROMAC_PATH="${DISTROMAC_PATH:-$(cd "$(dirname "$0")" && pwd)}"
export PATH="$DISTROMAC_PATH/bin:$PATH"

# Parse flags
export DISTROMAC_THEME="catppuccin-mocha"

for arg in "$@"; do
  case "$arg" in
    --no-nvim)       export DISTROMAC_NO_NVIM=1 ;;
    --no-sketchybar) export DISTROMAC_NO_SKETCHYBAR=1 ;;
    --no-aerospace)  export DISTROMAC_NO_AEROSPACE=1 ;;
    --no-tmux)       export DISTROMAC_NO_TMUX=1 ;;
    --no-ghostty)    export DISTROMAC_NO_GHOSTTY=1 ;;
    --no-borders)    export DISTROMAC_NO_BORDERS=1 ;;
    --no-raycast)    export DISTROMAC_NO_RAYCAST=1 ;;
    --no-spotify)    export DISTROMAC_NO_SPOTIFY=1 ;;
    --no-defaults)   export DISTROMAC_NO_DEFAULTS=1 ;;
    --no-fonts)      export DISTROMAC_NO_FONTS=1 ;;
    --no-languages)  export DISTROMAC_NO_LANGUAGES=1 ;;
    --no-npm)        export DISTROMAC_NO_NPM=1 ;;
    --minimal)
      export DISTROMAC_NO_NVIM=1
      export DISTROMAC_NO_SKETCHYBAR=1
      export DISTROMAC_NO_AEROSPACE=1
      export DISTROMAC_NO_TMUX=1
      export DISTROMAC_NO_GHOSTTY=1
      export DISTROMAC_NO_BORDERS=1
      export DISTROMAC_NO_RAYCAST=1
      export DISTROMAC_NO_SPOTIFY=1
      export DISTROMAC_NO_DEFAULTS=1
      export DISTROMAC_NO_FONTS=1
      export DISTROMAC_NO_LANGUAGES=1
      export DISTROMAC_NO_NPM=1
      ;;
    --theme=*) export DISTROMAC_THEME="${arg#--theme=}" ;;
    *)
      echo "Unknown flag: $arg" >&2
      echo "Usage: ./install.sh [--no-<app>] [--theme=<name>] [--no-defaults] [--no-fonts] [--no-languages] [--no-npm] [--minimal]" >&2
      exit 1
      ;;
  esac
done

echo ""
echo "  ╔══════════════════════════════╗"
echo "  ║        d i s t r o m a c     ║"
echo "  ╚══════════════════════════════╝"
echo ""

# 0. Pre-install hook
distromac-hook pre-install || true

# 1. Preflight
source "$DISTROMAC_PATH/install/preflight/guard.sh"
source "$DISTROMAC_PATH/install/preflight/xcode.sh"
source "$DISTROMAC_PATH/install/preflight/homebrew.sh"

# 2. Packaging
source "$DISTROMAC_PATH/install/packaging/brews.sh"
source "$DISTROMAC_PATH/install/packaging/casks.sh"

if [[ ${DISTROMAC_NO_FONTS} != "1" ]]; then
  source "$DISTROMAC_PATH/install/packaging/fonts.sh"
fi

if [[ ${DISTROMAC_NO_LANGUAGES} != "1" ]]; then
  source "$DISTROMAC_PATH/install/packaging/languages.sh"
fi

if [[ ${DISTROMAC_NO_NPM} != "1" ]]; then
  source "$DISTROMAC_PATH/install/packaging/npm.sh"
fi

# 3. Config
source "$DISTROMAC_PATH/install/config/shell.sh"
source "$DISTROMAC_PATH/install/config/git.sh"
source "$DISTROMAC_PATH/install/config/dotfiles.sh"
source "$DISTROMAC_PATH/install/config/macos-defaults.sh"
source "$DISTROMAC_PATH/install/config/theme.sh"

# 4. Post-install
source "$DISTROMAC_PATH/install/post-install/cleanup.sh"

# 5. Post-install hook
distromac-hook post-install || true
