#!/usr/bin/env bash
# Fixture for global/hooks/block-env-commit.sh
#
# Sets up a throwaway git repo, stages various files, and feeds the hook the
# Claude Code PreToolUse input shape (JSON on stdin) to verify:
#   - `git commit` with a staged .env file produces a deny decision
#   - other commands or other staged files produce no deny output
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
HOOK="$SPINE_DIR/global/hooks/block-env-commit.sh"

if [ ! -x "$HOOK" ]; then
  echo "FAIL: hook not executable at $HOOK" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "FAIL: jq is required (the hook itself uses jq)" >&2
  exit 1
fi
if ! command -v git >/dev/null 2>&1; then
  echo "FAIL: git is required" >&2
  exit 1
fi

# ---------- throwaway git repo ----------

TMP_DIR=$(mktemp -d -t block-env-commit-XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

(
  cd "$TMP_DIR"
  git init -q
  git config user.email "test@example.com"
  git config user.name "Test"
  # One non-env tracked file so `git reset` has something to reset against.
  echo "seed" > seed.txt
  git add seed.txt
  git commit -q -m "seed"
)

# ---------- harness ----------

pass=0
fail=0

# stage_file <relative-path> <content>
# Creates and force-stages a file (force is needed for .env so a host-level
# .gitignore doesn't filter it out).
stage_file() {
  local path="$1"
  local content="${2:-content}"
  local dir
  dir="$(dirname "$path")"
  (
    cd "$TMP_DIR"
    [ "$dir" != "." ] && mkdir -p "$dir"
    printf '%s\n' "$content" > "$path"
    git add -f "$path"
  )
}

reset_index() {
  (cd "$TMP_DIR" && git reset -q HEAD)
}

# expect_deny <name> <cmd> [staged_file...]
expect_deny() {
  local name="$1"; shift
  local cmd="$1"; shift
  reset_index
  for f in "$@"; do stage_file "$f" "FOO=bar"; done

  local input output decision
  input="$(jq -n --arg c "$cmd" --arg dir "$TMP_DIR" '{tool_input: {command: $c}, cwd: $dir}')"
  output="$(printf '%s' "$input" | "$HOOK" 2>/dev/null || true)"
  decision="$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null || true)"
  if [ "$decision" = "deny" ]; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        cmd:      $cmd"
    echo "        staged:   $*"
    echo "        expected: permissionDecision=deny"
    echo "        got:      $(printf '%s' "$output" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# expect_allow <name> <cmd> [staged_file...]
expect_allow() {
  local name="$1"; shift
  local cmd="$1"; shift
  reset_index
  for f in "$@"; do stage_file "$f" "ok"; done

  local input output
  input="$(jq -n --arg c "$cmd" --arg dir "$TMP_DIR" '{tool_input: {command: $c}, cwd: $dir}')"
  output="$(printf '%s' "$input" | "$HOOK" 2>/dev/null || true)"
  if [ -z "$output" ]; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        cmd:      $cmd"
    echo "        staged:   $*"
    echo "        expected: empty output (hook stays silent)"
    echo "        got:      $(printf '%s' "$output" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# ---------- cases ----------

echo "block-env-commit.sh fixture"
echo "  hook: $HOOK"
echo "  tmp:  $TMP_DIR"
echo

# Should block.
expect_deny  "staged bare .env"            "git commit -m oops"  ".env"
expect_deny  ".env.local staged"           "git commit -m oops"  ".env.local"
expect_deny  ".env.production staged"      "git commit -m oops"  ".env.production"
expect_deny  "subdir .env.local staged"    "git commit -m oops"  "foo/.env.local"
expect_deny  "commit -am with .env staged" "git commit -am oops" ".env"
expect_deny  "multi-flag commit -v -m"     "git commit -v -m x"  ".env"

# Should allow.
expect_allow "regular file staged"         "git commit -m ok"    "file.txt"
expect_allow "no staged files"             "git commit -m empty"
expect_allow "not a commit subcommand"     "git status"          ".env"
expect_allow "git log mentioning commit"   "git log --grep=commit"  ".env"
expect_allow "filename containing .env"    "git commit -m ok"    "foo.env.template"
expect_allow "empty command"               ""                    ".env"

echo
echo "  total: $((pass + fail))  pass: $pass  fail: $fail"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
