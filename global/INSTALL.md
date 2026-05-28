# Global Claude Code setup — install guide

This folder is the "global upgrade" — a curated `~/.claude/` setup. Two flavours:

- **`neutral/`** — a thin stub (~25 lines). Identity + pointer to the spine. The spine's `op-*` skills load discipline on-demand. **Recommended default.**
- **`stacks/<name>/`** — heavy per-stack CLAUDE.md templates (~250 lines each) with stack defaults, security rules, verification gates, and stop conditions baked in. Good if you want everything stated explicitly in the global rather than loaded on demand. Pick the one closest to your stack with `--stack=<name>`.
  - `stacks/ts-next-supabase/` — TypeScript + Next.js + Supabase + Stripe + Vercel.
  - `stacks/python-django/` — Python + Django + DRF + Postgres + Celery.
  - Add your own: drop `global/stacks/<your-name>/CLAUDE.md.template` and pass `--stack=<your-name>`.

If you only want the spine's chapters and templates without touching `~/.claude/`, you can skip this folder entirely.

## What gets installed

| File | Installs to | What it does |
|------|-------------|--------------|
| `neutral/CLAUDE.md.template` (default) or `stacks/<name>/CLAUDE.md.template` (with `--stack=<name>`) | `~/.claude/CLAUDE.md` | Global instructions every Claude Code session loads. |
| `settings.json` | `~/.claude/settings.json` | Permissions allowlist (so common commands don't prompt), env-file guard hook wiring, plugin enablement, default mode + theme. |
| `hooks/*.sh` | `~/.claude/hooks/*.sh` | `block-env-staging.sh` blocks `git add .env*` as defence-in-depth against secret leaks. `spine-writeback.sh` is a Stop hook that logs a per-turn heartbeat in plan-driven projects. Both wired via `settings.json`. |
| `../skills/core/op-*` | `~/.claude/skills/op-*` (symlinked) | The core `op-*` skills. Symlinks so `git pull` in the spine updates them instantly. |
| `commands/*.md` | `~/.claude/commands/*.md` (symlinked) | Slash commands shipped by the spine: `/onboard` (personal-profile interview), `/suggest` + `/curate` (suggestion-capture + review), `/add-skill` + `/refresh-bucket` (personal skill-library management), and the plan-driven flow `/prep` + `/done` (planning + session writeback). |
| (the spine itself) | `~/.claude-spine` (symlinked) | A symlink so skill files can use `~/.claude-spine/...` paths regardless of where you cloned. |

## Install

From the spine root:

```bash
./install.sh                              # neutral global stub (default)
./install.sh --stack=ts-next-supabase     # heavy TS / Next.js / Supabase template
./install.sh --stack=python-django        # heavy Python / Django template
./install.sh --opinionated                # alias for --stack=ts-next-supabase (backward compat)
./install.sh --dry-run                    # show what would happen, change nothing
```

`settings.json` and `~/.claude/hooks/block-env-staging.sh` are backed up to `~/.claude-backup-<timestamp>/` before being overwritten on every run. `~/.claude/CLAUDE.md` is treated more carefully: if its contents match an untouched shipped template (either variant) it gets overwritten with a backup; if it appears user-customized, it's **preserved** and the installer reports `preserved: ... appears user-customized`. Pass `--force-global` to overwrite anyway (the existing file is still backed up first). The installer is idempotent — re-running it updates the symlinks and re-installs `settings.json` + hook from the spine.

If you previously had the v1 `op-manual-*` skills installed, they're backed up and removed during install so they don't double-fire alongside the v2 `op-*` set. Pass `--keep-legacy` to leave them in place (e.g. for an A/B session).

### Flags

| Flag | Effect |
|------|--------|
| `--stack=<name>` | Install the heavy stack-flavored template from `global/stacks/<name>/CLAUDE.md.template` instead of the neutral stub. Shipped: `ts-next-supabase`, `python-django`. |
| `--opinionated` | Backward-compat alias for `--stack=ts-next-supabase`. |
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
2. **Run the onboarding interview.** First session, `op-welcome` greets you and points at `/onboard`. Invoke it yourself: `/onboard` for the 10-question essentials, `/onboard --deep` for the full ~28-question interview (essentials + 18 deep + 2 opt-in hook prompts). The profile is written to `~/.claude/claude-spine-profile.md` and read every session afterward.

#### Plan-driven workflow (recommended for new projects)

The spine ships a plan-driven workflow that makes every session cold-start-resistant. The **default is ambient** — most of the ceremony happens automatically:

```
new project:    /prep                          # auto-scaffolds + brief + plan in one command
next session:   (open Claude)   →   build   →   /done
new section:    /prep <section>  →   build   →   /done
```

How the ambient default works:

- **`/prep`** — one slash command. Step 0 auto-runs `init.sh` if `docs/` doesn't exist, then walks brief → product-shape → architecture → master plan → first section. Output: plan files in `docs/`. No code this session. Run `/prep <section-name>` later to plan each subsequent section just-in-time.
- **`op-spine-active`** — auto-firing skill. At the start of any conversation in a plan-driven project (cwd contains `docs/plans/` + `docs/PROGRESS.md`), silently loads `PROGRESS.md` + the active session entry, announces scope in 3-4 lines, then proceeds to build. No confirmation gate.
- **`spine-writeback.sh`** — Stop hook wired via `settings.json`. After every assistant turn, appends a one-line heartbeat to the active section's `## Session log` block recording which files changed. Idempotent (skips repeats), silent no-op outside plan-driven dirs, never blocks Claude on failure.
- **`/done`** — explicit session-complete. Walks the verify list, rolls up heartbeats into one PROGRESS.md log entry, advances the PROGRESS pointer, stages doc changes, suggests a commit message. You review the diff and commit.

##### Need a hard code-gate?

For safety-critical sessions (regulated work, paired review, anything where you want to read scope before any code), use Claude Code's built-in plan mode (Shift+Tab Tab). It refuses tool calls until you approve the plan — generic across all work, no separate command to memorize.

For projects that pre-date this workflow, the older `docs/SESSION_STARTER.md` paste-prompts still work — see that file for guidance on when to use which.
3. **If you installed a `--stack=<name>` variant:** open `~/.claude/CLAUDE.md` and fill in the `{{placeholders}}` — name, intro line, stack defaults if they don't match yours.
4. **Review `~/.claude/settings.json`** — the allowlist is shipped neutral but you can prune further:
   - **WebFetch allowlist** pre-approves the major language / framework docs (Anthropic, MDN, Python, Django, FastAPI, Go, Rust, Ruby, PHP, Java, Kotlin, Swift, etc.). Add your own framework's domain; remove any you'll never use.
   - **Bash allowlist** pre-approves the common build / package tools across the major ecosystems (`npm`, `pip`, `cargo`, `go`, `mvn`, `bundle`, `composer`, `dotnet`, etc.) plus the spine's stack-tooling defaults (`supabase`, `vercel`, `gh`, `lighthouse`). Remove what you don't use; add anything your stack relies on.
   - **enabledPlugins** — `skill-creator` and `github` ship on by default. Stack-specific plugins (`vercel`, `playwright`, `frontend-design`) ship off by default — enable per-stack only when you actually need them.
   - **effortLevel** is `high` (opinionated but Pro-plan-safe). Raise to `xhigh` for deepest reasoning on Max 20x; lower to `medium` for faster, cheaper turns. See "Tuning for Max 20x / 1M context" below.
   - **autoCompactWindow** is `180000` (auto-compact fires at 180K tokens — sized for 200K-context models). Raise to `800000` if you have a 1M-context model. Same section below.

### Verify

In a fresh session, ask:

```
What's in my global CLAUDE.md? Summarize the section headings.
```

For the neutral stub, expect a short list (Where to look, Personalization, Project-level rules, Override hierarchy).
For a `--stack=<name>` variant, expect a long list (Always-on, How to work with me, Decisions, First touch, Workflow operating model, Proactive signaling, Code output, Verification, …).

Then:

```
List the op-* skills loaded.
```

Should show the spine's core `op-*` skills, including the ambient `op-spine-active` (auto-fires in plan-driven projects) and the planning skill `op-prepare`. The list grows over time — what matters is that none of the v1 `op-manual-*` skills are present alongside them.

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

Every stack-flavored `CLAUDE.md.template` under `global/stacks/<name>/` is opinionated for the named stack — its concrete advice doesn't translate verbatim to other stacks. The shape (Always-on / How to work with me / Decisions / Workflow / Signaling / Code output / Security / Stack defaults / Project conventions) IS the lesson; rewrite the contents to match your project:

- **Stack defaults** → your actual stack.
- **Stop conditions** → add anything your domain demands (HIPAA boundaries, payment ledger writes, etc.).
- **Anthropic API** → reflects defaults that work today; verify the model IDs are current when you read this.
- **Forbidden** list → add to, don't remove.

To ship a new stack variant: copy an existing one to `global/stacks/<your-name>/CLAUDE.md.template`, rewrite the stack-specific sections, then pass `--stack=<your-name>` at install time. Upstream PRs welcome for any major-stack template not already covered.

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
