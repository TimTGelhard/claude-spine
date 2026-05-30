#!/usr/bin/env bash
# Fixture for global/hooks/spine-writeback.sh
#
# Verifies the plan-layout resolution precedence added for FIXES A2.1:
#   1. Project-level CLAUDE.md `Plan layout:` line wins.
#   2. Profile field `- **Plans dir:**` is next.
#   3. The four built-in conventions are the fallback.
#   4. Malformed values at any level fall through to the next.
#
# Plus the A16.1 heartbeat behavior:
#   5. Heartbeats report the per-turn delta, not the whole dirty tree.
#   6. Cue-capture skips the hook's own `- (turn @ …)` Pending-entry lines.
#
# The hook reads stdin (Claude Code Stop event JSON), writes a heartbeat to
# the section file for files changed THIS turn, and emits a stdout line.
#
# Run from the repo root, or pass SPINE_DIR explicitly.

set -uo pipefail

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
HOOK="$SPINE_DIR/global/hooks/spine-writeback.sh"

if [ ! -x "$HOOK" ]; then
  echo "FAIL: hook not executable at $HOOK" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "FAIL: jq is required (the hook uses jq for input parsing)" >&2
  exit 1
fi
if ! command -v git >/dev/null 2>&1; then
  echo "FAIL: git is required" >&2
  exit 1
fi

# ---------- harness ----------

pass=0
fail=0

ok()    { echo "  PASS  $1"; pass=$((pass + 1)); }
notok() { echo "  FAIL  $1"; echo "        $2"; fail=$((fail + 1)); }

# Each case sets up its own throwaway repo + fake profile + fake project files,
# then runs the hook with a synthetic Stop-event input. The hook should write a
# heartbeat to whichever section file the layout resolved to — we assert on
# which one received the write.

make_repo() {
  local repo="$1"
  mkdir -p "$repo"
  (cd "$repo" && git init -q && git config user.email "t@t" && git config user.name "t")
  # Touch a non-plan file so git status reports a change for the heartbeat.
  echo "x" > "$repo/work.txt"
}

run_hook() {
  local repo="$1"
  local profile="$2"
  local sid="${3:-test}"
  local input
  input=$(jq -n --arg cwd "$repo" --arg sid "$sid" '{cwd:$cwd, session_id:$sid, transcript_path:""}')
  # Inject the test profile via HOME.
  local fake_home
  fake_home=$(mktemp -d)
  mkdir -p "$fake_home/.claude"
  if [ -n "$profile" ]; then
    cp "$profile" "$fake_home/.claude/claude-spine-profile.md"
  fi
  printf '%s' "$input" | HOME="$fake_home" bash "$HOOK" 2>/dev/null || true
  rm -rf "$fake_home"
}

# A16.1 made the heartbeat a per-turn delta: the first hook run in a session only
# baselines the working tree (no heartbeat); a later run reports what was dirtied
# since. The layout-resolution cases therefore run the hook twice under one
# session id — baseline, then a fresh change — and assert on the delta heartbeat.
run_hook_delta() {
  local repo="$1"
  local profile="$2"
  local sid="$3"
  run_hook "$repo" "$profile" "$sid"           # turn 1: baseline only
  echo "delta" > "$repo/.spine-delta-probe"     # a new file dirtied "this turn"
  run_hook "$repo" "$profile" "$sid"           # turn 2: emits the delta heartbeat
}

# A16.1 snapshots + long-session markers live under $TMPDIR/spine-signals keyed
# by session id. Use a per-run, per-case prefix so repeated suite runs (and the
# cases within one run) never read each other's stale snapshots.
SID_BASE="spinetest-$$"

# ---------- Case 1: built-in `docs/plans/` + `docs/PROGRESS.md` ----------

WORK1=$(mktemp -d)
trap 'rm -rf "$WORK1"' EXIT
REPO1="$WORK1/repo"
make_repo "$REPO1"
mkdir -p "$REPO1/docs/plans"
cat > "$REPO1/docs/PROGRESS.md" <<'EOF'
# Progress

- **Section**: `audit-01-architecture` (from `docs/PROJECT_PLAN.md`)
- **Session**: `1` — `Architectural integrity sweep`
EOF
echo "# audit-01-architecture" > "$REPO1/docs/plans/audit-01-architecture.md"

run_hook_delta "$REPO1" "" "${SID_BASE}-c1"

if grep -q '^- session 1 ' "$REPO1/docs/plans/audit-01-architecture.md"; then
  ok "Case 1: built-in docs/plans/ + docs/PROGRESS.md resolves correctly"
else
  notok "Case 1: built-in docs/plans/ + docs/PROGRESS.md resolves correctly" \
        "heartbeat did not land in docs/plans/audit-01-architecture.md"
fi

# ---------- Case 2: profile-set custom dir ----------

