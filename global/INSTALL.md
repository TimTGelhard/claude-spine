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
| `commands/*.md` | `~/.claude/commands/*.md` (symlinked) | Slash commands shipped by the spine: `/onboard` (personal-profile interview), `/suggest` + `/curate` (suggestion-capture + review), `/add-skill` + `/refresh-bucket` (personal skill-library management), and the plan-driven trio `/prep` + `/session-start` + `/session-end` (multi-session planning + cold-start-resistant execution). |
| (the spine itself) | `~/.claude-spine` (symlinked) | A symlink so skill files can use `~/.claude-spine/...` paths regardless of where you cloned. |

## Install

From the spine root:

```bash
./install.sh                  # neutral global stub (default)
./install.sh --opinionated    # heavy template instead
./install.sh --dry-run        # show what would happen, change nothing
```

`settings.json` and `~/.claude/hooks/block-env-staging.sh` are backed up to `~/.claude-backup-<timestamp>/` before being overwritten on every run. `~/.claude/CLAUDE.md` is treated more carefully: if its contents match an untouched shipped template (either variant) it gets overwritten with a backup; if it appears user-customized, it's **preserved** and the installer reports `preserved: ... appears user-customized`. Pass `--force-global` to overwrite anyway (the existing file is still backed up first). The installer is idempotent — re-running it updates the symlinks and re-installs `settings.json` + hook from the spine.

If you previously had the v1 `op-manual-*` skills installed, they're backed up and removed during install so they don't double-fire alongside the v2 `op-*` set. Pass `--keep-legacy` to leave them in place (e.g. for an A/B session).

### Flags

| Flag | Effect |
|------|--------|
| `--opinionated` | Install the heavy founder-flavored template instead of the neutral stub. |
| `--skip-global` | Don't touch `~/.claude/CLAUDE.md`. |
| `--skip-skills` | Don't create skill symlinks. |
| `--skip-commands` | Don't symlink slash commands into `~/.claude/commands/`. |
| `--skip-settings` | Don't overwrite `~/.claude/settings.json`. |
| `--skip-hook` | Don't install the env-leak hook. |
| `--keep-legacy` | Leave any pre-v2 `~/.claude/skills/op-manual-*` skills in place. By default they're backed up and removed because their trigger descriptions overlap with the v2 `op-*` set. |
| `--force-global` | Overwrite `~/.claude/CLAUDE.md` even if it appears user-customized. Existing file is still backed up. Default: preserve user-customized content. |
| `--dry-run` | Print what would happen; change nothing. |

### After install

1. **Restart Claude Code.** Close open sessions and start fresh.
2. **Run the onboarding interview.** First session will trigger `op-onboard` automatically when it notices no profile exists. Or invoke it yourself: `/onboard` for the 5-question essentials, `/onboard --deep` for the full ~15-question interview. The profile is written to `~/.claude/claude-spine-profile.md` and read every session afterward.

#### Plan-driven workflow (recommended for new projects)

The spine ships a plan-driven workflow that makes every session cold-start-resistant. The flow is:

```
new project:    init.sh  →  /prep  →  /session-start  →  build  →  /session-end  →  (close terminal)
next session:                          /session-start  →  build  →  /session-end
new section:                /prep <section>  →  /session-start  →  …
```

- **`./init.sh <project-path>`** — scaffolds `docs/` and `.claude/CLAUDE.md` in a project from spine templates. Idempotent — won't overwrite existing files. Run once per new project.
- **`/prep`** — one planning session that produces `docs/PROJECT_BRIEF.md`, `docs/ARCHITECTURE.md`, `docs/PROJECT_PLAN.md`, `docs/plans/<section-1>.md`, and an initialized `docs/PROGRESS.md`. No code this session. Run once at project start, then `/prep <section-name>` to plan each subsequent section just-in-time.
- **`/session-start`** — opens a fresh build session. Reads `PROGRESS.md` and the active session entry only (~1-2K tokens). Confirms scope with you. Refuses to write code until you say "yes / go / confirmed".
- **`/session-end`** — walks the verify list, updates the section plan + `PROGRESS.md`, stages changes, suggests a commit message. The user reviews and commits.

