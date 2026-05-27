#!/usr/bin/env bash
# Smoke test for install.sh --dry-run
#
# Runs install.sh with --dry-run against an isolated temporary HOME so the
# script's section headers and per-step output can be grep-asserted without
# touching the user's real ~/.claude.
#
# The dry-run path is short-circuited by the script's `run()` helper — no
# files are mutated even on the temp HOME. We're testing the output contract,
# not side effects.

set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
  link_target="$(readlink "$SCRIPT_PATH")"
  case "$link_target" in
    /*) SCRIPT_PATH="$link_target" ;;
    *) SCRIPT_PATH="$(dirname "$SCRIPT_PATH")/$link_target" ;;
  esac
done
SPINE_DIR="${SPINE_DIR:-$(cd "$(dirname "$SCRIPT_PATH")/../.." && pwd -P)}"
INSTALL="$SPINE_DIR/install.sh"

if [ ! -x "$INSTALL" ]; then
  echo "FAIL: install.sh not executable at $INSTALL" >&2
  exit 1
fi

TMP_HOME="$(mktemp -d)"
cleanup() { rm -rf "$TMP_HOME"; }
trap cleanup EXIT INT TERM

pass=0
fail=0

# run_install <scenario> [flags...]
# Captures stdout+stderr to a per-scenario log file.
run_install() {
  local scenario="$1"; shift
  local log="$TMP_HOME/$scenario.log"
  HOME="$TMP_HOME" "$INSTALL" --dry-run "$@" >"$log" 2>&1
  printf '%s' "$log"
}

# assert_contains <log> <test name> <substring>
# `--` after flags is required because BSD grep on macOS parses leading `--`
# in the pattern as a flag (e.g. `--dry-run`, `--keep-legacy`).
assert_contains() {
  local log="$1"; local name="$2"; local needle="$3"
  if grep -qF -- "$needle" "$log"; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        expected substring: $needle"
    echo "        log: $log"
    fail=$((fail + 1))
  fi
}

# assert_not_contains <log> <test name> <substring>
assert_not_contains() {
  local log="$1"; local name="$2"; local needle="$3"
  if grep -qF -- "$needle" "$log"; then
    echo "  FAIL  $name"
    echo "        forbidden substring present: $needle"
    echo "        log: $log"
    fail=$((fail + 1))
  else
    echo "  PASS  $name"
    pass=$((pass + 1))
  fi
}

echo "install.sh --dry-run fixture"
echo "  spine:    $SPINE_DIR"
echo "  tmp HOME: $TMP_HOME"
echo

# ---------- scenario 1: default install on a clean HOME ----------

echo "scenario 1: default --dry-run (clean HOME)"
log="$(run_install default)"
assert_contains "$log" "DRY RUN banner"            "DRY RUN — no changes will be made."
assert_contains "$log" "spine root reported"       "Spine root:    $SPINE_DIR"
assert_contains "$log" "claude-spine symlink step" "==> ensuring ~/.claude-spine resolves to the spine clone"
assert_contains "$log" "core skills step"          "==> linking core skills into"
assert_contains "$log" "slash commands step"       "==> linking slash commands into"
assert_contains "$log" "neutral global step"       "==> installing global CLAUDE.md (neutral variant)"
assert_contains "$log" "settings.json step"        "==> installing settings.json"
assert_contains "$log" "env-leak hook step"        "==> installing env-leak hook"
assert_contains "$log" "summary done"              "==> done."
# Clean HOME has no legacy skills, so the cleanup section must NOT print.
assert_not_contains "$log" "no legacy cleanup on clean HOME" "==> removing legacy op-manual-* skills"
# Sanity: every shipped core skill should appear in the link plan.
for skill in op-add-skill op-anti-patterns op-brownfield op-bucket-router \
             op-collaboration-modes op-curate op-foundations op-hooks \
             op-onboard op-persistence op-prompting op-recovery op-signaling \
             op-subagents op-suggest op-tools op-visuals op-workflow; do
  assert_contains "$log" "links $skill" "/skills/$skill"
done
echo

# ---------- scenario 2: --opinionated swaps the global variant ----------

echo "scenario 2: --opinionated"
log="$(run_install opinionated --opinionated)"
assert_contains    "$log" "opinionated banner"   "==> installing global CLAUDE.md (opinionated variant)"
assert_not_contains "$log" "no neutral banner"   "==> installing global CLAUDE.md (neutral variant)"
echo

# ---------- scenario 3: legacy cleanup actually fires when legacy dirs exist ----------

echo "scenario 3: legacy op-manual-* cleanup branch"
mkdir -p "$TMP_HOME/.claude/skills/op-manual-workflow"
mkdir -p "$TMP_HOME/.claude/skills/op-manual-tactics"
log="$(run_install with-legacy)"
assert_contains "$log" "cleanup banner"            "==> removing legacy op-manual-* skills (superseded by spine's op-*)"
assert_contains "$log" "would remove workflow"     "removed: $TMP_HOME/.claude/skills/op-manual-workflow"
assert_contains "$log" "would remove tactics"      "removed: $TMP_HOME/.claude/skills/op-manual-tactics"
assert_contains "$log" "keep-legacy opt-out hint"  "pass --keep-legacy to opt out"
# Make sure dry-run didn't actually rm the directories.
if [ -d "$TMP_HOME/.claude/skills/op-manual-workflow" ]; then
  echo "  PASS  legacy dir preserved by --dry-run"
  pass=$((pass + 1))
else
  echo "  FAIL  legacy dir disappeared during --dry-run"
  fail=$((fail + 1))
fi
echo

# ---------- scenario 4: --keep-legacy short-circuits the cleanup ----------

echo "scenario 4: --keep-legacy"
log="$(run_install keep-legacy --keep-legacy)"
assert_contains    "$log" "keep-legacy notice"     "==> --keep-legacy: leaving any op-manual-* skills in place"
assert_not_contains "$log" "no cleanup banner"     "==> removing legacy op-manual-* skills"
echo

# ---------- scenario 5: --skip-* flags short-circuit their sections ----------

echo "scenario 5: --skip-* flags"
log="$(run_install skip-skills --skip-skills)"
assert_contains    "$log" "skip-skills notice"     "==> skipping skill symlinks (--skip-skills)"
assert_not_contains "$log" "no link section"       "==> linking core skills into"

log="$(run_install skip-commands --skip-commands)"
assert_contains "$log" "skip-commands notice"      "==> skipping slash commands (--skip-commands)"

log="$(run_install skip-global --skip-global)"
assert_contains "$log" "skip-global notice"        "==> skipping global CLAUDE.md (--skip-global)"

log="$(run_install skip-settings --skip-settings)"
assert_contains "$log" "skip-settings notice"      "==> skipping settings.json (--skip-settings)"

log="$(run_install skip-hook --skip-hook)"
assert_contains "$log" "skip-hook notice"          "==> skipping env-leak hook (--skip-hook)"
echo

# ---------- scenario 6: --help exits 0 and prints usage ----------

echo "scenario 6: --help"
help_log="$TMP_HOME/help.log"
HOME="$TMP_HOME" "$INSTALL" --help >"$help_log" 2>&1
assert_contains "$help_log" "help mentions Usage"      "Usage:"
assert_contains "$help_log" "help mentions --dry-run"  "--dry-run"
assert_contains "$help_log" "help mentions --keep-legacy" "--keep-legacy"
echo

# ---------- scenario 7: unknown flag fails ----------

echo "scenario 7: unknown flag rejected"
if HOME="$TMP_HOME" "$INSTALL" --bogus-flag --dry-run >"$TMP_HOME/bogus.log" 2>&1; then
  echo "  FAIL  unknown flag should have exited non-zero"
  fail=$((fail + 1))
else
  echo "  PASS  unknown flag exits non-zero"
  pass=$((pass + 1))
fi
assert_contains "$TMP_HOME/bogus.log" "rejection message" "unknown flag:"
echo

# ---------- summary ----------

echo "  total: $((pass + fail))  pass: $pass  fail: $fail"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
