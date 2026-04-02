#!/usr/bin/env bash
set -eEo pipefail

# distromac VM test orchestrator
# Runs on the host Mac. Manages the full VM lifecycle.

# --- Configuration ---
DISTROMAC_TEST_IMAGE="${DISTROMAC_TEST_IMAGE:-ghcr.io/cirruslabs/macos-sequoia-base:latest}"
VM_NAME="${DISTROMAC_TEST_VM:-distromac-test-$$}"
SSH_USER="${DISTROMAC_TEST_SSH_USER:-admin}"
SSH_PASS="${DISTROMAC_TEST_SSH_PASS:-admin}"
TEST_FLAGS="${DISTROMAC_TEST_FLAGS:-}"
TEST_SUITE="${DISTROMAC_TEST_SUITE:-}"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

SSH_OPTS=(-o StrictHostKeyChecking=no -o ConnectTimeout=5 -o LogLevel=ERROR)

# --- Prerequisite checks ---
if ! command -v tart &>/dev/null; then
  echo "[ERROR] tart is not installed. Install with: brew install cirruslabs/cli/tart" >&2
  exit 2
fi

if ! command -v sshpass &>/dev/null; then
  echo "[ERROR] sshpass is not installed. Install with: brew install hudochenkov/sshpass/sshpass" >&2
  exit 2
fi

# --- Cleanup trap (always runs) ---
cleanup() {
  echo ""
  echo "[CLEANUP] Stopping and deleting VM: $VM_NAME"
  tart stop "$VM_NAME" 2>/dev/null || true
  tart delete "$VM_NAME" 2>/dev/null || true
}
trap cleanup EXIT

# --- Helper functions ---
vm_ssh() {
  sshpass -p "$SSH_PASS" ssh "${SSH_OPTS[@]}" "$SSH_USER@$vm_ip" "$@"
}

# --- 1. Clone VM ---
echo "[VM] Cloning image: $DISTROMAC_TEST_IMAGE → $VM_NAME"
if ! tart clone "$DISTROMAC_TEST_IMAGE" "$VM_NAME"; then
  echo "[ERROR] Failed to clone VM image. Try: tart pull $DISTROMAC_TEST_IMAGE" >&2
  echo "[ERROR] Also check available disk space." >&2
  exit 2
fi

# --- 2. Start VM (headless) ---
echo "[VM] Starting VM: $VM_NAME"
tart run "$VM_NAME" --no-graphics &
TART_PID=$!

# --- 3. Wait for SSH (120s timeout, 5s poll) ---
echo "[VM] Waiting for SSH availability..."
deadline=$((SECONDS + 120))
vm_ip=""
ssh_ready=false

while (( SECONDS < deadline )); do
  vm_ip=$(tart ip "$VM_NAME" 2>/dev/null || true)
  if [[ -n $vm_ip ]]; then
    if sshpass -p "$SSH_PASS" ssh "${SSH_OPTS[@]}" "$SSH_USER@$vm_ip" true 2>/dev/null; then
      echo "[VM] SSH ready at $vm_ip"
      ssh_ready=true
      break
    fi
  fi
  sleep 5
done

if [[ $ssh_ready != true ]]; then
  echo "[ERROR] SSH timeout after 120s. VM may still be booting." >&2
  exit 2
fi

# --- 4. Sync repo into VM ---
echo "[VM] Syncing repo into VM..."
sshpass -p "$SSH_PASS" rsync -az --exclude .git --exclude .claude --exclude .worktrees \
  -e "ssh ${SSH_OPTS[*]}" \
  "$REPO_ROOT/" "$SSH_USER@$vm_ip:~/distromac/"

# --- 5. Run test suite (30-min timeout) ---
echo "[VM] Running test suite..."
echo ""

set +e
timeout 1800 sshpass -p "$SSH_PASS" ssh "${SSH_OPTS[@]}" "$SSH_USER@$vm_ip" \
  "DISTROMAC_TEST_FLAGS='$TEST_FLAGS' DISTROMAC_TEST_SUITE='$TEST_SUITE' bash ~/distromac/tests/vm/suite.sh"
test_exit=$?
set -e

echo ""

# --- 6. Handle exit code ---
if (( test_exit == 124 )); then
  echo "[ERROR] Test suite timed out after 30 minutes." >&2
  exit 2
fi

if (( test_exit != 0 )); then
  echo "[RESULT] Tests failed (exit code: $test_exit)"
  exit 1
fi

echo "[RESULT] All tests passed."
exit 0
