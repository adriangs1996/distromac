#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_REPO="${DISTROMAC_REPO:-adriangs1996/distromac}"
DISTROMAC_BRANCH="${DISTROMAC_BRANCH:-main}"
export DISTROMAC_PATH="${HOME}/.distromac"

echo "Installing distromac..."

if [[ -d "$DISTROMAC_PATH" ]]; then
  echo "Updating existing installation..."
  cd "$DISTROMAC_PATH"
  git pull --rebase
else
  echo "Cloning distromac..."
  git clone -b "$DISTROMAC_BRANCH" "https://github.com/${DISTROMAC_REPO}.git" "$DISTROMAC_PATH"
fi

cd "$DISTROMAC_PATH"
exec bash install.sh "$@"
