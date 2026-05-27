# 14b — Hooks: what they are and what to wire

Hooks are shell commands the *harness* runs in response to events. The harness runs them, not Claude. Crucial implications:

- **You can't ask Claude to "do X automatically every time."** That's a hook, configured in `settings.json`.
- They're deterministic. Fire every time their event fires, regardless of what Claude was thinking.
- They run with your shell permissions.

This is why hooks are the right answer to "from now on, when X, do Y" — behavior the system executes, not a memory Claude has.

## Hooks vs CLAUDE.md vs skills vs memory

| Want | Use | Why |
|------|-----|-----|
| "Always run X when editing TS files" | Hook | Deterministic, runs every time, doesn't burn Claude tokens |
| "Default to approach X for new features" | CLAUDE.md instruction | Claude internalizes it; flexible for edge cases |
| "Multi-step procedure I do repeatedly" | Skill | Loaded on demand, doesn't bloat context |
| "Remember this preference about how I work" | Memory | Persists, Claude consults when relevant |

**Common mistake:** trying to put "always run typecheck after editing" in CLAUDE.md. Claude *might* do it, *might* forget, *might* skip in long sessions. Hook = it always happens.

The decision tree: if it's a *command that can be scripted*, it's a hook. If it's *reasoning Claude should do*, it's CLAUDE.md or a skill.

## High-value recipes

Ask the `update-config` skill to set these up.

### Quality gates (run after edits)
- **TypeScript check after `.ts`/`.tsx` edits.** Catches type breakage in real-time.
- **Linter / formatter on save.** Stops style drift.
- **Test runner on edits to test files.** Tight feedback loop.

### Commit gates (run before commits)
- **Block commits if typecheck fails.**
- **Block commits if `grep -r "TODO: do not commit" .` finds matches.**
- **Block commits to `main` directly.** Force PRs / branches.
- **Block commits that include `.env.local` or other gitignored-but-staged files.**

### Notifications (run on completion)
- **Show a notification when a long-running command finishes.** Stop blocking.
- **Beep when Claude needs input.** Useful if you're context-switching.

## Recommended starter set

If you have zero hooks today, this minimum set pays back immediately:

1. **TypeScript check on `.ts`/`.tsx` edits.**
2. **Block commits if typecheck fails.**
3. **Allowlist read-only commands** (`fewer-permission-prompts` skill).
4. **Block commits including `.env.local`, `.env`, or `.env.*.local`**.
5. **Notification when long-running commands finish.**

Total setup: ~15 minutes via `update-config`. Pays back daily.

If you're on **claude-spine**, items 4 and 5 ship default-on (`block-env-commit.sh` + `notify-long-task.sh`), and item 1 plus an auto-formatter ship default-off as opt-ins through `/onboard --deep` (the Hook tuning pass writes them to `~/.claude/settings.json` after explicit Y/n approval — see `skills/core/op-onboard/SKILL.md` `## Hook tuning (deep mode only)`). That leaves item 2 (block-on-typecheck-fail) and item 3 (read-only allowlist) for `update-config` to wire when you're ready.

## Project-level hooks (ship with the repo)

For client-site work especially:

- **Lighthouse check before commit on a touched HTML/CSS file.**
- **Image optimization on adding files to `images/`** — convert to WebP, fail if any image is >500KB.
- **JSON-LD validation hook** — schema check on structured data.

These live in the project's `.claude/settings.json` — they ship with the codebase, so future-you (or another contributor) inherits them.

## What NOT to hook

- **Heavy commands on every edit.** Full test suite on each save = hated machine. Scope to lightweight checks.
- **Anything destructive.** No auto-delete, auto-push, auto-deploy.
- **Aggressive auto-fix on save.** Formatter fine. Auto-import-organizer fine. Auto-fix linter errors risky — you don't see what changed.
- **Hooks that hide bugs.** "Hook auto-retries failed commands" is debt waiting to bite.

## Verifying hooks work

After setting up a hook, test that it fires:

1. Trigger the event (edit a file, attempt a commit).
2. Confirm the hook actually ran. Silent failure is worse than no hook.
3. Test the failure path — break something and confirm the hook catches it.

A hook you haven't tested isn't a guarantee, it's a hope.

## Maintaining hooks

Symptoms a hook is wrong:

- "It's annoying me; it's slow on big edits" → scope tighter or run async.
- "It blocks on something unrelated" → fix the underlying issue or remove.
- "I bypass it with `--no-verify` regularly" → fix or kill.

A hook you routinely bypass is worse than no hook — it teaches you to ignore safety checks.

## TL;DR

- Hooks are how the system enforces "from now on, when X, do Y." Not CLAUDE.md, not memory.
- Use the `update-config` skill to write them — don't memorize the schema.
- Starter set: TS check on edits, block commits on typecheck fail, allowlist read-only, block env files, notify on long completion.
- A hook you bypass should be removed, not endured.
