#!/usr/bin/env bash
# claude-spine installer
#
# Wires this clone into ~/.claude/ so Claude Code picks up the spine's skills,
# the global stub, the settings allowlist, and the env-leak hook.
#
# Usage:
#   ./install.sh                     # neutral global stub (default)
#   ./install.sh --opinionated       # the heavy founder-flavored template instead
#   ./install.sh --skip-global       # skip ~/.claude/CLAUDE.md
#   ./install.sh --skip-skills       # skip skill symlinks
#   ./install.sh --skip-commands     # skip slash-command symlinks
#   ./install.sh --skip-settings     # skip ~/.claude/settings.json
#   ./install.sh --skip-hook         # skip installing hooks (env-leak + spine-writeback)
#   ./install.sh --keep-legacy       # don't remove pre-v2 op-manual-* skills
#   ./install.sh --force-global      # overwrite ~/.claude/CLAUDE.md even if user-customized
#   ./install.sh --dry-run           # print actions, change nothing
#   ./install.sh -h | --help

set -euo pipefail

# ---------- resolve spine root ----------

# The directory this script lives in is the spine root.
SCRIPT_PATH="${BASH_SOURCE[0]}"
# Resolve any symlinks in the script path itself.
while [ -L "$SCRIPT_PATH" ]; do
  link_target="$(readlink "$SCRIPT_PATH")"
  case "$link_target" in
    /*) SCRIPT_PATH="$link_target" ;;
    *) SCRIPT_PATH="$(dirname "$SCRIPT_PATH")/$link_target" ;;
  esac
done
SPINE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"

# ---------- parse flags ----------

OPINIONATED=0
SKIP_GLOBAL=0
SKIP_SKILLS=0
SKIP_COMMANDS=0
SKIP_SETTINGS=0
SKIP_HOOK=0
KEEP_LEGACY=0
FORCE_GLOBAL=0
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --opinionated) OPINIONATED=1 ;;
    --skip-global) SKIP_GLOBAL=1 ;;
    --skip-skills) SKIP_SKILLS=1 ;;
    --skip-commands) SKIP_COMMANDS=1 ;;
    --skip-settings) SKIP_SETTINGS=1 ;;
    --skip-hook) SKIP_HOOK=1 ;;
    --keep-legacy) KEEP_LEGACY=1 ;;
    --force-global) FORCE_GLOBAL=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,18p' "$0"
      exit 0
      ;;
    *)
      echo "unknown flag: $arg" >&2
      echo "run ./install.sh --help" >&2
      exit 2
      ;;
  esac
done

# ---------- preflight ----------

CLAUDE_DIR="$HOME/.claude"
SPINE_LINK="$HOME/.claude-spine"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"

case "$(uname -s)" in
  Darwin|Linux) : ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "Windows detected. This installer needs symlinks. Run inside WSL," >&2
    echo "or copy skills/core/, global/, and templates/ into ~/.claude manually." >&2
    exit 1
    ;;
  *)
    echo "Unknown OS: $(uname -s). Proceeding — expect breakage." >&2
    ;;
esac

# Env-leak hook needs jq to parse Claude Code's hook input. Without it the hook
# silently no-ops on the very command it exists to block. Fail before we touch
# anything if jq is missing and the hook install isn't explicitly skipped.
if [ "$SKIP_HOOK" -eq 0 ] && ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required for the env-leak hook (\`global/hooks/block-env-staging.sh\`)." >&2
  echo "       Without jq the hook silently fails on \`git add .env\` — the exact thing" >&2
  echo "       it's meant to prevent." >&2
  echo >&2
  echo "       Install jq, then re-run:" >&2
  echo "         macOS:  brew install jq" >&2
  echo "         Linux:  apt-get install jq    (or your distro's equivalent)" >&2
  echo >&2
  echo "       Or skip the hook explicitly: ./install.sh --skip-hook" >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN — no changes will be made."
fi
echo "Spine root:    $SPINE_DIR"
echo "Claude dir:    $CLAUDE_DIR"
echo "Spine symlink: $SPINE_LINK"
echo

# ---------- helpers ----------

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  + $*"
  else
    "$@"
  fi
}

ensure_dir() {
  if [ ! -d "$1" ]; then
    run mkdir -p "$1"
  fi
}

# Back up a path into BACKUP_DIR (preserving relative location under $HOME).
backup_path() {
  local src="$1"
  [ -e "$src" ] || [ -L "$src" ] || return 0
  local rel="${src#$HOME/}"
  local dest="$BACKUP_DIR/$rel"
  ensure_dir "$(dirname "$dest")"
  run cp -a "$src" "$dest"
  echo "  backed up: $src → $dest"
}

# Symlink src → dest, backing up dest if it already exists and isn't already the right link.
symlink_force() {
  local src="$1"
  local dest="$2"
  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      echo "  ok (already linked): $dest → $src"
      return 0
    fi
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup_path "$dest"
    run rm -rf "$dest"
  fi
  run ln -s "$src" "$dest"
  echo "  linked: $dest → $src"
}

# ---------- 1. ~/.claude-spine symlink ----------

echo "==> ensuring ~/.claude-spine resolves to the spine clone"
ensure_dir "$CLAUDE_DIR"

if [ -L "$SPINE_LINK" ]; then
  current="$(readlink "$SPINE_LINK")"
  # Resolve relative readlink against $HOME.
  case "$current" in
    /*) abs_current="$current" ;;
    *) abs_current="$HOME/$current" ;;
  esac
  if [ "$(cd "$abs_current" 2>/dev/null && pwd -P)" = "$SPINE_DIR" ]; then
    echo "  ok: $SPINE_LINK already → $SPINE_DIR"
  else
    backup_path "$SPINE_LINK"
    run rm -f "$SPINE_LINK"
    run ln -s "$SPINE_DIR" "$SPINE_LINK"
    echo "  re-linked: $SPINE_LINK → $SPINE_DIR"
  fi
elif [ "$SPINE_DIR" = "$SPINE_LINK" ]; then
  # User cloned the spine directly into the canonical path.
  echo "  ok: spine is already at $SPINE_LINK (no symlink needed)"
elif [ -e "$SPINE_LINK" ]; then
  # A real, unrelated directory/file is sitting at ~/.claude-spine. Don't clobber.
  echo "  ERROR: $SPINE_LINK exists and is not a symlink (and is not this spine)." >&2
  echo "  Move it aside, then re-run." >&2
  exit 1
else
  run ln -s "$SPINE_DIR" "$SPINE_LINK"
  echo "  linked: $SPINE_LINK → $SPINE_DIR"
fi
echo

# ---------- 1b. legacy op-manual-* cleanup ----------

# The v1 line of skills was named op-manual-{workflow,tactics,templates,recovery}.
# The v2 spine ships a finer-grained op-* set that supersedes them. If we leave
# both in place, trigger descriptions overlap and skills double-fire. Wipe them
# unless the user opted into --keep-legacy.

if [ "$SKIP_SKILLS" -eq 0 ]; then
  if [ "$KEEP_LEGACY" -eq 1 ]; then
    echo "==> --keep-legacy: leaving any op-manual-* skills in place"
    echo "    (they may overlap with the spine's op-* set and double-fire)"
    echo
  else
    legacy_found=0
    for legacy_dir in "$CLAUDE_DIR"/skills/op-manual-*; do
      [ -e "$legacy_dir" ] || [ -L "$legacy_dir" ] || continue
      legacy_found=1
      break
    done
    if [ "$legacy_found" -eq 1 ]; then
      echo "==> removing legacy op-manual-* skills (superseded by spine's op-*)"
      for legacy_dir in "$CLAUDE_DIR"/skills/op-manual-*; do
        [ -e "$legacy_dir" ] || [ -L "$legacy_dir" ] || continue
        backup_path "$legacy_dir"
        run rm -rf "$legacy_dir"
        echo "  removed: $legacy_dir"
      done
      echo "  (pass --keep-legacy to opt out of this step)"
      echo
    fi
  fi
fi

# ---------- 2. core skill symlinks ----------

if [ "$SKIP_SKILLS" -eq 0 ]; then
  echo "==> linking core skills into ~/.claude/skills/"
  ensure_dir "$CLAUDE_DIR/skills"
  for skill_dir in "$SPINE_DIR"/skills/core/op-*/; do
    [ -d "$skill_dir" ] || continue
    skill_dir="${skill_dir%/}"
    skill_name="$(basename "$skill_dir")"
    symlink_force "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
  done
  echo
