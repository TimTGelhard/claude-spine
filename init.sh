#!/usr/bin/env bash
#
# claude-spine init — scaffold docs/ into a project from spine templates.
#
# Usage:
#   ./init.sh [<project-path>]    (default: current directory)
#   ./init.sh --dry-run [<path>]  (show what would happen, change nothing)
#
# Behavior:
#   - Idempotent. Existing files are NOT overwritten — reported as "skip (exists)".
#   - Creates docs/, docs/plans/, and .claude/ in the target project.
#   - Copies templates: PROJECT_BRIEF, ARCHITECTURE, PROJECT_PLAN, PROGRESS,
#     DECISIONS, FEATURES, SMOKE_TESTS, DEPLOY, SESSION_STARTER.
#   - Copies CLAUDE.md template into .claude/CLAUDE.md (project-level) if missing.
#   - Leaves docs/plans/ empty — /prep populates it with the real section plans.
#
# After running:
#   1. Open the project in Claude Code.
#   2. Run /prep to walk the planning pass.
#   3. Just keep working — the op-spine-active skill auto-loads scope
#      at the start of every session, /done closes a session.

set -euo pipefail

# Resolve spine dir from the script location, following symlinks.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  TARGET="$(readlink "$SOURCE")"
  if [[ "$TARGET" == /* ]]; then SOURCE="$TARGET"
  else SOURCE="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)/$TARGET"; fi
done
SPINE_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

TEMPLATES_DIR="${SPINE_DIR}/templates"

DRY_RUN=0
PROJECT_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '3,18p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*) echo "Unknown flag: $1" >&2; exit 2 ;;
    *) PROJECT_DIR="$1" ;;
  esac
  shift
done

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "Error: templates directory not found at $TEMPLATES_DIR" >&2
  exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: project directory not found at $PROJECT_DIR" >&2
  exit 1
fi

DOCS_DIR="${PROJECT_DIR}/docs"
PLANS_DIR="${DOCS_DIR}/plans"
CLAUDE_DIR="${PROJECT_DIR}/.claude"

echo "Initializing claude-spine project structure"
echo "  spine:    $SPINE_DIR"
echo "  project:  $PROJECT_DIR"
[ $DRY_RUN -eq 1 ] && echo "  (dry run — no files will be written)"
echo

run() {
  if [ $DRY_RUN -eq 1 ]; then
    echo "  would: $*"
  else
    "$@"
  fi
}

ensure_dir() {
  local d="$1"
  if [ ! -d "$d" ]; then
    run mkdir -p "$d"
    echo "  mkdir  ${d#${PROJECT_DIR}/}"
  fi
}

copy_template() {
  local src="${TEMPLATES_DIR}/$1"
  local dest="$2"
  local rel="${dest#${PROJECT_DIR}/}"

  if [ -e "$dest" ]; then
    echo "  skip   $rel  (exists)"
    return
  fi
  if [ ! -e "$src" ]; then
    echo "  ERROR  template missing: $1" >&2
    return 1
  fi
  if [ $DRY_RUN -eq 1 ]; then
    echo "  would write  $rel  (from $1)"
  else
    cp "$src" "$dest"
    echo "  write  $rel"
  fi
}

ensure_dir "$DOCS_DIR"
ensure_dir "$PLANS_DIR"
ensure_dir "$CLAUDE_DIR"

# Core project docs
copy_template "PROJECT_BRIEF.md"   "${DOCS_DIR}/PROJECT_BRIEF.md"
copy_template "ARCHITECTURE.md"    "${DOCS_DIR}/ARCHITECTURE.md"
copy_template "PROJECT_PLAN.md"    "${DOCS_DIR}/PROJECT_PLAN.md"
copy_template "PROGRESS.md"        "${DOCS_DIR}/PROGRESS.md"
copy_template "DECISIONS.md"       "${DOCS_DIR}/DECISIONS.md"
copy_template "FEATURES.md"        "${DOCS_DIR}/FEATURES.md"
copy_template "SMOKE_TESTS.md"     "${DOCS_DIR}/SMOKE_TESTS.md"
copy_template "DEPLOY.md"          "${DOCS_DIR}/DEPLOY.md"
copy_template "SESSION_STARTER.md" "${DOCS_DIR}/SESSION_STARTER.md"

# Project-level CLAUDE.md skeleton (only if missing)
copy_template "CLAUDE.md"          "${CLAUDE_DIR}/CLAUDE.md"

# Keep docs/plans/ as a tracked directory (real plans land here when /prep runs)
if [ ! -e "${PLANS_DIR}/.gitkeep" ]; then
  if [ $DRY_RUN -eq 1 ]; then
    echo "  would write  docs/plans/.gitkeep"
  else
    : > "${PLANS_DIR}/.gitkeep"
    echo "  write  docs/plans/.gitkeep"
  fi
fi

echo
echo "Done."
echo
echo "Next steps in the project (Claude Code session):"
echo "  1. /prep   — walk the planning pass"
echo "  2. (just keep working — op-spine-active auto-loads scope each session)"
echo "  3. /done   — writeback when the session is done"
