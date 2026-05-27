#!/usr/bin/env bash
# Stop hook — spine-writeback (ambient session writeback)
#
# Fires after every assistant turn in a plan-driven project. Does three
# things, in order, never interrupting Claude:
#
#   1. Heartbeat — appends a one-line entry to the active section plan
#      recording which files changed this turn. Does NOT advance the
#      PROGRESS pointer — that's `/done`'s job.
#   2. Cross-session-note capture (P3.4) — scans the most recent
#      assistant turn for forward-looking cue phrases and appends
#      candidates to a "## Pending cross-session notes" block in the
#      section file. `/done` reviews and either promotes or discards.
#   3. Long-session signal (P3.5) — once per session, when turn count
#      crosses 30 OR elapsed time crosses 2h, emits a one-line signal
#      suggesting the user split or push through. Single-fire guarded
#      by a marker under $TMPDIR.
#
# -e is intentionally not set; any parse failure exits 0 silently.

set -uo pipefail

# ---------- read input ----------

INPUT=$(cat 2>/dev/null || true)

CWD=""
SESSION_ID=""
TRANSCRIPT_PATH=""
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
  CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)
  TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)
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

# Heartbeat is gated on file changes; cue-capture and long-session aren't.
# Compute one shared timestamp for all three blocks.
TS=$(date '+%Y-%m-%d %H:%M' 2>/dev/null || echo "now")

# ---------- 1. Heartbeat (only when files changed) ----------

HEARTBEAT_FIRED=0

if [ -n "$CHANGED" ]; then
  NEW_LINE="- session ${SESSION} @ ${TS} — touched: ${CHANGED}"
  # Timestamp-stripped form for idempotency comparison
  NEW_LINE_BARE="- session ${SESSION} — touched: ${CHANGED}"

  SKIP_DUPLICATE=0
  if grep -q '^## Session log' "$SECTION_FILE" 2>/dev/null; then
    LAST_LINE=$(awk '
      /^## Session log/{flag=1; next}
      flag && /^- session /{last=$0}
      END{print last}
    ' "$SECTION_FILE" 2>/dev/null || true)
    LAST_BARE=$(echo "$LAST_LINE" | sed -E 's/ @ [0-9:-]+( [0-9:]+)? —/ —/' 2>/dev/null || true)
    if [ "$LAST_BARE" = "$NEW_LINE_BARE" ]; then
      SKIP_DUPLICATE=1
    fi
  fi

  if [ "$SKIP_DUPLICATE" -eq 0 ]; then
    if ! grep -q '^## Session log' "$SECTION_FILE" 2>/dev/null; then
      {
        printf '\n## Session log\n\n'
        printf 'Append-only. One heartbeat per assistant turn. `/done` rolls these up into a PROGRESS.md entry.\n\n'
      } >> "$SECTION_FILE" 2>/dev/null || true
    fi
    echo "$NEW_LINE" >> "$SECTION_FILE" 2>/dev/null || true
    HEARTBEAT_FIRED=1
  fi
fi

# ---------- 2. Cross-session-note capture (always, requires transcript) ----------

# Forward-looking cue patterns. Kept tight to bias against noise — better to
# under-capture than to flood the Pending block. `/done` reviews and promotes.
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ] && command -v jq >/dev/null 2>&1; then
  LAST_ASSISTANT_JSON=$(awk '/"type":"assistant"/{last=$0} END{print last}' "$TRANSCRIPT_PATH" 2>/dev/null || true)

  if [ -n "$LAST_ASSISTANT_JSON" ]; then
    LAST_ASSISTANT_TEXT=$(printf '%s' "$LAST_ASSISTANT_JSON" \
      | jq -r '(.message.content // []) | map(select(.type == "text") | .text) | join("\n")' 2>/dev/null \
      || true)

    if [ -n "$LAST_ASSISTANT_TEXT" ]; then
      CUES_RE='(cross.?session note|follow.?up:|for (the |a )?(next|later|future) session|FYI for next session|note for next session|need to .{0,80}(in|before) .{0,30}(next|later|future) session|schema (will need|needs to)|carry.?over:)'

      CANDIDATES=$(printf '%s' "$LAST_ASSISTANT_TEXT" \
        | grep -iE "$CUES_RE" 2>/dev/null \
        | head -n 5 \
        | sed -E 's/^[[:space:]]*[-*]?[[:space:]]*//; s/[[:space:]]+$//' \
        || true)

      if [ -n "$CANDIDATES" ]; then
        if ! grep -q '^## Pending cross-session notes' "$SECTION_FILE" 2>/dev/null; then
          {
            printf '\n## Pending cross-session notes\n\n'
            printf '_Auto-captured by `spine-writeback.sh` from cue phrases in assistant turns. `/done` reviews this list and either promotes entries to **Cross-session notes** above or discards them. Hook is append-only; never edits this block once written._\n\n'
          } >> "$SECTION_FILE" 2>/dev/null || true
        fi

        while IFS= read -r line; do
          [ -z "$line" ] && continue
          trimmed="${line:0:280}"
          if ! grep -qF -- "$trimmed" "$SECTION_FILE" 2>/dev/null; then
            echo "- (turn @ ${TS}) ${trimmed}" >> "$SECTION_FILE" 2>/dev/null || true
          fi
        done <<< "$CANDIDATES"
      fi
    fi
  fi