WORK2=$(mktemp -d -t spinetest2.XXXXXX)
REPO2="$WORK2/repo"
make_repo "$REPO2"
mkdir -p "$REPO2/roadmap"
cat > "$REPO2/STATUS.md" <<'EOF'
# Status

- **Section**: `phase-1` (from `docs/PROJECT_PLAN.md`)
- **Session**: `1` — `Initial setup`
EOF
echo "# phase-1" > "$REPO2/roadmap/phase-1.md"

# Profile points at the custom layout.
PROFILE2="$WORK2/profile.md"
cat > "$PROFILE2" <<'EOF'
# Claude Spine — Personal Profile

## Environment

- **OS:** macOS
- **Plans dir:** roadmap/ + STATUS.md
EOF

run_hook_delta "$REPO2" "$PROFILE2" "${SID_BASE}-c2"

if grep -q '^- session 1 ' "$REPO2/roadmap/phase-1.md"; then
  ok "Case 2: profile-set Plans dir resolves to custom roadmap/+STATUS.md"
else
  notok "Case 2: profile-set Plans dir resolves to custom roadmap/+STATUS.md" \
        "heartbeat did not land in roadmap/phase-1.md"
fi

rm -rf "$WORK2"

# ---------- Case 3: project override beats profile ----------

WORK3=$(mktemp -d -t spinetest3.XXXXXX)
REPO3="$WORK3/repo"
make_repo "$REPO3"
# Profile says one thing.
mkdir -p "$REPO3/wrong-plans"
cat > "$REPO3/wrong-progress.md" <<'EOF'
- **Section**: `should-not-fire` (from `docs/PROJECT_PLAN.md`)
- **Session**: `1` — `wrong`
EOF
echo "# should-not-fire" > "$REPO3/wrong-plans/should-not-fire.md"
# Project CLAUDE.md says another.
mkdir -p "$REPO3/right-plans"
cat > "$REPO3/right-progress.md" <<'EOF'
- **Section**: `correct` (from `docs/PROJECT_PLAN.md`)
- **Session**: `1` — `right`
EOF
echo "# correct" > "$REPO3/right-plans/correct.md"
cat > "$REPO3/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

Plan layout: right-plans/ right-progress.md
EOF

PROFILE3="$WORK3/profile.md"
cat > "$PROFILE3" <<'EOF'
## Environment

- **Plans dir:** wrong-plans/ + wrong-progress.md
EOF

run_hook_delta "$REPO3" "$PROFILE3" "${SID_BASE}-c3"

if grep -q '^- session 1 ' "$REPO3/right-plans/correct.md" \
   && ! grep -q '^- session 1 ' "$REPO3/wrong-plans/should-not-fire.md"; then
  ok "Case 3: project-level CLAUDE.md Plan layout: beats profile field"
else
  notok "Case 3: project-level CLAUDE.md Plan layout: beats profile field" \
        "heartbeat landed in the wrong section file (profile won when project should have)"
fi

rm -rf "$WORK3"

# ---------- Case 4: malformed profile falls through to built-in ----------

WORK4=$(mktemp -d -t spinetest4.XXXXXX)
REPO4="$WORK4/repo"
make_repo "$REPO4"
# Built-in layout exists.
mkdir -p "$REPO4/docs/plans"
cat > "$REPO4/docs/PROGRESS.md" <<'EOF'
- **Section**: `fallback` (from `docs/PROJECT_PLAN.md`)
- **Session**: `1` — `fallback to built-in`
EOF
echo "# fallback" > "$REPO4/docs/plans/fallback.md"

# Profile points at a non-existent path.
PROFILE4="$WORK4/profile.md"
cat > "$PROFILE4" <<'EOF'
## Environment

- **Plans dir:** does/not/exist/ + does-not-exist.md
EOF

run_hook_delta "$REPO4" "$PROFILE4" "${SID_BASE}-c4"

if grep -q '^- session 1 ' "$REPO4/docs/plans/fallback.md"; then
  ok "Case 4: malformed profile field falls through to built-in docs/plans/"
else
  notok "Case 4: malformed profile field falls through to built-in docs/plans/" \
        "heartbeat did not land in docs/plans/fallback.md — fallback chain broken"
fi

rm -rf "$WORK4"

# ---------- Case 5: unfilled profile marker is ignored ----------

WORK5=$(mktemp -d -t spinetest5.XXXXXX)
REPO5="$WORK5/repo"
make_repo "$REPO5"
mkdir -p "$REPO5/docs/plans"
cat > "$REPO5/docs/PROGRESS.md" <<'EOF'
- **Section**: `unfilled-test` (from `docs/PROJECT_PLAN.md`)
- **Session**: `1` — `ignore unfilled marker`
EOF
echo "# unfilled-test" > "$REPO5/docs/plans/unfilled-test.md"

PROFILE5="$WORK5/profile.md"
cat > "$PROFILE5" <<'EOF'
## Environment

- **Plans dir:** (unfilled — run /onboard --deep to capture)
EOF

