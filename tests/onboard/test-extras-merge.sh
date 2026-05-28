#!/usr/bin/env bash
# Fixture for the settings-extras jq merge command used by
# skills/core/op-onboard/extras-merge.md.
#
# Verifies the merge behavior end-to-end without involving op-onboard itself —
# the merge is just a `jq` invocation, so we test it directly against a
# synthetic settings.json + the eight shipped fragments under
# global/settings-extras/.
#
# Cases:
#   - Happy path: merge +vcs-gitlab.json into a baseline settings.json
#   - Idempotent: re-merging the same fragment makes no further changes
#   - Missing-key resilience: settings.json without permissions.allow gets it
#     created via `// []`
#   - All eight fragments parse as valid JSON (regression guard)
#   - Two-fragment sequential merge: +vcs-gitlab + +docker-k8s preserved
#   - Malformed settings.json fails fast (non-zero exit)
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
EXTRAS_DIR="$SPINE_DIR/global/settings-extras"

if ! command -v jq >/dev/null 2>&1; then
  echo "FAIL: jq is required (the merge itself uses jq)" >&2
  exit 1
fi
if [ ! -d "$EXTRAS_DIR" ]; then
  echo "FAIL: settings-extras directory missing at $EXTRAS_DIR" >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# ---------- the merge under test ----------