fi

# ---------- emit heartbeat stdout (deferred until after silent cue capture) ----------

if [ "$HEARTBEAT_FIRED" = "1" ]; then
  echo "spine: heartbeat → docs/plans/${SECTION}.md (session ${SESSION}; touched: ${CHANGED})"
fi

# ---------- 3. Long-session signal (single-fire per session_id) ----------

# State lives under $TMPDIR (ephemeral, not tracked in the repo). Each
# session_id gets three files: .turns (counter), .start (epoch), .long-session
# (marker that we've already signaled). The signal fires at >=30 turns OR
# >=2h elapsed, whichever first.
if [ -n "$SESSION_ID" ]; then
  SIGNAL_DIR="${TMPDIR:-/tmp}/spine-signals"
  mkdir -p "$SIGNAL_DIR" 2>/dev/null

  COUNTER_FILE="${SIGNAL_DIR}/${SESSION_ID}.turns"
  START_FILE="${SIGNAL_DIR}/${SESSION_ID}.start"
  LONG_MARKER="${SIGNAL_DIR}/${SESSION_ID}.long-session"

  CURRENT_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
  NEW_COUNT=$((CURRENT_COUNT + 1))
  echo "$NEW_COUNT" > "$COUNTER_FILE" 2>/dev/null || true

  if [ ! -f "$START_FILE" ]; then
    date '+%s' > "$START_FILE" 2>/dev/null || true
  fi

  if [ ! -f "$LONG_MARKER" ]; then
    LONG_FIRE=0
    ELAPSED_MIN=0

    if [ "$NEW_COUNT" -ge 30 ]; then
      LONG_FIRE=1
    fi

    START_EPOCH=$(cat "$START_FILE" 2>/dev/null || echo "")
    NOW_EPOCH=$(date '+%s' 2>/dev/null || echo "")
    if [ -n "$START_EPOCH" ] && [ -n "$NOW_EPOCH" ]; then
      ELAPSED_SEC=$((NOW_EPOCH - START_EPOCH))
      ELAPSED_MIN=$((ELAPSED_SEC / 60))
      if [ "$ELAPSED_SEC" -ge 7200 ]; then
        LONG_FIRE=1
      fi
    fi

    if [ "$LONG_FIRE" = "1" ]; then
      touch "$LONG_MARKER" 2>/dev/null || true
      echo "spine: past typical session size (${NEW_COUNT} turns, ${ELAPSED_MIN}m elapsed). split now or push? — see chapter 06 (feature sizing)."
    fi
  fi
fi

exit 0
