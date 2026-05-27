#!/usr/bin/env bash
# Stop hook — spine-writeback (ambient session writeback)
#
# Fires after every assistant turn in a plan-driven project. Appends a
# one-line heartbeat to the active section plan recording which files
# changed this turn. Does NOT advance the PROGRESS pointer — that's the
# job of the explicit /done command, which rolls heartbeats up into a
# proper session-log entry.
#
# Designed to NEVER interrupt Claude. -e is intentionally not set; any
# parse failure exits 0 silently.

set -uo pipefail

# ---------- read input ----------

INPUT=$(cat 2>/dev/null || true)

CWD=""
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
  CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
fi
[ -z "$CWD" ] && CWD="$PWD"

# ---------- preflight: is this a plan-driven project? ----------

[ -d "$CWD/docs/plans" ] || exit 0
[ -f "$CWD/docs/PROGRESS.md" ] || exit 0

PROGRESS="$CWD/docs/PROGRESS.md"

# ---------- parse active section + session from PROGRESS.md ----------

# Expected template lines:
#   - **Section**: `<section-name>` (from `docs/PROJECT_PLAN.md`)
#   - **Session**: `<N>` — `<one-line goal>`
# First backtick-quoted token on each line is the value.

SECTION=$(grep -E '^\s*-?\s*\*\*Section\*\*:' "$PROGRESS" 2>/dev/null \
  | head -n1 \
  | sed -E 's/^[^`]*`([^`]+)`.*/\1/' \
  | tr -d '\n' || true)

SESSION=$(grep -E '^\s*-?\s*\*\*Session\*\*:' "$PROGRESS" 2>/dev/null \
  | head -n1 \
  | sed -E 's/^[^`]*`([^`]+)`.*/\1/' \
  | tr -d '\n' || true)

[ -z "$SECTION" ] && exit 0
[ -z "$SESSION" ] && exit 0

# Template placeholders (e.g. `<section-name>`) — surface nothing, exit.
case "$SECTION" in *"<"*">"*) exit 0 ;; esac
case "$SESSION" in *"<"*">"*) exit 0 ;; esac

SECTION_FILE="$CWD/docs/plans/${SECTION}.md"
[ -f "$SECTION_FILE" ] || exit 0

# ---------- compute changed files this turn ----------

CHANGED=""
if command -v git >/dev/null 2>&1 && [ -d "$CWD/.git" ]; then
  CHANGED=$(cd "$CWD" && git status --porcelain 2>/dev/null \
    | awk '{print $NF}' \
    | grep -Ev '^docs/plans/' \
    | grep -Ev '^docs/PROGRESS\.md$' \
    | head -n 8 \
    | tr '\n' ' ' \
    | sed -E 's/[[:space:]]+$//' || true)
fi

# Nothing changed outside the doc layer → no heartbeat. Silent exit.
[ -z "$CHANGED" ] && exit 0

# ---------- compose heartbeat ----------

TS=$(date '+%Y-%m-%d %H:%M' 2>/dev/null || echo "now")
NEW_LINE="- session ${SESSION} @ ${TS} — touched: ${CHANGED}"
# Timestamp-stripped form for idempotency comparison
NEW_LINE_BARE="- session ${SESSION} — touched: ${CHANGED}"

# ---------- idempotency: skip if last heartbeat matches (sans timestamp) ----------

if grep -q '^## Session log' "$SECTION_FILE" 2>/dev/null; then
  LAST_LINE=$(awk '
    /^## Session log/{flag=1; next}
    flag && /^- session /{last=$0}
    END{print last}
  ' "$SECTION_FILE" 2>/dev/null || true)
  LAST_BARE=$(echo "$LAST_LINE" | sed -E 's/ @ [0-9:-]+( [0-9:]+)? —/ —/' 2>/dev/null || true)
  if [ "$LAST_BARE" = "$NEW_LINE_BARE" ]; then
    exit 0
  fi
fi

# ---------- append heartbeat ----------

if ! grep -q '^## Session log' "$SECTION_FILE" 2>/dev/null; then
  {
    printf '\n## Session log\n\n'
    printf 'Append-only. One heartbeat per assistant turn. `/done` rolls these up into a PROGRESS.md entry.\n\n'
  } >> "$SECTION_FILE" 2>/dev/null || true
fi

echo "$NEW_LINE" >> "$SECTION_FILE" 2>/dev/null || true

# ---------- output one-line note (Claude Code surfaces stdout to user) ----------

echo "spine: heartbeat → docs/plans/${SECTION}.md (session ${SESSION}; touched: ${CHANGED})"

exit 0
