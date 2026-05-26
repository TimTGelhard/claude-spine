# Global Claude Code setup — install guide

This folder is the "global upgrade" — a curated `~/.claude/` setup distilled from real solo-founder / MVP / agency work. It's opinionated and battle-tested, but everything here is yours to edit.

> If you only want the manual chapters and templates, skip this folder. The manual works without any global config.

## What you get

| File | Installs to | What it does |
|------|-------------|--------------|
| `CLAUDE.md.template` | `~/.claude/CLAUDE.md` | Global instructions every Claude Code session loads. Sets tone, scope discipline, security baseline, verification rules, stop conditions. |
| `settings.json` | `~/.claude/settings.json` | Permissions allowlist (so common commands don't prompt), env-file guard hook, plugin enablement, default mode + theme. |
| `hooks/block-env-staging.sh` | `~/.claude/hooks/block-env-staging.sh` | Blocks `git add .env*` as defence-in-depth against secret leaks. Wired up via `settings.json`. |

## Before you install

These files will overwrite existing files in `~/.claude/`. If you already have a `CLAUDE.md` or `settings.json`, **back them up first**:

```bash
mkdir -p ~/.claude-backup-$(date +%Y%m%d)
cp -r ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/hooks ~/.claude-backup-$(date +%Y%m%d)/ 2>/dev/null || true
```

## Install — step by step

From the repo root (`claude-code-operators-manual/`):

### 1. CLAUDE.md — the personal one

```bash
mkdir -p ~/.claude
cp global/CLAUDE.md.template ~/.claude/CLAUDE.md
```

Now **open `~/.claude/CLAUDE.md`** and fill in:

- `{{YOUR NAME OR BUILD BOX}}` in the H1 — your handle, machine name, whatever.
- The intro paragraph with `{{ONE OR TWO LINES ABOUT YOU AND THIS MACHINE}}` — what kind of work this machine does.
- All `{{MANUAL_DIR}}` placeholders — replace with the absolute path where you cloned this repo (e.g. `/Users/yourname/dev/claude-code-operators-manual`).
- The **Stack defaults** section — the defaults assume a Next.js + Supabase + Vercel + Expo solo-builder. If you ship Django, Rails, Go, or anything else, rewrite this section. The discipline above and below it is stack-agnostic.

Quick sed for the manual path (macOS / Linux):

```bash
sed -i.bak "s|{{MANUAL_DIR}}|$(pwd)|g" ~/.claude/CLAUDE.md && rm ~/.claude/CLAUDE.md.bak
```

### 2. settings.json — permissions, hooks, plugins

```bash
cp global/settings.json ~/.claude/settings.json
```

Then look it over. Defaults that may not match you:

- **WebFetch allowlist** — pre-approves `docs.anthropic.com`, `nextjs.org`, `supabase.com`, `vercel.com`, `tailwindcss.com`, etc. Add your own framework's docs domain; remove any you'll never use.
- **Bash allowlist** — pre-approves `supabase`, `vercel`, `gh`, `lighthouse`, etc. Trim what you don't use; add `bundler`, `cargo`, `go`, etc. for your stack.
- **enabledPlugins** — five plugins from the official marketplace. Disable any you don't want. They install on first use; you don't need to install them upfront.
- **effortLevel** — `xhigh` favors quality over speed. Lower to `high` or `medium` if you want faster, cheaper turns.
- **autoCompactWindow** — `800000` means auto-compact fires at 800K tokens (out of 1M). Tighten if you find compaction is too aggressive.

### 3. The env-file guard hook

```bash
mkdir -p ~/.claude/hooks
cp global/hooks/block-env-staging.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/block-env-staging.sh
```

Verify it's wired:

```bash
echo '{"tool_input":{"command":"git add .env"}}' | ~/.claude/hooks/block-env-staging.sh
```

Should return a `deny` decision. If it errors, install `jq` (`brew install jq`).

### 4. Restart Claude Code

Close any open sessions and start fresh. New sessions will load your global `CLAUDE.md` and apply the settings.

## Verify

After install, open Claude Code and ask:

```
What's in my global CLAUDE.md? Summarise the section headings.
```

Claude should reply with the section list (How to work with me, Decisions, First touch, Workflow operating model, etc.). If it can't see them, the file isn't being loaded — check the path.

## Customising further

The shipped `CLAUDE.md` is opinionated for solo-founder / MVP / client work in TS / Next / Supabase. The structure is the point — keep the sections, rewrite the contents:

- **Stack defaults** → your actual stack
- **Stop conditions** → add anything your domain demands (HIPAA boundaries, payment ledger writes, etc.)
- **Anthropic API** → reflects defaults that work today; verify the model IDs are current when you read this
- **Forbidden** list → add to, don't remove

The manual chapters (especially `12-skills-memory-claudemd.md` and `18-anti-patterns.md`) explain the *why* behind these choices and what each section is for.

## Uninstall

```bash
rm ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/hooks/block-env-staging.sh
# Restore your backup if you made one:
# cp ~/.claude-backup-YYYYMMDD/* ~/.claude/
```
