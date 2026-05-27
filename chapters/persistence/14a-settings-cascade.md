# 14a — Settings cascade: where settings live

Claude Code reads several `settings.json` files. They cascade narrowest-wins (except security, which doesn't loosen).

## The four locations

| Location | Scope | Use for |
|---|---|---|
| `~/.claude/settings.json` | Global — every project on this machine | Machine-wide habits, default permissions, global hooks |
| `~/.claude/settings.local.json` | Global, local-machine override, gitignored | Personal overrides that shouldn't leave this machine |
| `<project>/.claude/settings.json` | Project — shared via git | Project-specific rules, ships with the repo |
| `<project>/.claude/settings.local.json` | Project, local-only, gitignored | Per-machine overrides for this project |

For solo MVP work: global settings for machine-wide habits, project settings for project-specific rules. Local files are for personal overrides you don't want to ship.

## What settings.json controls

Three main categories:

1. **Hooks** — shell commands the harness runs on events (file edit, pre-commit, command completion). See [14b](14b-hook-recipes.md).
2. **Permissions** — which tools and commands need approval, which are auto-allowed, which are denied.
3. **Environment + behavior** — env vars, default model, statusline, etc.

## Don't hand-edit from memory

The schema shifts between Claude Code versions. Hook event names, permission field shapes — all moving targets. Use the `update-config` skill — it knows the current schema and writes changes correctly.

> "Add a hook to run `npm run typecheck` after any TypeScript edit, in this project only."

The skill picks the right file (global vs project), the right event name, and the right shape.

## Permissions in particular

Settings.json controls which tools auto-run vs ask for approval:

- **Allowlist read-only commands** — `git status`, `git diff`, `ls`, `npm ls`, etc. Reduces "approve this tool call" prompts massively. Use the `fewer-permission-prompts` skill to auto-generate one from your patterns.
- **Deny dangerous commands by default** — `rm -rf`, `git push --force`, etc. Force explicit approval each time even if other Bash usage is allowlisted.
- **Per-project allowances** — a project that needs `supabase` commands frequently can have them allowlisted in its `.claude/settings.json` without affecting other projects.

## Cascade in practice

If global `settings.json` allows `git status` and project `settings.json` denies it, the project rule wins (narrower scope). Exception: security-relevant denials don't get overridden — you can't loosen a global "deny `rm -rf`" from a project file.

## Keybindings

Less critical, but if you have repeated keystroke patterns, `~/.claude/keybindings.json` lets you customize. The `keybindings-help` skill walks through it. Useful for: chord shortcuts (e.g. `Ctrl+G, Ctrl+S` for "git status"), rebinding submit/cancel, custom commands you run constantly.

## TL;DR

- Four settings files: global, global-local, project, project-local. Narrower wins.
- Hooks, permissions, behavior — all live here.
- Use the `update-config` skill to edit, not hand-editing.
- Allowlist read-only commands (via `fewer-permission-prompts`) for fewer prompts.