run_hook_delta "$REPO5" "$PROFILE5" "${SID_BASE}-c5"

if grep -q '^- session 1 ' "$REPO5/docs/plans/unfilled-test.md"; then
  ok "Case 5: (unfilled) profile marker is ignored, built-in resolution applies"
else
  notok "Case 5: (unfilled) profile marker is ignored, built-in resolution applies" \
        "heartbeat did not land in docs/plans/unfilled-test.md"
fi

rm -rf "$WORK5"

# ---------- Case 6: heartbeat reports only the per-turn delta (A16.1) ----------

WORK6=$(mktemp -d -t spinetest6.XXXXXX)
REPO6="$WORK6/repo"
make_repo "$REPO6"   # pre-existing dirt: work.txt
mkdir -p "$REPO6/docs/plans"
cat > "$REPO6/docs/PROGRESS.md" <<'EOF'
- **Section**: `delta-test` (from `docs/PROJECT_PLAN.md`)
- **Session**: `1` — `per-turn delta`
EOF
echo "# delta-test" > "$REPO6/docs/plans/delta-test.md"
SECTION6="$REPO6/docs/plans/delta-test.md"

# Turn 1 only baselines the tree — pre-existing work.txt must NOT be logged.
run_hook "$REPO6" "" "${SID_BASE}-c6"
if grep -q '^- session 1 ' "$SECTION6"; then
  notok "Case 6a: first turn baselines without a heartbeat" \
        "a heartbeat was written for pre-existing dirt on the baseline turn"
else
  ok "Case 6a: first turn baselines the tree without a heartbeat"
fi

# Turn 2 dirties a NEW file — only it should appear in the heartbeat.
echo "new" > "$REPO6/feature.txt"
run_hook "$REPO6" "" "${SID_BASE}-c6"
LAST6=$(grep '^- session 1 ' "$SECTION6" | tail -n1)
if echo "$LAST6" | grep -q 'feature.txt' && ! echo "$LAST6" | grep -q 'work.txt'; then
  ok "Case 6b: heartbeat lists only the per-turn delta (feature.txt, not pre-existing work.txt)"
else
  notok "Case 6b: heartbeat lists only the per-turn delta" \
        "expected feature.txt and not work.txt in: '$LAST6'"
fi

rm -rf "$WORK6"

# ---------- Case 7: cue-capture skips the hook's own Pending-entry lines (A16.1) ----------

WORK7=$(mktemp -d -t spinetest7.XXXXXX)
REPO7="$WORK7/repo"
make_repo "$REPO7"
mkdir -p "$REPO7/docs/plans"
cat > "$REPO7/docs/PROGRESS.md" <<'EOF'
- **Section**: `cue-test` (from `docs/PROJECT_PLAN.md`)
- **Session**: `1` — `cue self-skip`
EOF
echo "# cue-test" > "$REPO7/docs/plans/cue-test.md"
SECTION7="$REPO7/docs/plans/cue-test.md"

# One assistant turn echoing (a) a line shaped like the hook's own Pending entry
# (leads with "- (turn @ …" — must be skipped) and (b) a genuine new cue line.
# The hook parses the transcript as JSONL (one compact object per line, via
# awk /"type":"assistant"/) — so the fixture MUST be compact (jq -c), not the
# pretty-printed default, or the awk record-grabber never matches.
TRANSCRIPT7="$WORK7/transcript.jsonl"
ASSISTANT_TEXT='- (turn @ 2026-01-01 00:00) follow-up: an already-captured note line
follow-up: a brand new thing to remember next session'
jq -c -n --arg t "$ASSISTANT_TEXT" \
  '{type:"assistant", message:{content:[{type:"text", text:$t}]}}' > "$TRANSCRIPT7"

INPUT7=$(jq -n --arg cwd "$REPO7" --arg sid "${SID_BASE}-c7" --arg tp "$TRANSCRIPT7" \
  '{cwd:$cwd, session_id:$sid, transcript_path:$tp}')
FAKE_HOME7=$(mktemp -d)
mkdir -p "$FAKE_HOME7/.claude"
printf '%s' "$INPUT7" | HOME="$FAKE_HOME7" bash "$HOOK" 2>/dev/null || true
rm -rf "$FAKE_HOME7"

if grep -q 'brand new thing to remember' "$SECTION7" \
   && ! grep -q 'already-captured note line' "$SECTION7"; then
  ok "Case 7: cue-capture keeps genuine cues and skips its own '- (turn @ …)' lines"
else
  notok "Case 7: cue-capture self-skip" \
        "expected the new cue captured and the '(turn @' line skipped"
fi

rm -rf "$WORK7"

# A16.1 snapshot/marker cleanup for this run.
rm -f "${TMPDIR:-/tmp}/spine-signals/${SID_BASE}-"* 2>/dev/null || true

# ---------- summary ----------

echo
echo "  $pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
