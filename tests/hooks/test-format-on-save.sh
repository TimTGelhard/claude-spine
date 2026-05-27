#!/usr/bin/env bash
# Fixture for global/hooks/format-on-save.sh
#
# Verifies the formatter-routing logic without depending on real
# prettier / black / rustfmt installations. Formatters are mocked via PATH
# shims that touch a marker file on invocation; the test then asserts whether
# the marker exists.
#
# Cases:
#   - .ts in dir with package.json + node_modules/.bin/prettier shim
#       → local prettier shim invoked
#   - .ts in dir with package.json + global prettier shim only
#       → global prettier shim invoked
#   - .ts WITHOUT package.json in any ancestor
#       → no shim invoked
#   - .py in dir with pyproject.toml containing [tool.black] + black shim
#       → black shim invoked
#   - .py in dir with pyproject.toml WITHOUT [tool.black]
#       → no shim invoked (even when black is on PATH)
#   - .py in dir with [tool.black] but no black binary
#       → silent skip
#   - .go in dir with go.mod + gofmt shim
#       → gofmt shim invoked
#   - .rs in dir with Cargo.toml + rustfmt shim
#       → rustfmt shim invoked
#   - .xyz (unhandled extension)
#       → no shim invoked
#   - empty stdin / missing file_path / non-existent file
#       → silent

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
HOOK="$SPINE_DIR/global/hooks/format-on-save.sh"

if [ ! -x "$HOOK" ]; then
  echo "FAIL: hook not executable at $HOOK" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "FAIL: jq is required" >&2
  exit 1
fi

TMP_DIR=$(mktemp -d -t format-on-save-XXXXXX)
SHIM_DIR=$(mktemp -d -t format-shim-XXXXXX)
MARKER_DIR=$(mktemp -d -t format-marker-XXXXXX)
trap 'rm -rf "$TMP_DIR" "$SHIM_DIR" "$MARKER_DIR"' EXIT INT TERM

# ---------- shim helpers ----------

# make_shim <name> — write a marker-touching shim to $SHIM_DIR/<name>. When
# invoked, it records the call (the shim binary's basename) in MARKER_DIR.
make_shim() {
  local name="$1"
  cat > "$SHIM_DIR/$name" <<EOF
#!/usr/bin/env bash
touch "$MARKER_DIR/$name"
exit 0
EOF
  chmod +x "$SHIM_DIR/$name"
}

remove_shim() {
  rm -f "$SHIM_DIR/$1"
}

