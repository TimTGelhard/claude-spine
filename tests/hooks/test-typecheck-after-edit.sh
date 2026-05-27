#!/usr/bin/env bash
# Fixture for global/hooks/typecheck-after-edit.sh
#
# Sets up a throwaway project tree, runs the hook with various stdin inputs,
# and verifies:
#   - .ts with project tsconfig + a mocked tsc that prints a file-specific
#     error  →  stderr contains "spine: typecheck errors in"
#   - .ts with project tsconfig + a mocked tsc that prints only project-wide
#     errors (not mentioning the edited file)  →  silent
#   - .ts with project tsconfig but no tsc available  →  silent
#   - .ts with no tsconfig anywhere up the tree  →  silent
#   - .py with a syntax error  →  stderr contains "spine: python syntax error"
#   - .py that parses cleanly  →  silent
#   - .md file  →  silent (extension not handled)
#   - empty stdin  →  silent
#   - stdin without file_path  →  silent
#   - file_path pointing at a non-existent file  →  silent
#
# tsc is mocked via a PATH shim so the test doesn't require TypeScript to be
# installed. python3 must be available (it is on macOS by default).

set -uo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
  link_target="$(readlink "$SCRIPT_PATH")"
  case "$link_target" in
    /*) SCRIPT_PATH="$link_target" ;;
    *) SCRIPT_PATH="$(dirname "$SCRIPT_PATH")/$link_target" ;;
  esac
done
SPINE_DIR="${SPINE_DIR:-$(cd "$(dirname "$SCRIPT_PATH")/../.." && pwd -P)}"
HOOK="$SPINE_DIR/global/hooks/typecheck-after-edit.sh"

if [ ! -x "$HOOK" ]; then
  echo "FAIL: hook not executable at $HOOK" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "FAIL: jq is required (the hook uses jq)" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
  echo "FAIL: python or python3 is required" >&2
  exit 1
fi

TMP_DIR=$(mktemp -d -t typecheck-after-edit-XXXXXX)
SHIM_DIR=$(mktemp -d -t typecheck-shim-XXXXXX)
trap 'rm -rf "$TMP_DIR" "$SHIM_DIR"' EXIT INT TERM

# ---------- project layout ----------

# Project A: has tsconfig.json. We mock `tsc` per-test by rewriting the shim.
PROJ_A="$TMP_DIR/proj-a"
mkdir -p "$PROJ_A/src"
echo '{"compilerOptions":{}}' > "$PROJ_A/tsconfig.json"
echo 'export const x: number = 1;' > "$PROJ_A/src/clean.ts"
echo 'export const x: string = 1;' > "$PROJ_A/src/broken.ts"

# Project B: no tsconfig in any ancestor (lives directly in tmp root, no
# tsconfig at $TMP_DIR or above). find_up walks up to /, no tsconfig.
PROJ_B="$TMP_DIR/no-tsconfig"
mkdir -p "$PROJ_B"
echo 'export const x = 1;' > "$PROJ_B/foo.ts"

# Python fixtures.
echo 'x = 1' > "$TMP_DIR/clean.py"
echo 'x = (1' > "$TMP_DIR/broken.py"

# Markdown — extension not handled.
echo '# hello' > "$TMP_DIR/note.md"

# ---------- tsc shim ----------

# install_tsc_shim <mode> — write a fake `tsc` to $SHIM_DIR that behaves
# according to <mode>:
#   absent             — remove the shim (simulate "no tsc available")
#   file-error <abs>   — emit a TS error line mentioning <abs> on stderr,
#                        exit 1 (tsc returns non-zero on errors)
#   project-error <abs>— emit a TS error mentioning a DIFFERENT file, exit 1
install_tsc_shim() {
  case "$1" in
    absent)
      rm -f "$SHIM_DIR/tsc"
      ;;
    file-error)
      cat > "$SHIM_DIR/tsc" <<EOF
#!/usr/bin/env bash
printf '%s(1,7): error TS2322: Type number is not assignable to type string.\\n' "$2" >&2
exit 1
EOF
      chmod +x "$SHIM_DIR/tsc"
      ;;
    project-error)
      cat > "$SHIM_DIR/tsc" <<EOF
#!/usr/bin/env bash
printf 'some/other/file.ts(3,5): error TS2304: Cannot find name foo.\\n' >&2
exit 1
EOF
      chmod +x "$SHIM_DIR/tsc"
      ;;
    clean)
      cat > "$SHIM_DIR/tsc" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
      chmod +x "$SHIM_DIR/tsc"
      ;;
  esac
}

# ---------- harness ----------

pass=0
fail=0

# run_hook <file_path> — feed the hook a PostToolUse-shaped input and return
# the captured stderr on stdout (so callers can grep it). Discards hook stdout.
run_hook() {
  local file="$1"
  local input
  input=$(jq -n --arg p "$file" '{tool_input: {file_path: $p}}')
  PATH="$SHIM_DIR:$PATH" "$HOOK" <<<"$input" 2>&1 >/dev/null
}

# expect_stderr_contains <name> <file> <needle>
expect_stderr_contains() {
  local name="$1" file="$2" needle="$3"
  local out
  out=$(run_hook "$file")
  if printf '%s' "$out" | grep -qF "$needle"; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        file:     $file"
    echo "        needle:   $needle"
    echo "        stderr:   $(printf '%s' "$out" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# expect_silent <name> <file>
expect_silent() {
  local name="$1" file="$2"
  local out
  out=$(run_hook "$file")
  if [ -z "$out" ]; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        file:     $file"
    echo "        expected: empty stderr"
    echo "        stderr:   $(printf '%s' "$out" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# expect_silent_raw <name> <input-json>
expect_silent_raw() {
  local name="$1" input="$2"
  local out
  out=$(PATH="$SHIM_DIR:$PATH" "$HOOK" <<<"$input" 2>&1 >/dev/null)
  if [ -z "$out" ]; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        input:    $input"
    echo "        expected: empty stderr"
    echo "        stderr:   $(printf '%s' "$out" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# ---------- cases ----------

echo "typecheck-after-edit.sh fixture"
echo "  hook:    $HOOK"
echo "  tmpdir:  $TMP_DIR"
echo "  shimdir: $SHIM_DIR"
echo

# TypeScript — file-specific error surfaces.
install_tsc_shim file-error "$PROJ_A/src/broken.ts"
expect_stderr_contains "TS error mentioning edited file"  "$PROJ_A/src/broken.ts"  "spine: typecheck errors in"

# TypeScript — project-wide error (not mentioning edited file) stays silent.
install_tsc_shim project-error "$PROJ_A/src/clean.ts"
expect_silent          "TS error in other file is suppressed"  "$PROJ_A/src/clean.ts"

# TypeScript — clean tsc → silent.
install_tsc_shim clean
expect_silent          "TS clean run"                     "$PROJ_A/src/clean.ts"

# TypeScript — no tsc on PATH → silent.
install_tsc_shim absent
expect_silent          "TS with no tsc available"         "$PROJ_A/src/clean.ts"

# TypeScript — no tsconfig in any ancestor → silent (no shim consulted).
install_tsc_shim absent
expect_silent          "TS with no tsconfig in tree"      "$PROJ_B/foo.ts"

# Python — syntax error.
expect_stderr_contains "Python syntax error"              "$TMP_DIR/broken.py"  "spine: python syntax error"

# Python — clean parse.
expect_silent          "Python clean parse"               "$TMP_DIR/clean.py"

# Unhandled extension.
expect_silent          ".md is ignored"                   "$TMP_DIR/note.md"

# Edge cases on input.
expect_silent_raw      "empty stdin"                      ""
expect_silent_raw      "no file_path in input"            "$(jq -n '{tool_input: {}}')"
expect_silent_raw      "file_path missing on disk"        "$(jq -n --arg p "$TMP_DIR/does-not-exist.ts" '{tool_input: {file_path: $p}}')"

echo
echo "  total: $((pass + fail))  pass: $pass  fail: $fail"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
