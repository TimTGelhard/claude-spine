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

# ---------- profile-overridable defaults ----------
#
# Thresholds and cue phrases can be overridden in
# ~/.claude/claude-spine-profile.md under `## Spine defaults`. Missing or
# malformed values fall back to the shipped defaults below.

PROFILE="${HOME}/.claude/claude-spine-profile.md"

spine_default_int() {
  local key="$1"
  local fallback="$2"
  if [ ! -f "$PROFILE" ]; then
    echo "$fallback"; return
  fi
  local val
  val=$(grep -E "^- \*\*${key}:\*\*" "$PROFILE" 2>/dev/null \
    | head -n1 \
    | sed -E "s/^- \*\*${key}:\*\*[[:space:]]*([0-9]+).*/\1/" \
    || true)
  if [[ "$val" =~ ^[0-9]+$ ]]; then echo "$val"; else echo "$fallback"; fi
}

LONG_TURNS=$(spine_default_int "Long-session turn threshold" 30)
LONG_SECS=$(spine_default_int "Long-session elapsed seconds" 7200)

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

# ---------- parse-error surface (N2) ----------
#
# If PROGRESS.md exists but SECTION/SESSION extraction failed, write a marker
# at $CWD/docs/.spine-parse-error. `/done` and `/spine` read it and surface a
# visible warning. On the next successful parse, the marker is removed.
#
# We distinguish two empty-extract cases:
#   • Template state — Section/Session bullets still hold `<section-name>` /
#     `<N>` placeholders. Silent exit (waiting for user to fill in).
#   • Format drift — the bullets have been edited but no longer match the
#     parser's expected shape (`- **Section**: \`<name>\``). Write the marker.

PARSE_ERROR_MARKER="$CWD/docs/.spine-parse-error"

HAS_TEMPLATE_PLACEHOLDERS=0
if grep -qE '\*\*Section\*\*:[^`]*`<[^>]+>`' "$PROGRESS" 2>/dev/null || \
   grep -qE '\*\*Session\*\*:[^`]*`<[^>]+>`' "$PROGRESS" 2>/dev/null; then
  HAS_TEMPLATE_PLACEHOLDERS=1
fi

if [ -z "$SECTION" ] || [ -z "$SESSION" ]; then
  if [ "$HAS_TEMPLATE_PLACEHOLDERS" -eq 0 ]; then
    {
      echo "spine-writeback could not parse $PROGRESS @ $(date '+%Y-%m-%d %H:%M:%S')"
      echo ""
      echo "Expected bullet shape (literal — see templates/PROGRESS.md):"
      echo "  - **Section**: \`<section-name>\` (from \`docs/PROJECT_PLAN.md\`)"
      echo "  - **Session**: \`<N>\` — \`<one-line goal>\`"
      echo ""
      [ -z "$SECTION" ] && echo "Missing: Section bullet — bold **Section**, colon, backtick-quoted name."
      [ -z "$SESSION" ] && echo "Missing: Session bullet — bold **Session**, colon, backtick-quoted N."
      echo ""
      echo "Until the bullets parse, the Stop hook silently no-ops:"
      echo "  - Per-turn heartbeats are NOT logged to the active section plan."
      echo "  - Cross-session-note capture is paused."
      echo "  - Long-session signaling is paused."
      echo ""
      echo "Fix the PROGRESS.md bullets (template at \`templates/PROGRESS.md\` shows the literal shape); this marker auto-clears on the next successful parse. This file is safe to ignore in git — it is runtime state, not source."
    } > "$PARSE_ERROR_MARKER" 2>/dev/null || true
  fi
  exit 0
fi

# Successful parse on real values — clear any stale marker.
[ -f "$PARSE_ERROR_MARKER" ] && rm -f "$PARSE_ERROR_MARKER" 2>/dev/null || true

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
      DEFAULT_CUES='cross.?session note|follow.?up:|for (the |a )?(next|later|future) session|FYI for next session|note for next session|need to .{0,80}(in|before) .{0,30}(next|later|future) session|schema (will need|needs to)|carry.?over:'

      # Append any user-supplied cue phrases from profile (one per bullet under
      # "Cross-session note cues:"; the help-text bullet starts with `- (` and is skipped).
      USER_CUES=""
      if [ -f "$PROFILE" ]; then
        USER_CUES=$(awk '
          /^- \*\*Cross-session note cues:\*\*/{flag=1; next}
          flag && /^- \*\*/{flag=0}
          flag && /^  - / && !/^  - \(/ {sub(/^  - /,""); print}
        ' "$PROFILE" 2>/dev/null | tr '\n' '|' | sed 's/|$//' || true)
      fi

      if [ -n "$USER_CUES" ]; then
        CUES_RE="(${DEFAULT_CUES}|${USER_CUES})"
      else
        CUES_RE="(${DEFAULT_CUES})"
      fi

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

    if [ "$NEW_COUNT" -ge "$LONG_TURNS" ]; then
      LONG_FIRE=1
    fi

    START_EPOCH=$(cat "$START_FILE" 2>/dev/null || echo "")
    NOW_EPOCH=$(date '+%s' 2>/dev/null || echo "")
    if [ -n "$START_EPOCH" ] && [ -n "$NOW_EPOCH" ]; then
      ELAPSED_SEC=$((NOW_EPOCH - START_EPOCH))
      ELAPSED_MIN=$((ELAPSED_SEC / 60))
      if [ "$ELAPSED_SEC" -ge "$LONG_SECS" ]; then
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