For projects that pre-date this workflow, the older `docs/SESSION_STARTER.md` paste-prompts still work — see that file for guidance on when to use which.
3. **If you installed the opinionated variant:** open `~/.claude/CLAUDE.md` and fill in the `{{placeholders}}` — name, intro line, stack defaults if they don't match yours.
4. **Review `~/.claude/settings.json`** — the allowlist is opinionated:
   - **WebFetch allowlist** pre-approves `docs.anthropic.com`, `nextjs.org`, `supabase.com`, `vercel.com`, `tailwindcss.com`, etc. Add your own framework's docs domain; remove any you'll never use.
   - **Bash allowlist** is opinionated for TS / Next.js / Supabase / Vercel stacks — pre-approves `supabase`, `vercel`, `gh`, `lighthouse`, etc. Remove what you don't use; add `bundler`, `cargo`, `go`, etc. for your stack.
   - **enabledPlugins** — five plugins from the official marketplace. Disable any you don't want.
   - **effortLevel** is `high` (opinionated but Pro-plan-safe). Raise to `xhigh` for deepest reasoning on Max 20x; lower to `medium` for faster, cheaper turns. See "Tuning for Max 20x / 1M context" below.
   - **autoCompactWindow** is `180000` (auto-compact fires at 180K tokens — sized for 200K-context models). Raise to `800000` if you have a 1M-context model. Same section below.

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

## Tuning for Max 20x / 1M context

The shipped defaults — `effortLevel: "high"` and `autoCompactWindow: 180000` — assume **Anthropic Pro plan on a 200K-context model**. Opinionated, but not aggressive on budget.

If you're on **Max 20x** and/or using a **1M-context model** (Opus 4.7 1M, Sonnet 4.6 1M), raise both in `~/.claude/settings.json`:

```json
"effortLevel": "xhigh",
"autoCompactWindow": 800000,
```

- `xhigh` runs Claude with the deepest reasoning — best for hard multi-file refactors and architecture work. Burns Pro budget fast; pays off on Max.
- `autoCompactWindow: 800000` defers auto-compaction until 800K tokens, exploiting the 1M window. Wasted on a 200K model — the window itself will force compaction sooner.

Restart Claude Code after changing.

## Customizing further

The opinionated `CLAUDE.md.template` is opinionated for solo-founder / MVP / agency work in TS / Next.js / Supabase. The structure is the point — keep the sections, rewrite the contents:

- **Stack defaults** → your actual stack
- **Stop conditions** → add anything your domain demands (HIPAA boundaries, payment ledger writes, etc.)
- **Anthropic API** → reflects defaults that work today; verify the model IDs are current when you read this
- **Forbidden** list → add to, don't remove

The spine chapters (especially `chapters/persistence/12b-claudemd.md` and `chapters/anti-patterns/`) explain the *why* behind these choices.

## Uninstall

From the spine root:

```bash
./uninstall.sh             # remove what install.sh installed
./uninstall.sh --dry-run   # show what would be removed
```

It removes only what the spine installs — the `~/.claude/skills/op-*` symlinks that resolve into this clone, the `~/.claude/commands/*.md` symlinks the spine added, `~/.claude/hooks/block-env-staging.sh`, and `~/.claude-spine` (only when it's a symlink).

It deliberately leaves user data alone:

- `~/.claude/CLAUDE.md` — you may have edited it.
- `~/.claude/settings.json` — same.
- `~/.claude/claude-spine-profile.md` — your onboarding profile.
- `bucket/` inside the spine — your bucket skills.

To restore the originals install.sh backed up, look in `~/.claude-backup-<timestamp>/` and `cp -a` the bits you want back. To drop the listed user data too, `rm` them by hand.
