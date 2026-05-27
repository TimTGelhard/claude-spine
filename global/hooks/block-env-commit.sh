#!/usr/bin/env bash
# Pre-tool-use hook: block any `git commit` whose staged set contains a .env file.
#
# Closes the gap left by block-env-staging.sh, which only intercepts `git add`
# arguments. A .env that was tracked before .gitignore was set up, or one that
# slipped in via `git add -f`, would still reach `git commit`. This hook is the
# second layer.
#
# Designed to NEVER block in error. -e is intentionally not set; any parse
# failure exits 0 silently and lets the commit proceed (the staging hook is
# still the primary defense).

set -uo pipefail

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$CMD" ] && exit 0

# Only intercept commit invocations. Match `git commit` (with any flag combo)
# but not commands that merely contain "commit" elsewhere (e.g. `git log --grep=commit`).
case "$CMD" in
  *"git commit"*|*"git "*"commit "*|*"git "*"commit") ;;
  *) exit 0 ;;
esac
# Stricter re-check: ensure `commit` is the subcommand, not a flag value.
if ! echo "$CMD" | grep -qE '(^|[[:space:]]|;|&&)git[[:space:]]+(-[a-zA-Z-]+[[:space:]]+)*commit($|[[:space:]])'; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
[ -z "$CWD" ] && CWD="$PWD"

[ -d "$CWD/.git" ] || [ -f "$CWD/.git" ] || exit 0

STAGED=$(cd "$CWD" && git diff --cached --name-only 2>/dev/null || true)
[ -z "$STAGED" ] && exit 0

# Match any path whose final segment is .env or .env.<anything>.
# Examples that match: .env, .env.local, foo/.env, sub/.env.production
# Examples that don't:  foo.env.template, .env.example.bak (if extension chain), README.env-notes.md
ENV_FILES=$(echo "$STAGED" | grep -E '(^|/)\.env(\.[a-zA-Z0-9_.-]+)?$' || true)
[ -z "$ENV_FILES" ] && exit 0

JOINED=$(echo "$ENV_FILES" | tr '\n' ' ' | sed -E 's/[[:space:]]+$//')

jq -n --arg files "$JOINED" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("Blocked: refusing to commit staged .env file(s): " + $files + ". If this is intentional (e.g., committing a .env.example template), rename the file or `git restore --staged <file>` first, then re-commit. If the file is tracked from before .gitignore was set up, run `git rm --cached <file>` and add it to .gitignore.")
  }
}'

exit 0
