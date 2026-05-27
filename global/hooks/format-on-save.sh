#!/usr/bin/env bash
# PostToolUse hook — auto-format a file after Claude edits it.
#
# Detects the formatter from the project's config files (walking up from the
# edited file), then runs it against the single edited file. Silent skip if no
# formatter is configured for the file type, or if the formatter binary isn't
# available — the goal is "if the project formats this stack, keep style
# consistent on each edit", not "force a style on every project".
#
# Detection map:
#   .ts .tsx .js .jsx .json .md .css .scss .html .yaml .yml → prettier
#     (requires nearest package.json AND a prettier binary: prefer
#      node_modules/.bin/prettier, fall back to PATH-resolved prettier)
#   .py                                                     → black
#     (requires nearest pyproject.toml with a [tool.black] section AND a
#      PATH-resolved black; otherwise skip — black is not zero-config)
#   .go                                                     → gofmt
#     (requires nearest go.mod AND a PATH-resolved gofmt)
#   .rs                                                     → rustfmt
#     (requires nearest Cargo.toml AND a PATH-resolved rustfmt)
#
# Default-off. Wired into ~/.claude/settings.json only when the user opts in
# via `/onboard --deep` Section G (Automation), question G2.
#
# Designed to NEVER block. Formatter failures are swallowed; exit 0 always.

set -uo pipefail

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0

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

DIR=$(dirname "$FILE")

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.md|*.css|*.scss|*.html|*.yaml|*.yml)
    PKG_DIR=$(find_up "$DIR" "package.json") || exit 0
    if [ -x "$PKG_DIR/node_modules/.bin/prettier" ]; then
      "$PKG_DIR/node_modules/.bin/prettier" --write "$FILE" >/dev/null 2>&1 || true
    elif command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE" >/dev/null 2>&1 || true
    fi
    ;;

  *.py)
    PY_DIR=$(find_up "$DIR" "pyproject.toml") || exit 0
    if ! grep -q '^\[tool\.black\]' "$PY_DIR/pyproject.toml" 2>/dev/null; then
      exit 0
    fi
    if command -v black >/dev/null 2>&1; then
      black --quiet "$FILE" >/dev/null 2>&1 || true
    fi
    ;;

  *.go)
    find_up "$DIR" "go.mod" >/dev/null || exit 0
    if command -v gofmt >/dev/null 2>&1; then
      gofmt -w "$FILE" >/dev/null 2>&1 || true
    fi
    ;;

  *.rs)
    find_up "$DIR" "Cargo.toml" >/dev/null || exit 0
    if command -v rustfmt >/dev/null 2>&1; then
      rustfmt "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
