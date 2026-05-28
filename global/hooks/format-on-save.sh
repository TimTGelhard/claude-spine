#!/usr/bin/env bash
# PostToolUse hook — auto-format a file after Claude edits it.
#
# Detects the formatter from the project's config files (walking up from the
# edited file), then runs it against the single edited file. Silent skip if no
# formatter is configured for the file type, or if the formatter binary isn't
# available — the goal is "if the project formats this stack, keep style
# consistent on each edit", not "force a style on every project".
#
# Detection map (extension → formatter):
#   .ts .tsx .js .jsx .json .md .css .scss .html .yaml .yml → prettier (needs package.json + prettier bin)
#   .py                                                     → black (needs pyproject.toml with [tool.black])
#   .go                                                     → gofmt (needs go.mod)
#   .rs                                                     → rustfmt (needs Cargo.toml)
#   .rb                                                     → rubocop --autocorrect or standardrb (needs Gemfile + .rubocop.yml or standard.yml)
#   .php                                                    → php-cs-fixer (needs composer.json + .php-cs-fixer config) or laravel/pint
#   .java                                                   → google-java-format (PATH-resolved binary, only if user has it)
#   .kt .kts                                                → ktlint (PATH-resolved, only if user has it)
#   .swift                                                  → swiftformat (PATH-resolved, only if user has it)
#   .cs                                                     → dotnet format (needs .csproj/.sln nearby + dotnet on PATH)
#   .sh .bash                                               → shfmt (PATH-resolved, only if user has it)
#   .ex .exs                                                → mix format (needs mix.exs)
#   .lua                                                    → stylua (needs stylua.toml or .stylua.toml)
#   .c .cc .cpp .h .hpp .m .mm                              → clang-format (needs .clang-format)
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
    if grep -q '^\[tool\.black\]' "$PY_DIR/pyproject.toml" 2>/dev/null && command -v black >/dev/null 2>&1; then
      black --quiet "$FILE" >/dev/null 2>&1 || true
    elif grep -q '^\[tool\.ruff' "$PY_DIR/pyproject.toml" 2>/dev/null && command -v ruff >/dev/null 2>&1; then
      ruff format "$FILE" >/dev/null 2>&1 || true
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

  *.rb)
    find_up "$DIR" "Gemfile" >/dev/null || exit 0
    if find_up "$DIR" ".rubocop.yml" >/dev/null 2>&1 && command -v rubocop >/dev/null 2>&1; then
      rubocop --autocorrect --force-exclusion --no-color "$FILE" >/dev/null 2>&1 || true
    elif find_up "$DIR" ".standard.yml" >/dev/null 2>&1 && command -v standardrb >/dev/null 2>&1; then
      standardrb --fix "$FILE" >/dev/null 2>&1 || true
    fi
    ;;

  *.php)
    find_up "$DIR" "composer.json" >/dev/null || exit 0
    if find_up "$DIR" ".php-cs-fixer.dist.php" >/dev/null 2>&1 || find_up "$DIR" ".php-cs-fixer.php" >/dev/null 2>&1; then
      if command -v php-cs-fixer >/dev/null 2>&1; then
        php-cs-fixer fix "$FILE" --quiet >/dev/null 2>&1 || true
      fi
    elif find_up "$DIR" "pint.json" >/dev/null 2>&1 && command -v pint >/dev/null 2>&1; then
      pint "$FILE" --quiet >/dev/null 2>&1 || true
    fi
    ;;

  *.java)
    # google-java-format is the most-portable choice. Project-integrated
    # formatters (spotless via gradle / maven) require a build invocation
    # which is too heavy for a per-edit hook.
    if command -v google-java-format >/dev/null 2>&1; then
      google-java-format --replace "$FILE" >/dev/null 2>&1 || true
    fi
    ;;

  *.kt|*.kts)
    if command -v ktlint >/dev/null 2>&1; then
      ktlint --format --quiet "$FILE" >/dev/null 2>&1 || true
    fi
    ;;

  *.swift)
    if command -v swiftformat >/dev/null 2>&1; then
      swiftformat "$FILE" --quiet >/dev/null 2>&1 || true
    fi
    ;;

  *.cs)
    # dotnet format scopes to a project — find the nearest .csproj or .sln.
    PROJ_DIR=$(find_up_glob "$DIR" '*.csproj') || PROJ_DIR=$(find_up_glob "$DIR" '*.sln') || exit 0
    if command -v dotnet >/dev/null 2>&1; then
      ( cd "$PROJ_DIR" && dotnet format --include "$FILE" --no-restore --verbosity quiet >/dev/null 2>&1 ) || true
    fi
    ;;

  *.sh|*.bash)
    if command -v shfmt >/dev/null 2>&1; then
      shfmt -w "$FILE" >/dev/null 2>&1 || true
    fi
    ;;

  *.ex|*.exs)
    find_up "$DIR" "mix.exs" >/dev/null || exit 0
    if command -v mix >/dev/null 2>&1; then
      ( cd "$(find_up "$DIR" "mix.exs")" && mix format "$FILE" >/dev/null 2>&1 ) || true
    fi
    ;;

  *.lua)
    ( find_up "$DIR" "stylua.toml" >/dev/null || find_up "$DIR" ".stylua.toml" >/dev/null ) || exit 0
    if command -v stylua >/dev/null 2>&1; then
      stylua "$FILE" >/dev/null 2>&1 || true
    fi
    ;;

  *.c|*.cc|*.cpp|*.h|*.hpp|*.m|*.mm)
    find_up "$DIR" ".clang-format" >/dev/null || exit 0
    if command -v clang-format >/dev/null 2>&1; then
      clang-format -i "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
