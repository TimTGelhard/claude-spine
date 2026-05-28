#!/usr/bin/env bash
# Fixture for global/hooks/spine-writeback.sh
#
# Verifies the plan-layout resolution precedence added for FIXES A2.1:
#   1. Project-level CLAUDE.md `Plan layout:` line wins.
#   2. Profile field `- **Plans dir:**` is next.
#   3. The four built-in conventions are the fallback.
#   4. Malformed values at any level fall through to the next.
#
# The hook reads stdin (Claude Code Stop event JSON), writes a heartbeat to
# the section file if files changed, and emits a stdout line. We don't fake
# a transcript here — that path is exercised by manual testing — but the
# layout resolution is the FIXES A2.1 win, so that's what we cover.
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
  local input
  input=$(jq -n --arg cwd "$repo" --arg sid "test" '{cwd:$cwd, session_id:$sid, transcript_path:""}')
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

run_hook "$REPO1" ""

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

run_hook "$REPO2" "$PROFILE2"

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

run_hook "$REPO3" "$PROFILE3"

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

run_hook "$REPO4" "$PROFILE4"

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

run_hook "$REPO5" "$PROFILE5"

if grep -q '^- session 1 ' "$REPO5/docs/plans/unfilled-test.md"; then
  ok "Case 5: (unfilled) profile marker is ignored, built-in resolution applies"
else
  notok "Case 5: (unfilled) profile marker is ignored, built-in resolution applies" \
        "heartbeat did not land in docs/plans/unfilled-test.md"
fi

rm -rf "$WORK5"

# ---------- summary ----------

echo
echo "  $pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
