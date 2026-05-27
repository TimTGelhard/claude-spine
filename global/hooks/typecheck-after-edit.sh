#!/usr/bin/env bash
# PostToolUse hook — typecheck a file after Claude edits it.
#
# For .ts / .tsx: walks up from the edited file to find the nearest
# tsconfig.json, then runs `tsc --noEmit --incremental -p <tsconfig>` using a
# project-local tsc if available (node_modules/.bin/tsc) and falling back to a
# PATH-resolved tsc. Errors mentioning the edited file are surfaced on stderr;
# project-wide errors are suppressed (they predated the edit).
#
# For .py: runs `python -m py_compile <file>` (syntax-only — fast). mypy / ruff
# are not invoked here; the goal is "did the edit at least parse".
#
# Default-off. Wired into ~/.claude/settings.json only when the user opts in
# via `/onboard --deep` Section G (Automation), question G1. Ships from
# global/hooks/ so install.sh symlinks the script into ~/.claude/hooks/; the
# settings.json entry is the gate.
#
# Designed to NEVER block. -e is intentionally not set; any failure exits 0
# silently and lets the edit stand. The hook is advisory only — surfacing
# errors so Claude sees them in the next turn.

set -uo pipefail

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0

# find_up <start_dir> <marker_file> — print the nearest ancestor directory
# containing <marker_file>; return non-zero if none found before /.
find_up() {
  local dir="$1"
  local marker="$2"
  while [ "$dir" != "/" ] && [ "$dir" != "." ] && [ -n "$dir" ]; do
    if [ -f "$dir/$marker" ]; then
      printf '%s' "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

case "$FILE" in
  *.ts|*.tsx)
    TS_DIR=$(find_up "$(dirname "$FILE")" "tsconfig.json") || exit 0

    if [ -x "$TS_DIR/node_modules/.bin/tsc" ]; then
      TSC="$TS_DIR/node_modules/.bin/tsc"
    elif command -v tsc >/dev/null 2>&1; then
      TSC="tsc"
    else
      exit 0
    fi

    OUTPUT=$("$TSC" --noEmit --incremental -p "$TS_DIR/tsconfig.json" 2>&1 || true)
    # Surface only errors that mention the edited file. Project-wide noise
    # predated this edit; we don't want to make Claude debug pre-existing
    # state on every save.
    FILE_ERRORS=$(printf '%s\n' "$OUTPUT" | grep -F "$FILE" | grep "error TS" || true)
    if [ -n "$FILE_ERRORS" ]; then
      printf 'spine: typecheck errors in %s:\n%s\n' "$FILE" "$FILE_ERRORS" >&2
    fi
    ;;

  *.py)
    if command -v python3 >/dev/null 2>&1; then
      PY=python3
    elif command -v python >/dev/null 2>&1; then
      PY=python
    else
      exit 0
    fi

    PY_OUT=$("$PY" -m py_compile "$FILE" 2>&1) || {
      printf 'spine: python syntax error in %s:\n%s\n' "$FILE" "$PY_OUT" >&2
    }
    ;;
esac

exit 0
