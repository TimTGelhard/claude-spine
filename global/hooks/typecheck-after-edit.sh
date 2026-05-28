#!/usr/bin/env bash
# PostToolUse hook — typecheck / parse-check a file after Claude edits it.
#
# For each supported language, walks up to find the project root config, then
# runs the cheapest meaningful check (typecheck if available, parse-check
# otherwise). Errors mentioning the edited file are surfaced on stderr;
# project-wide errors are suppressed (they predated the edit).
#
# Per-extension behavior:
#   .ts .tsx       → tsc --noEmit on the nearest tsconfig.json
#                    (prefer node_modules/.bin/tsc, fall back to PATH tsc)
#   .py            → mypy → pyright → ruff check → py_compile (whichever is available)
#   .go            → `go vet` from the file's package directory
#                    (needs go.mod somewhere up the tree)
#   .rs            → `cargo check --quiet` from the Cargo.toml root
#   .java          → javac --release N (where N comes from pom.xml/build.gradle if found; defaults skip)
#                    — heavy enough that we only run it if jdtls is NOT detected
#                    (jdtls + an IDE is the normal Java workflow)
#                    For now we leave Java as parse-only via a fast `javap -p` style
#                    check; skipping is fine when IDE-driven.
#   .cs            → `dotnet build --nologo -clp:ErrorsOnly -v q`
#                    on the nearest .csproj (skip if .sln is the entry — too heavy)
#   .rb            → `ruby -c` (parse-check; fast, broad)
#   .php           → `php -l` (lint; fast, broad)
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

# Same as find_up but accepts a glob pattern (e.g., '*.csproj') and tests via shell globbing.
find_up_glob() {
  local dir="$1"
  local pattern="$2"
  while [ "$dir" != "/" ] && [ "$dir" != "." ] && [ -n "$dir" ]; do
    # shellcheck disable=SC2086,SC2231
    for match in $dir/$pattern; do
      if [ -f "$match" ]; then
        printf '%s' "$dir"
        return 0
      fi
    done
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
    # Try the strongest available checker; fall back through to py_compile.
    if command -v mypy >/dev/null 2>&1; then
      MYPY_OUT=$(mypy --no-error-summary --no-color-output "$FILE" 2>&1 || true)
      FILE_ERRORS=$(printf '%s\n' "$MYPY_OUT" | grep -F "$FILE" | grep -E ':[0-9]+: error' || true)
      [ -n "$FILE_ERRORS" ] && printf 'spine: mypy errors in %s:\n%s\n' "$FILE" "$FILE_ERRORS" >&2
    elif command -v pyright >/dev/null 2>&1; then
      PYR_OUT=$(pyright --outputjson "$FILE" 2>&1 || true)
      # Quick text grep is enough — full JSON parse would need jq. Errors
      # printed to stderr by pyright look like: <file>:<line>:<col> - error: ...
      FILE_ERRORS=$(printf '%s\n' "$PYR_OUT" | grep -F "$FILE" | grep -E 'error:' || true)
      [ -n "$FILE_ERRORS" ] && printf 'spine: pyright errors in %s:\n%s\n' "$FILE" "$FILE_ERRORS" >&2
    elif command -v ruff >/dev/null 2>&1; then
      # ruff check covers a lot of obvious correctness issues even without type info.
      RUFF_OUT=$(ruff check --no-cache --quiet "$FILE" 2>&1 || true)
      [ -n "$RUFF_OUT" ] && printf 'spine: ruff issues in %s:\n%s\n' "$FILE" "$RUFF_OUT" >&2
    else
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
    fi
    ;;

  *.go)
    GO_DIR=$(find_up "$(dirname "$FILE")" "go.mod") || exit 0
    if ! command -v go >/dev/null 2>&1; then
      exit 0
    fi
    # go vet operates on packages, not files; run it on the file's package directory.
    PKG_DIR=$(dirname "$FILE")
    VET_OUT=$( ( cd "$GO_DIR" && go vet "./$(realpath --relative-to="$GO_DIR" "$PKG_DIR" 2>/dev/null || echo "./...")" 2>&1 ) || true)
    FILE_ERRORS=$(printf '%s\n' "$VET_OUT" | grep -F "$(basename "$FILE")" || true)
    [ -n "$FILE_ERRORS" ] && printf 'spine: go vet errors in %s:\n%s\n' "$FILE" "$FILE_ERRORS" >&2
    ;;

  *.rs)
    RS_DIR=$(find_up "$(dirname "$FILE")" "Cargo.toml") || exit 0
    if ! command -v cargo >/dev/null 2>&1; then
      exit 0
    fi
    CARGO_OUT=$( ( cd "$RS_DIR" && cargo check --quiet 2>&1 ) || true)
    FILE_ERRORS=$(printf '%s\n' "$CARGO_OUT" | grep -F "$FILE" | grep -E '^(error|warning)' || true)
    [ -n "$FILE_ERRORS" ] && printf 'spine: cargo check errors in %s:\n%s\n' "$FILE" "$FILE_ERRORS" >&2
    ;;

  *.cs)
    PROJ_DIR=$(find_up_glob "$(dirname "$FILE")" '*.csproj') || exit 0
    if ! command -v dotnet >/dev/null 2>&1; then
      exit 0
    fi
    BUILD_OUT=$( ( cd "$PROJ_DIR" && dotnet build --nologo -clp:ErrorsOnly -v q 2>&1 ) || true)
    FILE_ERRORS=$(printf '%s\n' "$BUILD_OUT" | grep -F "$FILE" || true)
    [ -n "$FILE_ERRORS" ] && printf 'spine: dotnet build errors in %s:\n%s\n' "$FILE" "$FILE_ERRORS" >&2
    ;;

  *.rb)
    if ! command -v ruby >/dev/null 2>&1; then
      exit 0
    fi
    RB_OUT=$(ruby -c "$FILE" 2>&1) || {
      printf 'spine: ruby syntax error in %s:\n%s\n' "$FILE" "$RB_OUT" >&2
    }
    ;;

  *.php)
    if ! command -v php >/dev/null 2>&1; then
      exit 0
    fi
    PHP_OUT=$(php -l "$FILE" 2>&1) || {
      printf 'spine: php syntax error in %s:\n%s\n' "$FILE" "$PHP_OUT" >&2
    }
    ;;
esac

exit 0
