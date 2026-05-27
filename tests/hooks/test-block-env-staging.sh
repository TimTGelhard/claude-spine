#!/usr/bin/env bash
# Fixture for global/hooks/block-env-staging.sh
#
# Feeds the Claude Code PreToolUse hook input format (JSON on stdin) and
# asserts:
#   - `git add` commands that name a .env file produce a deny decision
#   - other commands produce no deny output
#
# Run from the repo root, or pass SPINE_DIR explicitly.

set -euo pipefail

# ---------- resolve repo root ----------

SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
  link_target="$(readlink "$SCRIPT_PATH")"
  case "$link_target" in
    /*) SCRIPT_PATH="$link_target" ;;
    *) SCRIPT_PATH="$(dirname "$SCRIPT_PATH")/$link_target" ;;
  esac
done
SPINE_DIR="${SPINE_DIR:-$(cd "$(dirname "$SCRIPT_PATH")/../.." && pwd -P)}"
HOOK="$SPINE_DIR/global/hooks/block-env-staging.sh"

if [ ! -x "$HOOK" ]; then
  echo "FAIL: hook not executable at $HOOK" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "FAIL: jq is required (the hook itself uses jq)" >&2
  exit 1
fi

# ---------- harness ----------

pass=0
fail=0

# expect_deny "<test name>" "<command>"
expect_deny() {
  local name="$1"
  local cmd="$2"
  local input output decision
  input="$(jq -n --arg c "$cmd" '{tool_input: {command: $c}}')"
  output="$(printf '%s' "$input" | "$HOOK" 2>/dev/null || true)"
  decision="$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null || true)"
  if [ "$decision" = "deny" ]; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        command:  $cmd"
    echo "        expected: permissionDecision=deny"
    echo "        got:      $(printf '%s' "$output" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# expect_allow "<test name>" "<command>"
expect_allow() {
  local name="$1"
  local cmd="$2"
  local input output
  input="$(jq -n --arg c "$cmd" '{tool_input: {command: $c}}')"
  output="$(printf '%s' "$input" | "$HOOK" 2>/dev/null || true)"
  if [ -z "$output" ]; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        command:  $cmd"
    echo "        expected: empty output (hook stays silent)"
    echo "        got:      $(printf '%s' "$output" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# ---------- cases ----------

echo "block-env-staging.sh fixture"
echo "  hook: $HOOK"
echo

# Should block.
expect_deny  "bare .env"                      "git add .env"
expect_deny  ".env.local"                     "git add .env.local"
expect_deny  ".env.production"                "git add .env.production"
expect_deny  "subdir .env.local"              "git add foo/.env.local"
expect_deny  "git add -A on env file"         "git add -A .env.staging"
expect_deny  "explicit ./.env path"           "git add ./.env"

# Should allow.
expect_allow "plain text file"                "git add file.txt"
expect_allow "git add ."                      "git add ."
expect_allow "git add -A (no env arg)"        "git add -A"
expect_allow "non-env file with .env in name" "git add foo.env.template"
expect_allow "git status"                     "git status"
expect_allow "missing command field"          ""

echo
echo "  total: $((pass + fail))  pass: $pass  fail: $fail"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