reset_markers() {
  rm -f "$MARKER_DIR"/*
}

# make_local_prettier_shim <pkg_dir> — write node_modules/.bin/prettier inside
# the given package directory. Touches MARKER_DIR/local-prettier when run.
make_local_prettier_shim() {
  local pkg_dir="$1"
  mkdir -p "$pkg_dir/node_modules/.bin"
  cat > "$pkg_dir/node_modules/.bin/prettier" <<EOF
#!/usr/bin/env bash
touch "$MARKER_DIR/local-prettier"
exit 0
EOF
  chmod +x "$pkg_dir/node_modules/.bin/prettier"
}

# ---------- project layouts ----------

# Project A — package.json + LOCAL prettier shim (node_modules/.bin)
PROJ_A="$TMP_DIR/proj-a"
mkdir -p "$PROJ_A/src"
echo '{}' > "$PROJ_A/package.json"
make_local_prettier_shim "$PROJ_A"
echo 'const x = 1;' > "$PROJ_A/src/foo.ts"

# Project B — package.json, NO local prettier (relies on global PATH shim)
PROJ_B="$TMP_DIR/proj-b"
mkdir -p "$PROJ_B/src"
echo '{}' > "$PROJ_B/package.json"
echo 'const x = 1;' > "$PROJ_B/src/foo.ts"

# Project C — no package.json anywhere up the tree
PROJ_C="$TMP_DIR/no-pkg"
mkdir -p "$PROJ_C"
echo 'const x = 1;' > "$PROJ_C/foo.ts"

# Project D — pyproject.toml WITH [tool.black]
PROJ_D="$TMP_DIR/py-black"
mkdir -p "$PROJ_D"
cat > "$PROJ_D/pyproject.toml" <<'EOF'
[tool.black]
line-length = 100
EOF
echo 'x = 1' > "$PROJ_D/foo.py"

# Project E — pyproject.toml WITHOUT [tool.black]
PROJ_E="$TMP_DIR/py-no-black"
mkdir -p "$PROJ_E"
cat > "$PROJ_E/pyproject.toml" <<'EOF'
[tool.poetry]
name = "demo"
EOF
echo 'x = 1' > "$PROJ_E/foo.py"

# Project F — go.mod
PROJ_F="$TMP_DIR/go-proj"
mkdir -p "$PROJ_F"
echo 'module demo' > "$PROJ_F/go.mod"
echo 'package main' > "$PROJ_F/main.go"

# Project G — Cargo.toml
PROJ_G="$TMP_DIR/rust-proj"
mkdir -p "$PROJ_G/src"
cat > "$PROJ_G/Cargo.toml" <<'EOF'
[package]
name = "demo"
EOF
echo 'fn main() {}' > "$PROJ_G/src/main.rs"

# Unhandled extension
echo 'plain text' > "$TMP_DIR/notes.xyz"

# ---------- harness ----------

pass=0
fail=0

run_hook() {
  local file="$1"
  local input
  input=$(jq -n --arg p "$file" '{tool_input: {file_path: $p}}')
  PATH="$SHIM_DIR:$PATH" "$HOOK" <<<"$input" 2>&1
}

# expect_marker <name> <file> <marker_name>
expect_marker() {
  local name="$1" file="$2" marker="$3"
  reset_markers
  local out
  out=$(run_hook "$file")
  if [ -f "$MARKER_DIR/$marker" ]; then
    if [ -z "$out" ]; then
      echo "  PASS  $name"
      pass=$((pass + 1))
    else
      echo "  FAIL  $name (marker present but hook produced output)"
      echo "        out: $(printf '%s' "$out" | tr '\n' ' ')"
      fail=$((fail + 1))
    fi
  else
    echo "  FAIL  $name (expected marker $marker not created)"
    echo "        present markers: $(ls "$MARKER_DIR" 2>/dev/null | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# expect_no_marker <name> <file> — runs hook, asserts NO markers exist after.
expect_no_marker() {
  local name="$1" file="$2"
  reset_markers
  local out
  out=$(run_hook "$file")
  local found
  found=$(ls "$MARKER_DIR" 2>/dev/null | tr '\n' ' ')
  if [ -z "$found" ] && [ -z "$out" ]; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        expected: no markers, no output"
    echo "        markers:  $found"
    echo "        out:      $(printf '%s' "$out" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

expect_silent_raw() {
  local name="$1" input="$2"
  reset_markers
  local out
  out=$(PATH="$SHIM_DIR:$PATH" "$HOOK" <<<"$input" 2>&1)
  local found
  found=$(ls "$MARKER_DIR" 2>/dev/null | tr '\n' ' ')
  if [ -z "$found" ] && [ -z "$out" ]; then
    echo "  PASS  $name"
    pass=$((pass + 1))
  else
    echo "  FAIL  $name"
    echo "        markers: $found"
    echo "        out:     $(printf '%s' "$out" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# ---------- cases ----------

echo "format-on-save.sh fixture"
echo "  hook:     $HOOK"
echo "  tmpdir:   $TMP_DIR"
echo "  shimdir:  $SHIM_DIR"
echo "  markers:  $MARKER_DIR"
echo

# .ts → local prettier wins over global.
make_shim prettier   # global also present, but local should be preferred
expect_marker        ".ts uses local prettier"          "$PROJ_A/src/foo.ts"     "local-prettier"

# .ts → global prettier (no local).
expect_marker        ".ts falls back to global prettier" "$PROJ_B/src/foo.ts"     "prettier"

# .ts → no package.json anywhere → silent.
expect_no_marker     ".ts without package.json: silent"  "$PROJ_C/foo.ts"

# .py with [tool.black] + black shim → black runs.
make_shim black
expect_marker        ".py with [tool.black] + black shim" "$PROJ_D/foo.py"        "black"

# .py without [tool.black] → silent (even though black shim still present).
expect_no_marker     ".py without [tool.black]: silent"  "$PROJ_E/foo.py"

# .py with [tool.black] but no black binary → silent.
remove_shim black
expect_no_marker     ".py with [tool.black] but no black: silent"  "$PROJ_D/foo.py"

# .go with go.mod + gofmt shim → gofmt runs.
make_shim gofmt
expect_marker        ".go with go.mod + gofmt shim"     "$PROJ_F/main.go"        "gofmt"

# .rs with Cargo.toml + rustfmt shim → rustfmt runs.
make_shim rustfmt
expect_marker        ".rs with Cargo.toml + rustfmt shim" "$PROJ_G/src/main.rs"  "rustfmt"

# Unhandled extension → silent.
expect_no_marker     ".xyz: silent"                     "$TMP_DIR/notes.xyz"

# Edge cases.
expect_silent_raw    "empty stdin"                      ""
expect_silent_raw    "no file_path in input"            "$(jq -n '{tool_input: {}}')"
expect_silent_raw    "file_path missing on disk"        "$(jq -n --arg p "$TMP_DIR/does-not-exist.ts" '{tool_input: {file_path: $p}}')"

echo
echo "  total: $((pass + fail))  pass: $pass  fail: $fail"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