else
  echo "==> skipping skill symlinks (--skip-skills)"
  echo
fi

# ---------- 3. slash commands ----------

if [ "$SKIP_COMMANDS" -eq 0 ]; then
  if [ -d "$SPINE_DIR/global/commands" ]; then
    echo "==> linking slash commands into ~/.claude/commands/"
    ensure_dir "$CLAUDE_DIR/commands"
    found=0
    for cmd_file in "$SPINE_DIR"/global/commands/*.md; do
      [ -f "$cmd_file" ] || continue
      found=1
      cmd_name="$(basename "$cmd_file")"
      symlink_force "$cmd_file" "$CLAUDE_DIR/commands/$cmd_name"
    done
    if [ "$found" -eq 0 ]; then
      echo "  (no commands found in $SPINE_DIR/global/commands)"
    fi
    echo
  fi
else
  echo "==> skipping slash commands (--skip-commands)"
  echo
fi

# ---------- 4. global CLAUDE.md ----------

if [ "$SKIP_GLOBAL" -eq 0 ]; then
  if [ "$OPINIONATED" -eq 1 ]; then
    SRC_TEMPLATE="$SPINE_DIR/global/opinionated/CLAUDE.md.template"
    OTHER_TEMPLATE="$SPINE_DIR/global/neutral/CLAUDE.md.template"
    VARIANT="opinionated"
  else
    SRC_TEMPLATE="$SPINE_DIR/global/neutral/CLAUDE.md.template"
    OTHER_TEMPLATE="$SPINE_DIR/global/opinionated/CLAUDE.md.template"
    VARIANT="neutral"
  fi
  echo "==> installing global CLAUDE.md ($VARIANT variant)"

  if [ ! -f "$SRC_TEMPLATE" ]; then
    echo "  ERROR: missing template $SRC_TEMPLATE" >&2
    exit 1
  fi

  DEST="$CLAUDE_DIR/CLAUDE.md"

  # Render each template to a temp file so we can detect an untouched prior install (safe to overwrite) vs a user-customized file (preserve unless --force-global).
  RENDERED_TMP="$(mktemp)"
  OTHER_TMP="$(mktemp)"
  sed "s|{{SPINE_DIR}}|$SPINE_DIR|g" "$SRC_TEMPLATE" > "$RENDERED_TMP"
  [ -f "$OTHER_TEMPLATE" ] && sed "s|{{SPINE_DIR}}|$SPINE_DIR|g" "$OTHER_TEMPLATE" > "$OTHER_TMP"

  SHOULD_WRITE=1
  if [ -e "$DEST" ] && [ "$FORCE_GLOBAL" -ne 1 ]; then
    if cmp -s "$DEST" "$RENDERED_TMP"; then
      echo "  unchanged: $DEST already matches the $VARIANT template — skipping"
      SHOULD_WRITE=0
    elif [ -s "$OTHER_TMP" ] && cmp -s "$DEST" "$OTHER_TMP"; then
      echo "  variant swap: $DEST matches the untouched other variant — overwriting"
      backup_path "$DEST"
    else
      echo "  preserved: $DEST appears user-customized — leaving it alone"
      echo "             pass --force-global to overwrite (existing file will still be backed up first)"
      SHOULD_WRITE=0
    fi
  elif [ -e "$DEST" ] || [ -L "$DEST" ]; then
    backup_path "$DEST"
  fi

  if [ "$SHOULD_WRITE" -eq 1 ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "  + render $SRC_TEMPLATE → $DEST (substituting {{SPINE_DIR}})"
    else
      cat "$RENDERED_TMP" > "$DEST"
      echo "  wrote: $DEST"
      if [ "$OPINIONATED" -eq 1 ]; then
        echo "  NOTE: opinionated template has {{placeholders}} (name, intro, stack)."
        echo "        Open $DEST and fill them in."
      fi
    fi
  fi

  rm -f "$RENDERED_TMP" "$OTHER_TMP"
  echo
else
  echo "==> skipping global CLAUDE.md (--skip-global)"
  echo
fi

# ---------- 5. settings.json ----------

if [ "$SKIP_SETTINGS" -eq 0 ]; then
  echo "==> installing settings.json"
  DEST="$CLAUDE_DIR/settings.json"
  if [ -e "$DEST" ] || [ -L "$DEST" ]; then
    backup_path "$DEST"
  fi
  run cp "$SPINE_DIR/global/settings.json" "$DEST"
  echo "  wrote: $DEST"
  echo "  review the allowlist; trim to your stack."
  echo
else
  echo "==> skipping settings.json (--skip-settings)"
  echo
fi

# ---------- 6. hooks ----------

if [ "$SKIP_HOOK" -eq 0 ]; then
  echo "==> installing hooks"
  ensure_dir "$CLAUDE_DIR/hooks"
  hook_found=0
  for hook_src in "$SPINE_DIR"/global/hooks/*.sh; do
    [ -f "$hook_src" ] || continue
    hook_found=1
    hook_name="$(basename "$hook_src")"
    DEST="$CLAUDE_DIR/hooks/$hook_name"
    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
      backup_path "$DEST"
    fi
    run cp "$hook_src" "$DEST"
    run chmod +x "$DEST"
    echo "  wrote: $DEST"
  done
  if [ "$hook_found" -eq 0 ]; then
    echo "  (no hooks found in $SPINE_DIR/global/hooks)"
  fi
  echo
else
  echo "==> skipping hooks (--skip-hook)"
  echo
fi

# ---------- summary ----------

echo "==> claude-spine is installed."
echo
echo "  What just happened: 22 skills, 9 slash commands, a thin global"
echo "  CLAUDE.md, settings, and safety hooks were linked into ~/.claude/."
echo "  Claude Code will pick them up on its next launch."
echo
echo "  ┌── Next steps ─────────────────────────────────────────────────┐"
echo "  │                                                               │"
echo "  │  1. Restart Claude Code  (so it loads the new skills)         │"
echo "  │  2. Open any Claude Code session                              │"
echo "  │  3. Type  /onboard                                            │"
echo "  │                                                               │"
echo "  │  /onboard is a ~2-minute, 7-question interview that calibrates│"
echo "  │  Claude to your subscription, stack, and working style.       │"
echo "  │  Without it, every session falls back to generic defaults.    │"
echo "  │                                                               │"
echo "  │  After onboard, type  /spine  to see everything that's loaded,│"
echo "  │  or just start working — Claude knows what to do.             │"
echo "  │                                                               │"
echo "  └───────────────────────────────────────────────────────────────┘"
if [ -d "$BACKUP_DIR" ]; then
  echo
  echo "  Existing files were backed up to:"
  echo "    $BACKUP_DIR"
fi
echo
echo "  Re-running ./install.sh is safe (idempotent). To uninstall: ./uninstall.sh"
