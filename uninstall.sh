#!/usr/bin/env bash
# claude-spine uninstaller
#
# Removes the spine's symlinks and the env-leak hook from ~/.claude/.
# Leaves user data alone: CLAUDE.md, settings.json, ~/.claude/claude-spine-profile.md,
# and the spine's bucket/ directory.
#
# Usage:
#   ./uninstall.sh                   # remove what install.sh installed
#   ./uninstall.sh --dry-run         # print actions, change nothing
#   ./uninstall.sh -h | --help

set -euo pipefail

# ---------- resolve spine root ----------

# Same logic as install.sh: the directory this script lives in is the spine root.
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
  link_target="$(readlink "$SCRIPT_PATH")"
  case "$link_target" in
    /*) SCRIPT_PATH="$link_target" ;;
    *) SCRIPT_PATH="$(dirname "$SCRIPT_PATH")/$link_target" ;;
  esac
done
SPINE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"

# ---------- parse flags ----------

DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *)
      echo "unknown flag: $arg" >&2
      echo "run ./uninstall.sh --help" >&2
      exit 2
      ;;
  esac
done

CLAUDE_DIR="$HOME/.claude"
SPINE_LINK="$HOME/.claude-spine"

# ---------- helpers ----------

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  + $*"
  else
    "$@"
  fi
}

# Check whether a symlink resolves into $SPINE_DIR/$subpath/. install.sh creates
# these links with absolute paths, so a literal prefix match is enough — and
# safer than `readlink -f`, which BSD readlink (macOS) doesn't support.
points_into_spine() {
  local link="$1"
  local subpath="$2"
  [ -L "$link" ] || return 1
  local target
  target="$(readlink "$link")"
  case "$target" in
    "$SPINE_DIR/$subpath"/*) return 0 ;;
    *) return 1 ;;
  esac
}

# ---------- preflight ----------

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN — no changes will be made."
fi
echo "Spine root:    $SPINE_DIR"
echo "Claude dir:    $CLAUDE_DIR"
echo "Spine symlink: $SPINE_LINK"
echo

# ---------- 1. skill symlinks ----------

# Two symlink targets count as "spine-installed" under ~/.claude/skills/op-*:
#   - skills/core/op-*/                       (the universal op-* set, 22 of them)
#   - global/stacks/*/flavor-skill/           (the op-stack-flavor symlink — only
#                                              present when install was run with
#                                              --stack=<name>)
# Anything else under op-* — a hand-rolled skill, a skill pointing into a
# different spine clone — is left alone.

echo "==> removing spine skill symlinks from $CLAUDE_DIR/skills/"
removed_skills=0
skipped_skills=0
if [ -d "$CLAUDE_DIR/skills" ]; then
  for link in "$CLAUDE_DIR"/skills/op-*; do
    [ -L "$link" ] || continue
    if points_into_spine "$link" "skills/core"; then
      run rm -f "$link"
      echo "  removed: $link"
      removed_skills=$((removed_skills + 1))
    elif points_into_spine "$link" "global/stacks"; then
      run rm -f "$link"
      echo "  removed: $link (stack-flavor)"
      removed_skills=$((removed_skills + 1))
    else
      echo "  skipped: $link (not pointing into this spine clone)"
      skipped_skills=$((skipped_skills + 1))
    fi
  done
fi
if [ "$removed_skills" -eq 0 ] && [ "$skipped_skills" -eq 0 ]; then
  echo "  (none found)"
fi
echo

# ---------- 2. slash commands ----------

echo "==> removing spine command symlinks from $CLAUDE_DIR/commands/"
removed_cmds=0
skipped_cmds=0
if [ -d "$CLAUDE_DIR/commands" ]; then
  for link in "$CLAUDE_DIR"/commands/*.md; do
    [ -L "$link" ] || continue
    if points_into_spine "$link" "global/commands"; then
      run rm -f "$link"
      echo "  removed: $link"
      removed_cmds=$((removed_cmds + 1))
    else
      skipped_cmds=$((skipped_cmds + 1))
    fi
  done
fi
if [ "$removed_cmds" -eq 0 ]; then
  echo "  (none found)"
fi
echo

# ---------- 3. env-leak hook ----------

echo "==> removing env-leak hook"
HOOK="$CLAUDE_DIR/hooks/block-env-staging.sh"
if [ -e "$HOOK" ] || [ -L "$HOOK" ]; then
  run rm -f "$HOOK"
  echo "  removed: $HOOK"
else
  echo "  (not present)"
fi
echo

# ---------- 4. ~/.claude-spine symlink ----------

echo "==> removing ~/.claude-spine"
if [ -L "$SPINE_LINK" ]; then
  run rm -f "$SPINE_LINK"
  echo "  removed: $SPINE_LINK (symlink)"
elif [ -e "$SPINE_LINK" ]; then
  echo "  skipped: $SPINE_LINK is a real directory, not a symlink — leaving it alone."
else
  echo "  (not present)"
fi
echo

# ---------- summary: what's left ----------

echo "==> done."
echo
echo "  the following were intentionally LEFT IN PLACE:"
if [ -f "$CLAUDE_DIR/CLAUDE.md" ] || [ -L "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo "    $CLAUDE_DIR/CLAUDE.md  (may be customized)"
fi
if [ -f "$CLAUDE_DIR/settings.json" ] || [ -L "$CLAUDE_DIR/settings.json" ]; then
  echo "    $CLAUDE_DIR/settings.json  (may be customized)"
fi
if [ -f "$CLAUDE_DIR/claude-spine-profile.md" ]; then
  echo "    $CLAUDE_DIR/claude-spine-profile.md  (your onboarding profile)"
fi
if [ -d "$SPINE_DIR/bucket" ]; then
  echo "    $SPINE_DIR/bucket/  (your bucket skills — user data)"
fi
echo
echo "  to restore the pre-spine versions, look in ~/.claude-backup-<timestamp>/"
echo "  to drop these too: rm them by hand."
echo
echo "  restart Claude Code for the changes to take effect."
