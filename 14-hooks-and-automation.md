> **DEPRECATED** — v2 atomic version: [`chapters/persistence/`](chapters/persistence/). Full v1→v2 map: [`V1-CHAPTERS-DEPRECATED.md`](V1-CHAPTERS-DEPRECATED.md). Body kept for cross-reference.

# 14 — Hooks and automation

The most underused leverage in Claude Code. Hooks let you wire actions to events — automatically running typecheck after a TypeScript edit, blocking commits without a smoke test, formatting on save, notifying when a long build finishes. Set them up once, then stop thinking about them.

## What hooks are (and aren't)

Hooks in Claude Code are shell commands the *harness* runs in response to events. Crucially:

- **The harness runs them**, not Claude. You can't ask Claude to "do something automatically every time" — that's a hook, configured in `settings.json`.
- They're deterministic. A hook fires every time its event fires, regardless of what Claude was thinking.
- They run with your shell permissions.

This is why hooks are the right answer to "from now on, when X, do Y" — that's a behavior the system executes, not a memory Claude has.

## Where settings live

Settings cascade, narrowest wins (except security):

| Location | Scope |
|----------|-------|
| `~/.claude/settings.json` | Global — applies to every project on this machine. |
| `~/.claude/settings.local.json` | Global, local-machine override, gitignored by default. |
| `<project>/.claude/settings.json` | Project — shared with collaborators via git. |
| `<project>/.claude/settings.local.json` | Project, local-only, gitignored. |

For solo MVP work, you mostly want global settings (machine-wide habits) and project settings (project-specific rules). Local files are for personal overrides you don't want to ship.

## The skill that does this for you

You have an `update-config` skill installed. Use it. When you want a hook, ask:

> "Add a hook to run `npm run typecheck` after any TypeScript edit, in this project only."

The skill knows the current settings.json schema, picks the right event name, and writes it correctly. You don't have to remember the exact hook event identifiers — they shift between Claude Code versions, and the skill stays current.

This is the #1 thing to know: **don't hand-edit settings.json from memory.** Use the skill. Treat it like a `kubectl` for your Claude Code config.

## Common hook recipes

These are the high-value automations for a solo MVP/client-site builder. Ask the `update-config` skill to set them up.

### Quality gates (run after edits)
- **TypeScript check after `.ts`/`.tsx` edits.** Fails loudly if types break. Catches issues before they accumulate.
- **Linter / formatter on save.** Stops style drift, removes a class of "Claude wrote it slightly different than my conventions" friction.
- **Test runner on edits to test files.** Tight feedback loop.

### Commit gates (run before commits)
- **Block commits if typecheck fails.** Catches at the boundary.
- **Block commits if `grep -r "TODO: do not commit" .` finds matches.** A reliable safety net.
- **Block commits to `main` directly.** Force PRs / branches.
- **Block commits that include `.env.local` or other gitignored-but-staged files.**

### Notifications (run on completion)
- **Show a notification when a long-running command finishes.** Stop blocking on it.
- **Beep when Claude needs your input.** Useful if you're context-switching.

### Read-only allowlist (no hook, but a permission setting)
- Add common read-only commands (`git status`, `git diff`, `ls`, `npm ls`, `supabase status`, etc.) to the permission allowlist. Reduces "approve this tool call" prompts. Use the `fewer-permission-prompts` skill to auto-generate one for your patterns.

## Hooks vs CLAUDE.md vs skills

Choosing the right mechanism for "I want X to happen":

| Want | Use | Why |
|------|-----|-----|
| "Always do X when editing TS files" | Hook | Deterministic, runs every time, doesn't burn Claude tokens |
| "Default to approach X for new features" | CLAUDE.md instruction | Claude internalizes it; flexible for edge cases |
| "Multi-step procedure I do repeatedly" | Skill | Loaded on demand, doesn't bloat context |
| "Remember this preference about how I work" | Memory | Persists, Claude consults when relevant |

The decision tree: if it's a *command that can be scripted*, it's a hook. If it's *reasoning Claude should do*, it's CLAUDE.md or a skill.

**Common mistake:** trying to put "always run typecheck after editing" in CLAUDE.md. Claude *might* do it, *might* forget, *might* skip in long sessions. Hook = it always happens.

