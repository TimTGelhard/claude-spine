#!/bin/bash
# Pre-tool-use hook: block any `git add` command that stages a .env file.
# Defense in depth — .gitignore should already prevent this, but env-file leaks
# are catastrophic, so a second layer is worth the trivial cost.

set -euo pipefail

# Read the tool input from stdin (Claude Code hook protocol).
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Match `git add` commands that explicitly reference an env file in the args.
# Patterns matched:
#   git add .env
#   git add .env.local
#   git add foo/.env
#   git add -A .env.production
# Does NOT match `git add .` or `git add -A` alone — those rely on .gitignore.
# That's acceptable: if .gitignore is set up correctly (per stack defaults),
# `git add .` won't pick up .env files anyway.
if echo "$CMD" | grep -qE '(^|[[:space:]])(.*/)?\.env(\.[a-zA-Z0-9_.-]+)?($|[[:space:]])'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: never `git add` a .env file. If .gitignore is missing the entry, fix that first. Use `git add -f` only with explicit intent and confirm the file contains no secrets."
    }
  }'
  exit 0
fi

# Not a git-add-env command — allow.
exit 0
