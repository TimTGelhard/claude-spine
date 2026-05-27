# Global Claude Code setup — install guide

This folder is the "global upgrade" — a curated `~/.claude/` setup. There are two variants:

- **`neutral/`** — a thin stub (~20 lines). Identity + pointer to the spine. The spine's `op-*` skills load discipline on-demand. **Recommended default.**
- **`opinionated/`** — a heavy, kitchen-sink CLAUDE.md (~260 lines) with stack defaults, security rules, verification gates, and stop conditions all baked in up front. Good if you want everything stated explicitly in the global rather than loaded on demand.

If you only want the spine's chapters and templates without touching `~/.claude/`, you can skip this folder entirely.

## What gets installed

| File | Installs to | What it does |
|------|-------------|--------------|
| `neutral/CLAUDE.md.template` (default) or `opinionated/CLAUDE.md.template` (with `--opinionated`) | `~/.claude/CLAUDE.md` | Global instructions every Claude Code session loads. |
| `settings.json` | `~/.claude/settings.json` | Permissions allowlist (so common commands don't prompt), env-file guard hook wiring, plugin enablement, default mode + theme. |
| `hooks/block-env-staging.sh` | `~/.claude/hooks/block-env-staging.sh` | Blocks `git add .env*` as defence-in-depth against secret leaks. Wired via `settings.json`. |
| `../skills/core/op-*` | `~/.claude/skills/op-*` (symlinked) | The core `op-*` skills. Symlinks so `git pull` in the spine updates them instantly. |
| `commands/*.md` | `~/.claude/commands/*.md` (symlinked) | Slash commands shipped by the spine — currently `/onboard` (personal-profile interview). |
| (the spine itself) | `~/.claude-spine` (symlinked) | A symlink so skill files can use `~/.claude-spine/...` paths regardless of where you cloned. |

## Install

From the spine root:

```bash
./install.sh                  # neutral global stub (default)
./install.sh --opinionated    # heavy template instead
./install.sh --dry-run        # show what would happen, change nothing
```

Existing `~/.claude/CLAUDE.md`, `settings.json`, and `~/.claude/hooks/block-env-staging.sh` are backed up to `~/.claude-backup-<timestamp>/` before being overwritten. The installer is idempotent — re-running it updates the symlinks and re-installs `settings.json` + hook + global stub from the spine.

### Flags

| Flag | Effect |
|------|--------|
| `--opinionated` | Install the heavy founder-flavored template instead of the neutral stub. |
| `--skip-global` | Don't touch `~/.claude/CLAUDE.md`. |
| `--skip-skills` | Don't create skill symlinks. |
| `--skip-commands` | Don't symlink slash commands into `~/.claude/commands/`. |
| `--skip-settings` | Don't overwrite `~/.claude/settings.json`. |
| `--skip-hook` | Don't install the env-leak hook. |
| `--dry-run` | Print what would happen; change nothing. |

### After install

1. **Restart Claude Code.** Close open sessions and start fresh.
2. **Run the onboarding interview.** First session will trigger `op-onboard` automatically when it notices no profile exists. Or invoke it yourself: `/onboard` for the 5-question essentials, `/onboard --deep` for the full ~15-question interview. The profile is written to `~/.claude/claude-spine-profile.md` and read every session afterward.
3. **If you installed the opinionated variant:** open `~/.claude/CLAUDE.md` and fill in the `{{placeholders}}` — name, intro line, stack defaults if they don't match yours.
4. **Review `~/.claude/settings.json`** — the allowlist is opinionated:
   - **WebFetch allowlist** pre-approves `docs.anthropic.com`, `nextjs.org`, `supabase.com`, `vercel.com`, `tailwindcss.com`, etc. Add your own framework's docs domain; remove any you'll never use.
   - **Bash allowlist** pre-approves `supabase`, `vercel`, `gh`, `lighthouse`, etc. Trim what you don't use; add `bundler`, `cargo`, `go`, etc. for your stack.
   - **enabledPlugins** — five plugins from the official marketplace. Disable any you don't want.
   - **effortLevel** is `xhigh` (quality over speed). Lower to `high` or `medium` for faster, cheaper turns.
   - **autoCompactWindow** is `800000` (auto-compact fires at 800K tokens). Tighten if compaction is too aggressive.

### Verify

In a fresh session, ask:

```
What's in my global CLAUDE.md? Summarize the section headings.
```

For the neutral stub, expect a short list (Where to look, Personalization, Project-level rules, Override hierarchy).
For the opinionated variant, expect a long list (Always-on, How to work with me, Decisions, First touch, Workflow operating model, Proactive signaling, Code output, Verification, ...).

Then:

```
List the op-* skills loaded.
```

Should show all 16 core skills: `op-foundations`, `op-workflow`, `op-collaboration-modes`, `op-brownfield`, `op-prompting`, `op-visuals`, `op-signaling`, `op-persistence`, `op-hooks`, `op-tools`, `op-subagents`, `op-recovery`, `op-anti-patterns`, `op-onboard`, `op-bucket-router`, `op-add-skill`.

Also verify the env-leak hook is wired:

```bash
echo '{"tool_input":{"command":"git add .env"}}' | ~/.claude/hooks/block-env-staging.sh
```

Should return a `deny` decision. If it errors, install `jq` (`brew install jq` on macOS).

## Customizing further

The opinionated `CLAUDE.md.template` is opinionated for solo-founder / MVP / agency work in TS / Next.js / Supabase. The structure is the point — keep the sections, rewrite the contents:

- **Stack defaults** → your actual stack
- **Stop conditions** → add anything your domain demands (HIPAA boundaries, payment ledger writes, etc.)
- **Anthropic API** → reflects defaults that work today; verify the model IDs are current when you read this
- **Forbidden** list → add to, don't remove

The spine chapters (especially `chapters/persistence/12b-claudemd.md` and `chapters/anti-patterns/`) explain the *why* behind these choices.

## Uninstall

```bash
rm ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/hooks/block-env-staging.sh
rm -rf ~/.claude/skills/op-*
rm ~/.claude/commands/onboard.md ~/.claude/commands/add-skill.md ~/.claude/commands/refresh-bucket.md
rm ~/.claude/claude-spine-profile.md   # the personal profile, if you want a clean slate
rm ~/.claude-spine   # only if it's a symlink — `ls -la ~/.claude-spine` to check
# Restore your backup:
# cp -a ~/.claude-backup-YYYYMMDD-HHMMSS/.claude/. ~/.claude/
```