## What NOT to hook

Don't:

- **Run heavy commands on every edit.** Full test suite on each save is a recipe for hating your machine. Scope hooks to lightweight checks.
- **Hook anything destructive.** Don't auto-delete, auto-push, auto-deploy. Hooks are deterministic — that's wrong for destructive ops.
- **Auto-fix on save aggressively.** Auto-formatter is fine. Auto-import-organizer is fine. Auto-fix linter errors is risky — you don't see what changed.
- **Hide bugs with hooks.** "Hook auto-retries failed commands" is debt waiting to bite.

## Settings.json for permissions

Beyond hooks, settings.json controls which tools and commands need approval. Useful patterns:

- **Allowlist your read-only commands** — see `fewer-permission-prompts` skill.
- **Deny dangerous commands by default** — `rm -rf`, `git push --force`, etc. require explicit approval each time even if other Bash usage is allowlisted.
- **Per-project allowances** — a project that needs `supabase` commands frequently can have them allowlisted in its `.claude/settings.json` without affecting other projects.

When in doubt about a setting, ask the `update-config` skill — it'll tell you the current schema and place the change correctly.

## Keybindings

Less critical, but if you have repeated keystroke patterns, `~/.claude/keybindings.json` lets you customize. The `keybindings-help` skill walks you through it.

Useful for: chord shortcuts (e.g. `Ctrl+G, Ctrl+S` for "git status"), rebinding submit/cancel keys, custom commands you run constantly.

## A recommended starting setup for your work

If you have zero hooks today, here's a minimum-viable automation set that pays back immediately:

1. **TypeScript check on `.ts`/`.tsx` edits.** Catches type breakage in real-time.
2. **Block commits if typecheck fails.** Belt and suspenders.
3. **Allowlist read-only commands**: `git status`, `git diff`, `git log`, `ls`, `cat`, `npm ls`, `supabase status`, `vercel ls`, `vercel inspect`. Stops most permission prompts. Use `fewer-permission-prompts` skill.
4. **Block commits including `.env.local`, `.env`, or `.env.*.local`**. Saves you from accidentally pushing secrets. Doesn't replace `.gitignore`, supplements it.
5. **Notification when long-running commands finish.** So you don't have to babysit `npm install` or `supabase db push`.

Total setup: ~15 minutes via the `update-config` skill. Pays back daily.

## Project-level hooks for client work

For static client sites specifically, consider per-project hooks:

- **Lighthouse check before commit on a touched HTML/CSS file.** Catches perf regressions early.
- **Image optimization on adding files to `images/`** — auto-convert to WebP, fail if any image is >500KB.
- **JSON-LD validation hook** — runs a quick schema check on the site's structured data.

These live in the project's `.claude/settings.json` — they ship with the codebase, so future-you (or another contributor) inherits them automatically.

## Verifying hooks work

After setting up a hook, **test that it fires**:

1. Trigger the event (edit a file, attempt a commit, etc.).
2. Confirm the hook actually ran. If it failed silently, that's worse than no hook.
3. Test the failure path — edit something that should make the hook fail. Confirm it does.

A hook you haven't tested isn't a guarantee, it's a hope.

## Updating hooks over time

Hooks rot like any code. Symptoms:

- "The typecheck hook is annoying me; it's slow on big edits" → scope it tighter or run async.
- "The pre-commit hook is blocking on something unrelated" → either fix the underlying issue or remove the hook.
- "I'm bypassing the hook with `--no-verify` regularly" → the hook is wrong for your workflow. Fix or kill it.

A hook you routinely bypass is worse than no hook — it teaches you to ignore safety checks. Either repair it or remove it.

## TL;DR

- Hooks are how the system enforces "from now on, when X, do Y." Not CLAUDE.md, not memory.
- Use the `update-config` skill to write hooks correctly — don't memorize the schema.
- Highest-leverage starter set: TS check on edits, block commits on typecheck fail, allowlist read-only commands, block committing env files, notify on long-running completion.
- Hooks you don't trust or that you bypass routinely should be removed, not endured.
- Per-project hooks ship with the repo via `.claude/settings.json` — useful for client work.