# Same shape as the command embedded in op-onboard/extras-merge.md and
# global/settings-extras/README.md. Keep these in sync.
merge() {
  local settings="$1"
  local fragment="$2"
  local out="$3"
  # Explicit `|| return` per step — set -e does NOT propagate from functions
  # called inside `if` conditions (a known bash gotcha), so we have to be
  # explicit here.
  jq empty "$settings" >/dev/null 2>&1 || return 1
  jq empty "$fragment" >/dev/null 2>&1 || return 1
  jq -s '
    .[0] as $base
    | .[1] as $extra
    | $base
    | .permissions.allow    = ((.permissions.allow    // []) + ($extra.permissions.allow    // []) | unique)
    | .permissions.WebFetch = ((.permissions.WebFetch // []) + ($extra.permissions.WebFetch // []) | unique)
  ' "$settings" "$fragment" > "$out" 2>/dev/null || return 1
  jq empty "$out" >/dev/null 2>&1 || return 1
}

# ---------- harness ----------

pass=0
fail=0

ok()    { echo "  PASS  $1"; pass=$((pass + 1)); }
notok() { echo "  FAIL  $1"; echo "        $2"; fail=$((fail + 1)); }

# ---------- baseline settings ----------

BASELINE="$WORK/baseline.json"
cat > "$BASELINE" <<'EOF'
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(ls)",
      "Bash(gh pr view:*)"
    ],
    "WebFetch": [
      "domain:docs.python.org",
      "domain:github.com"
    ]
  },
  "model": "claude-opus-4-7",
  "enabledPlugins": {
    "skill-creator@claude-plugins-official": true
  }
}
EOF

# ---------- Case 1: happy-path merge ----------

OUT="$WORK/merged-gitlab.json"
if merge "$BASELINE" "$EXTRAS_DIR/+vcs-gitlab.json" "$OUT" 2>/dev/null; then
  # Original entries preserved
  if jq -e '.permissions.allow | index("Bash(git status)") != null' "$OUT" >/dev/null \
     && jq -e '.permissions.allow | index("Bash(gh pr view:*)") != null' "$OUT" >/dev/null; then
    ok "Case 1a: baseline allow entries preserved after gitlab merge"
  else
    notok "Case 1a: baseline allow entries preserved after gitlab merge" \
          "expected Bash(git status) and Bash(gh pr view:*) in output"
  fi
  # Fragment entries added
  if jq -e '.permissions.allow | index("Bash(glab mr view:*)") != null' "$OUT" >/dev/null \
     && jq -e '.permissions.WebFetch | index("domain:gitlab.com") != null' "$OUT" >/dev/null; then
    ok "Case 1b: gitlab fragment entries appear in merged output"
  else
    notok "Case 1b: gitlab fragment entries appear in merged output" \
          "expected Bash(glab mr view:*) and domain:gitlab.com in output"
  fi
  # Untouched top-level keys preserved
  if jq -e '.model == "claude-opus-4-7"' "$OUT" >/dev/null \
     && jq -e '.enabledPlugins["skill-creator@claude-plugins-official"] == true' "$OUT" >/dev/null; then
    ok "Case 1c: untouched top-level keys (model, enabledPlugins) preserved"
  else
    notok "Case 1c: untouched top-level keys (model, enabledPlugins) preserved" \
          "expected model + enabledPlugins from baseline in output"
  fi
else
  notok "Case 1: gitlab merge ran cleanly" "merge command returned non-zero"
fi

# ---------- Case 2: idempotency ----------

OUT2="$WORK/merged-gitlab-again.json"
if merge "$OUT" "$EXTRAS_DIR/+vcs-gitlab.json" "$OUT2" 2>/dev/null; then
  # The allow + WebFetch arrays should be identical after a second merge.
  if diff <(jq -S '.permissions.allow' "$OUT") <(jq -S '.permissions.allow' "$OUT2") >/dev/null \
     && diff <(jq -S '.permissions.WebFetch' "$OUT") <(jq -S '.permissions.WebFetch' "$OUT2") >/dev/null; then
    ok "Case 2: re-merging gitlab is idempotent (no duplicate entries)"
  else
    notok "Case 2: re-merging gitlab is idempotent (no duplicate entries)" \
          "allow or WebFetch arrays differ between first and second merge"
  fi
else
  notok "Case 2: idempotent re-merge ran cleanly" "merge command returned non-zero"
fi

# ---------- Case 3: missing-key resilience ----------

NOKEY="$WORK/no-allow-key.json"
cat > "$NOKEY" <<'EOF'
{
  "permissions": {
    "WebFetch": ["domain:docs.python.org"]
  }
}
EOF

OUT3="$WORK/merged-nokey.json"
if merge "$NOKEY" "$EXTRAS_DIR/+vcs-gitlab.json" "$OUT3" 2>/dev/null; then
  if jq -e '.permissions.allow | type == "array"' "$OUT3" >/dev/null \
     && jq -e '.permissions.allow | index("Bash(glab mr view:*)") != null' "$OUT3" >/dev/null; then
    ok "Case 3: missing permissions.allow created from // [] fallback"
  else
    notok "Case 3: missing permissions.allow created from // [] fallback" \
          "expected .permissions.allow array with glab entries to exist"
  fi
else
  notok "Case 3: merge against settings without permissions.allow" "merge returned non-zero"
fi

# ---------- Case 4: every shipped fragment parses ----------

frag_count=0
frag_failed=0
for frag in "$EXTRAS_DIR"/+*.json; do
  frag_count=$((frag_count + 1))
  if ! jq empty "$frag" >/dev/null 2>&1; then
    frag_failed=$((frag_failed + 1))
    echo "        invalid JSON: $frag"
  fi
done
if [ "$frag_failed" -eq 0 ] && [ "$frag_count" -ge 8 ]; then
  ok "Case 4: all $frag_count shipped fragments parse as valid JSON"
else
  notok "Case 4: every shipped fragment parses as valid JSON" \
        "parsed $((frag_count - frag_failed))/$frag_count (expected $frag_count, want at least 8)"
fi

# ---------- Case 5: two-fragment sequential merge ----------

OUT5A="$WORK/seq-1.json"
OUT5B="$WORK/seq-2.json"
if merge "$BASELINE" "$EXTRAS_DIR/+vcs-gitlab.json" "$OUT5A" 2>/dev/null \
   && merge "$OUT5A" "$EXTRAS_DIR/+docker-k8s-stack.json" "$OUT5B" 2>/dev/null; then
  if jq -e '.permissions.allow | index("Bash(glab mr view:*)") != null' "$OUT5B" >/dev/null \
     && jq -e '.permissions.allow | any(startswith("Bash(docker")) or (.permissions.allow | any(startswith("Bash(kubectl")))' "$OUT5B" >/dev/null; then
    ok "Case 5: two-fragment sequential merge preserves both fragments' entries"
  else
    notok "Case 5: two-fragment sequential merge preserves both fragments' entries" \
          "expected gitlab + docker/kubectl Bash entries in final output"
  fi
else
  notok "Case 5: two-fragment sequential merge" "one of the merges returned non-zero"
fi

# ---------- Case 6: malformed input fails fast ----------

BAD="$WORK/bad.json"
echo '{ this is not json' > "$BAD"
OUT6="$WORK/should-not-exist.json"
if merge "$BAD" "$EXTRAS_DIR/+vcs-gitlab.json" "$OUT6" 2>/dev/null; then
  notok "Case 6: malformed settings.json fails fast" \
        "merge returned 0 against invalid JSON — expected non-zero exit"
else
  ok "Case 6: malformed settings.json fails fast (jq empty rejects it)"
fi

# ---------- summary ----------

echo
echo "  $pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
