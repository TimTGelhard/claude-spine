#!/usr/bin/env bash
# claude-spine fast test suite
#
# Runs the deterministic, offline tests that should pass on every commit:
#   - hooks/test-block-env-staging.sh    (JSON-in, JSON-out hook contract)
#   - hooks/test-block-env-commit.sh     (git commit guard against staged .env)
#   - hooks/test-typecheck-after-edit.sh (opt-in PostToolUse typecheck contract)
#   - hooks/test-format-on-save.sh       (opt-in PostToolUse formatter routing)
#   - onboard/test-extras-merge.sh       (jq merge for settings-extras fragments)
#   - installer/test-dry-run.sh          (install.sh --dry-run output contract)
#
# Skipped here: tests/skill-triggers/ — it costs real money (API calls) and
# the launch doc explicitly excludes it from the fast suite. Run it manually
# before editing any op-* skill description.

set -uo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
  link_target="$(readlink "$SCRIPT_PATH")"
  case "$link_target" in
    /*) SCRIPT_PATH="$link_target" ;;
    *) SCRIPT_PATH="$(dirname "$SCRIPT_PATH")/$link_target" ;;
  esac
done
TESTS_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required (used by the env-leak hook and the fixture)." >&2
  echo "       macOS:  brew install jq" >&2
  echo "       Linux:  apt-get install jq    (or your distro's equivalent)" >&2
  exit 1
fi

suites=(
  "hooks/test-block-env-staging.sh"
  "hooks/test-block-env-commit.sh"
  "hooks/test-typecheck-after-edit.sh"
  "hooks/test-format-on-save.sh"
  "onboard/test-extras-merge.sh"
  "installer/test-dry-run.sh"
)

passed=0
failed=0
failed_names=()

for suite in "${suites[@]}"; do
  echo "============================================================"
  echo "  $suite"
  echo "============================================================"
  if bash "$TESTS_DIR/$suite"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    failed_names+=("$suite")
  fi
  echo
done

echo "============================================================"
echo "  summary: $passed suite(s) passed, $failed failed"
if [ "$failed" -gt 0 ]; then
  for name in "${failed_names[@]}"; do
    echo "    FAIL  $name"
  done
  exit 1
fi
