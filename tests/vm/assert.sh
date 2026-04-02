#!/usr/bin/env bash
# assert.sh — Pure-bash assertion library for distromac VM tests.
# Source this file; do not execute directly.
# Failures do NOT abort — all tests run to completion.

ASSERT_PASS=0
ASSERT_FAIL=0

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

_pass() {
  local desc="$1"
  (( ASSERT_PASS++ ))
  printf '  [PASS] %s\n' "$desc"
}

_fail() {
  local desc="$1" expected="$2" got="$3"
  (( ASSERT_FAIL++ ))
  printf '  [FAIL] %s\n' "$desc"
  printf '         Expected: %s\n' "$expected"
  printf '         Got:      %s\n' "$got"
}

# ---------------------------------------------------------------------------
# Assertion functions
# ---------------------------------------------------------------------------

# assert_exit_0 <description> <cmd...>
# Command exits 0.
assert_exit_0() {
  local desc="$1"; shift
  local rc=0
  "$@" >/dev/null 2>&1 || rc=$?
  if [[ $rc -eq 0 ]]; then
    _pass "$desc"
  else
    _fail "$desc" "exit 0" "exit $rc"
  fi
}

# assert_exit_nonzero <description> <cmd...>
# Command exits != 0.
assert_exit_nonzero() {
  local desc="$1"; shift
  local rc=0
  "$@" >/dev/null 2>&1 || rc=$?
  if [[ $rc -ne 0 ]]; then
    _pass "$desc"
  else
    _fail "$desc" "non-zero exit" "exit 0"
  fi
}

# assert_file_exists <description> <path>
# File exists.
assert_file_exists() {
  local desc="$1" path="$2"
  if [[ -f "$path" ]]; then
    _pass "$desc"
  else
    _fail "$desc" "file exists: $path" "file not found"
  fi
}

# assert_file_missing <description> <path>
# File does NOT exist.
assert_file_missing() {
  local desc="$1" path="$2"
  if [[ ! -f "$path" ]]; then
    _pass "$desc"
  else
    _fail "$desc" "file missing: $path" "file exists"
  fi
}

# assert_dir_exists <description> <path>
# Directory exists.
assert_dir_exists() {
  local desc="$1" path="$2"
  if [[ -d "$path" ]]; then
    _pass "$desc"
  else
    _fail "$desc" "directory exists: $path" "directory not found"
  fi
}

# assert_contains <description> <string> <file>
# File contains string (literal match).
assert_contains() {
  local desc="$1" string="$2" file="$3"
  if grep -qF "$string" "$file" 2>/dev/null; then
    _pass "$desc"
  else
    _fail "$desc" "file contains: $string" "string not found in $file"
  fi
}

# assert_not_contains <description> <string> <file>
# File does NOT contain string (literal match).
assert_not_contains() {
  local desc="$1" string="$2" file="$3"
  if ! grep -qF "$string" "$file" 2>/dev/null; then
    _pass "$desc"
  else
    _fail "$desc" "file does not contain: $string" "string found in $file"
  fi
}

# assert_stdout_contains <description> <string> <cmd...>
# Command stdout contains string.
assert_stdout_contains() {
  local desc="$1" string="$2"; shift 2
  local output
  output=$("$@" 2>/dev/null) || true
  if printf '%s' "$output" | grep -qF "$string"; then
    _pass "$desc"
  else
    _fail "$desc" "stdout contains: $string" "stdout: $output"
  fi
}

# assert_eq <description> <expected> <actual>
# Exact string equality.
assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    _pass "$desc"
  else
    _fail "$desc" "$expected" "$actual"
  fi
}

# assert_files_equal <description> <file_a> <file_b>
# Identical file content.
assert_files_equal() {
  local desc="$1" file_a="$2" file_b="$3"
  if cmp -s "$file_a" "$file_b"; then
    _pass "$desc"
  else
    _fail "$desc" "$file_a == $file_b" "files differ"
  fi
}

# assert_match <description> <regex> <string>
# Regex match.
assert_match() {
  local desc="$1" regex="$2" string="$3"
  if [[ "$string" =~ $regex ]]; then
    _pass "$desc"
  else
    _fail "$desc" "match regex: $regex" "$string"
  fi
}
