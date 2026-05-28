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
# Neutral default ships NO op-stack-flavor skill — no banner, no link target.
assert_not_contains "$log" "no flavor banner (neutral)"  "==> linking stack-flavor skill into"
assert_not_contains "$log" "no flavor target (neutral)"  "global/stacks/ts-next-supabase/flavor-skill"
assert_not_contains "$log" "no python flavor target"     "global/stacks/python-django/flavor-skill"
assert_contains "$log" "settings.json step"        "==> installing settings.json"
assert_contains "$log" "hooks step"                 "==> installing hooks"
assert_contains "$log" "summary done"              "==> claude-spine is installed."
assert_contains "$log" "next-step block present"   "Type  /onboard"
# Clean HOME has no legacy skills, so the cleanup section must NOT print.
assert_not_contains "$log" "no legacy cleanup on clean HOME" "==> removing legacy op-manual-* skills"
# Sanity: every shipped core skill should appear in the link plan.
for skill in op-add-skill op-anti-patterns op-brownfield op-bucket-router \
             op-collaboration-modes op-curate op-curate-nudge op-foundations \
             op-hooks op-onboard op-persistence op-prepare op-prompting \
             op-recovery op-signaling op-spine-active op-subagents op-suggest \
             op-tools op-visuals op-welcome op-workflow; do
  assert_contains "$log" "links $skill" "/skills/$skill"
done
echo

# ---------- scenario 2: --opinionated (backward-compat alias for --stack=ts-next-supabase) ----------

echo "scenario 2: --opinionated"
log="$(run_install opinionated --opinionated)"
assert_contains    "$log" "opinionated → stack banner"   "==> installing global CLAUDE.md (stack:ts-next-supabase variant)"
assert_not_contains "$log" "no neutral banner"            "==> installing global CLAUDE.md (neutral variant)"
# Stack-flavor skill should be wired alongside the CLAUDE.md.
assert_contains    "$log" "ts-flavor section banner"     "==> linking stack-flavor skill into ~/.claude/skills/op-stack-flavor"
assert_contains    "$log" "ts-flavor link target"        "global/stacks/ts-next-supabase/flavor-skill"
# Summary line should call out the +1 stack skill.
assert_contains    "$log" "summary mentions stack skill" "22 universal op-* skills + 1 stack-flavor skill"
echo

# ---------- scenario 2b: --stack=python-django routes to the python sibling ----------

echo "scenario 2b: --stack=python-django"
log="$(run_install stack-python --stack=python-django)"
assert_contains    "$log" "stack:python-django banner"   "==> installing global CLAUDE.md (stack:python-django variant)"
assert_not_contains "$log" "no neutral banner"            "==> installing global CLAUDE.md (neutral variant)"
# Stack-flavor skill should now point at the python flavor.
assert_contains    "$log" "py-flavor section banner"     "==> linking stack-flavor skill into ~/.claude/skills/op-stack-flavor"
assert_contains    "$log" "py-flavor link target"        "global/stacks/python-django/flavor-skill"
# And NOT at the TS flavor.
assert_not_contains "$log" "no ts flavor target"         "global/stacks/ts-next-supabase/flavor-skill"
echo

# ---------- scenario 2c: --stack=<nonexistent> exits non-zero with a listing ----------

echo "scenario 2c: --stack=nonexistent rejected"
if /Users/macbook/claude-spine/install.sh --dry-run --stack=does-not-exist >/dev/null 2>err.tmp; then
  echo "  FAIL  unknown stack should exit non-zero"
  fail=$((fail + 1))
else
  echo "  PASS  unknown stack exits non-zero"
  pass=$((pass + 1))
fi
if grep -q "Available stacks:" err.tmp; then
  echo "  PASS  rejection message lists available stacks"
  pass=$((pass + 1))
else
  echo "  FAIL  rejection should list available stacks"
  fail=$((fail + 1))
fi
rm -f err.tmp
echo

# ---------- scenario 2d: --stack=<name> with a CLAUDE.md.template but no flavor-skill is rejected ----------

# The pair is mandatory: install.sh refuses an unpaired stack. We simulate one
# by creating a temp stack dir with only the template, no flavor-skill. To do
# that without writing into the spine, we work against a synthetic SPINE_DIR
# Sandbox built under TMP_HOME. (BSD `mktemp -d` plays nicely on macOS.)

echo "scenario 2d: --stack=<paired-but-missing-flavor-skill> rejected"
fake_spine="$TMP_HOME/fake-spine"
mkdir -p "$fake_spine/global/stacks/lonely/"
echo "# placeholder template" > "$fake_spine/global/stacks/lonely/CLAUDE.md.template"
# Run install.sh from inside the fake spine root so SCRIPT_PATH resolves there.
# (install.sh derives SPINE_DIR from its own location, so we copy it in.)
cp "$INSTALL" "$fake_spine/install.sh"
chmod +x "$fake_spine/install.sh"
# Also copy global/neutral so other steps don't crash before reaching the
# validation check we care about.
mkdir -p "$fake_spine/global/neutral"
echo "# neutral placeholder" > "$fake_spine/global/neutral/CLAUDE.md.template"
if HOME="$TMP_HOME" "$fake_spine/install.sh" --dry-run --stack=lonely --skip-hook \
    >"$TMP_HOME/lonely.log" 2>&1; then
  echo "  FAIL  unpaired stack should exit non-zero"
  fail=$((fail + 1))
else
  echo "  PASS  unpaired stack exits non-zero"
  pass=$((pass + 1))
fi
assert_contains "$TMP_HOME/lonely.log" "rejection names flavor-skill" \
  "has no flavor skill at global/stacks/lonely/flavor-skill/SKILL.md"
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

# --skip-skills + --stack=<name> should also skip the op-stack-flavor link.
log="$(run_install skip-skills-with-stack --skip-skills --stack=ts-next-supabase)"
assert_contains    "$log" "skip-skills + stack notice"    "==> skipping skill symlinks (--skip-skills)"
assert_not_contains "$log" "no stack-flavor link"         "==> linking stack-flavor skill into"
# The stack-flavored CLAUDE.md still gets installed (--skip-skills doesn't
# disable that — only --skip-global would).
assert_contains    "$log" "stack CLAUDE.md still wires"   "==> installing global CLAUDE.md (stack:ts-next-supabase variant)"

log="$(run_install skip-commands --skip-commands)"
assert_contains "$log" "skip-commands notice"      "==> skipping slash commands (--skip-commands)"

log="$(run_install skip-global --skip-global)"
assert_contains "$log" "skip-global notice"        "==> skipping global CLAUDE.md (--skip-global)"

log="$(run_install skip-settings --skip-settings)"
assert_contains "$log" "skip-settings notice"      "==> skipping settings.json (--skip-settings)"

log="$(run_install skip-hook --skip-hook)"
assert_contains "$log" "skip-hook notice"          "==> skipping hooks (--skip-hook)"
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
