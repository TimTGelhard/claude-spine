#!/usr/bin/env bash
# Notification hook — surface Claude's notification events as desktop alerts.
#
# Fires on Claude Code's Notification event, which triggers when Claude wants
# the user's attention (waiting for a permission prompt, idle while expecting
# input, long-running task finished with a message). Default-on because the
# downside is mild (one extra desktop ping) and the upside is real: you can
# context-switch away from the terminal and still know when Claude needs you.
#
# Designed to NEVER block Claude. -e is intentionally not set; any failure
# exits 0 silently.

set -uo pipefail

INPUT=$(cat 2>/dev/null || true)

MSG=""
TITLE="Claude Code"
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
  MSG=$(echo "$INPUT" | jq -r '.message // empty' 2>/dev/null || true)
  CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
  if [ -n "$CWD" ]; then
    PROJECT_NAME=$(basename "$CWD" 2>/dev/null || true)
    [ -n "$PROJECT_NAME" ] && TITLE="Claude Code — $PROJECT_NAME"
  fi
fi
[ -z "$MSG" ] && MSG="Claude is waiting for you."

# macOS desktop notification via osascript.
if command -v osascript >/dev/null 2>&1; then
  ESCAPED_MSG=$(printf '%s' "$MSG" | sed 's/\\/\\\\/g; s/"/\\"/g')
  ESCAPED_TITLE=$(printf '%s' "$TITLE" | sed 's/\\/\\\\/g; s/"/\\"/g')
  osascript -e "display notification \"$ESCAPED_MSG\" with title \"$ESCAPED_TITLE\"" >/dev/null 2>&1 || true
# Linux desktop notification via notify-send.
elif command -v notify-send >/dev/null 2>&1; then
  notify-send "$TITLE" "$MSG" >/dev/null 2>&1 || true
fi

# Terminal bell — cross-platform fallback so even SSH sessions get a ping.
printf '\a' 2>/dev/null || true

exit 0
