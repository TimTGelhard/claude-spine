# Global Claude Code setup — install guide

This folder is the "global upgrade" — a curated `~/.claude/` setup. Two flavours:

- **`neutral/`** — a thin stub (~25 lines). Identity + pointer to the spine. The spine's `op-*` skills load discipline on-demand. **Recommended default.**
- **`stacks/<name>/`** — per-stack flavor pair, picked with `--stack=<name>`:
  - `stacks/<name>/CLAUDE.md.template` (~40 lines) — thin always-on stub. Eight rules the user most regrets Claude forgetting + pointer to the rest.
  - `stacks/<name>/flavor-skill/SKILL.md` (~170–240 lines) — heavy stack discipline (how-to-work, decisions, first-touch, workflow, signaling, code output, verification, debugging, stop conditions, stack defaults, full security non-negotiables, project conventions). Installed as `~/.claude/skills/op-stack-flavor/SKILL.md`; loads on-demand when stack-relevant work, security questions, or "is this done?" moments fire.
  - The split follows the "thin CLAUDE.md, fat skills" pattern the spine itself teaches (`chapters/persistence/12b-claudemd.md`) — every-session tokens go to the rules that need to be always-on; everything else stays on-demand.
  - Shipped stacks:
    - `stacks/ts-next-supabase/` — TypeScript + Next.js + Supabase + Stripe + Vercel.
    - `stacks/python-django/` — Python + Django + DRF + Postgres + Celery.
  - Add your own: drop both `global/stacks/<your-name>/CLAUDE.md.template` and `global/stacks/<your-name>/flavor-skill/SKILL.md`, then pass `--stack=<your-name>`. Both files must be present — the installer validates and refuses an unpaired stack.

If you only want the spine's chapters and templates without touching `~/.claude/`, you can skip this folder entirely.

## What gets installed

| File | Installs to | What it does |
|------|-------------|--------------|
| `neutral/CLAUDE.md.template` (default) or `stacks/<name>/CLAUDE.md.template` (with `--stack=<name>`) | `~/.claude/CLAUDE.md` | Global instructions every Claude Code session loads. |
| `stacks/<name>/flavor-skill/` (only with `--stack=<name>`) | `~/.claude/skills/op-stack-flavor/` (symlinked) | On-demand depth behind the thin CLAUDE.md — full stack discipline, security non-negotiables, verification + stop conditions. Neutral installs ship no flavor skill. |
| `settings.json` | `~/.claude/settings.json` | Permissions allowlist (so common commands don't prompt), env-file guard hook wiring, plugin enablement, default mode + theme. |
| `hooks/*.sh` | `~/.claude/hooks/*.sh` | `block-env-staging.sh` blocks `git add .env*` as defence-in-depth against secret leaks. `spine-writeback.sh` is a Stop hook that logs a per-turn heartbeat in plan-driven projects. Both wired via `settings.json`. |
| `../skills/core/op-*` | `~/.claude/skills/op-*` (symlinked) | The core `op-*` skills. Symlinks so `git pull` in the spine updates them instantly. |
| `commands/*.md` | `~/.claude/commands/*.md` (symlinked) | Slash commands shipped by the spine: `/onboard` (personal-profile interview), `/suggest` + `/curate` (suggestion-capture + review), `/add-skill` + `/refresh-bucket` (personal skill-library management), and the plan-driven flow `/prep` + `/done` (planning + session writeback). |
| (the spine itself) | `~/.claude-spine` (symlinked) | A symlink so skill files can use `~/.claude-spine/...` paths regardless of where you cloned. |

## Install

From the spine root:

```bash
./install.sh                              # neutral global stub (default)
./install.sh --stack=ts-next-supabase     # thin TS / Next.js / Supabase CLAUDE.md + op-stack-flavor skill
./install.sh --stack=python-django        # thin Python / Django CLAUDE.md + op-stack-flavor skill
./install.sh --opinionated                # alias for --stack=ts-next-supabase (backward compat)
./install.sh --dry-run                    # show what would happen, change nothing
```

`settings.json` and `~/.claude/hooks/block-env-staging.sh` are backed up to `~/.claude-backup-<timestamp>/` before being overwritten on every run. `~/.claude/CLAUDE.md` is treated more carefully: if its contents match an untouched shipped template (either variant) it gets overwritten with a backup; if it appears user-customized, it's **preserved** and the installer reports `preserved: ... appears user-customized`. Pass `--force-global` to overwrite anyway (the existing file is still backed up first). The installer is idempotent — re-running it updates the symlinks and re-installs `settings.json` + hook from the spine.

If you previously had the v1 `op-manual-*` skills installed, they're backed up and removed during install so they don't double-fire alongside the v2 `op-*` set. Pass `--keep-legacy` to leave them in place (e.g. for an A/B session).

### Flags

| Flag | Effect |
|------|--------|
| `--stack=<name>` | Install the thin stack-flavored CLAUDE.md from `global/stacks/<name>/CLAUDE.md.template` AND the matching `op-stack-flavor` skill from `global/stacks/<name>/flavor-skill/` instead of the neutral stub. Shipped: `ts-next-supabase`, `python-django`. |
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
2. **Run the onboarding interview.** First session, `op-welcome` greets you and points at `/onboard`. Invoke it yourself: `/onboard` for the 10-question essentials, `/onboard --deep` for the full ~28-question interview (essentials + 18 deep + 2 opt-in hook prompts; +2 conditional follow-ups when your artifact is a UI app — Section W). The profile is written to `~/.claude/claude-spine-profile.md` and read every session afterward.

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
3. **If you installed a `--stack=<name>` variant:** open `~/.claude/CLAUDE.md` and fill in the `{{placeholders}}` — name, intro line. Stack defaults are now in the `op-stack-flavor` skill at `global/stacks/<name>/flavor-skill/SKILL.md`; edit them there if they don't match yours.
4. **Review `~/.claude/settings.json`** — the allowlist is shipped neutral but you can prune further:
   - **WebFetch allowlist** pre-approves the broad-language docs (Anthropic, MDN, Python, Go, Rust, Ruby, PHP, Java, Kotlin, Swift, etc.). Stack-specific docs (Next.js, Supabase, Vercel, Django, FastAPI, cloud providers) are **not** in the neutral default — merge a `settings-extras/+*-stack.json` fragment to add them, or hand-edit.
   - **Bash allowlist** pre-approves the common build / package tools across the major ecosystems (`npm`, `pip`, `cargo`, `go`, `mvn`, `bundle`, `composer`, `dotnet`, etc.) plus `gh` and `lighthouse`. Stack-specific CLIs (`supabase`, `vercel`, `aws`, `gcloud`, `az`, `docker`, etc.) are **not** in the neutral default — merge the matching `settings-extras/+*-stack.json` fragment via `/onboard --deep` (or by hand) to add them. Remove what you don't use; add anything your stack relies on.
   - **enabledPlugins** — `skill-creator` and `github` ship on by default. Stack-specific plugins (`vercel`, `playwright`, `frontend-design`) ship off by default — enable per-stack only when you actually need them.
   - **effortLevel** is `medium` (Free-class default — fewer tokens per turn, so Free users don't burn the daily limit on day one). `/onboard` raises this automatically based on Q1 (subscription): Pro / Max 5× / Team / Enterprise / API → `high`; Max 20× → `xhigh`. See "Tuning per plan" below for the hand-tune mapping.
   - **autoCompactWindow** is `120000` (Free-class default — auto-compact fires at 120K tokens, comfortable for the 200K-context models on Free). `/onboard` raises this to `180000` (Pro / Max 5×), `400000` (Enterprise / API), or `800000` (Max 20×) per Q1. Same section below.
   - **Optional stack/VCS extras**: drop-in JSON fragments at `~/.claude-spine/global/settings-extras/+<name>.json` add allowlist entries for specific stacks (Vercel, Supabase, AWS, GCP, Azure, Docker/k8s) and non-GitHub VCS hosts (GitLab, Bitbucket). Merge what you need — see `global/settings-extras/README.md` for the `jq` merge command. The fragments are never auto-merged; you opt in by hand.
   - **Write surface is broad by default.** The shipped allow rules include `Write(**)` and `Edit(**)`; the deny list catches `.env*`, `**/credentials.json`, `**/*_secret*`, `**/*token*`, but anything else under `~` (e.g. `~/.zshrc`, `~/.ssh/config`) is writable. The harness relies on the "Executing actions with care" framing in `CLAUDE.md` + your own review of proposed actions. Tighten the allow rules if you want a stricter write surface.

### Verify

In a fresh session, ask:

```
What's in my global CLAUDE.md? Summarize the section headings.
```

For the neutral stub, expect a short list (Where to look, Personalization, Project-level rules, Override hierarchy).
For a `--stack=<name>` variant, expect a short list too — only Always-on, Where the rest lives, Override hierarchy. The heavy content (How to work with me / Decisions / First touch / Workflow / Signaling / Code output / Verification / Debugging / Stop conditions / Stack defaults / Security / Project conventions) now lives in the `op-stack-flavor` skill and loads on-demand.

Then:

```
List the op-* skills loaded.
```

Should show the spine's core `op-*` skills, including the ambient `op-spine-active` (auto-fires in plan-driven projects) and the planning skill `op-prepare`. If you installed with `--stack=<name>`, you should also see `op-stack-flavor` in the list. None of the v1 `op-manual-*` skills should be present alongside them.

Also verify the env-leak hook is wired:

```bash
echo '{"tool_input":{"command":"git add .env"}}' | ~/.claude/hooks/block-env-staging.sh
```

Should return a `deny` decision. If it errors, install `jq` (`brew install jq` on macOS).

## Tuning per plan

The shipped defaults — `effortLevel: "medium"` and `autoCompactWindow: 120000` — are **Free-class**: conservative so a Free user doesn't burn the daily limit on day one. `/onboard` proposes a raise based on your subscription answer (Q1) and writes the right values for you. If you skipped onboarding, set them by hand:

| Plan | `effortLevel` | `autoCompactWindow` |
|---|---|---|
| **Free** | `medium` | `120000` (ship default — leave alone) |
| **Pro** | `high` | `180000` |
| **Max (5×)** | `high` | `180000` |
| **Team / Enterprise** | `high` | `180000` / `400000` |
| **API / Bedrock / Vertex / OpenRouter** | `high` | `400000` |
| **Max (20×)** with a 1M-context model | `xhigh` | `800000` |

What the levers do:

- `effortLevel` controls how much reasoning Claude does per response. `medium` is the cost-conscious default; `high` deepens reasoning; `xhigh` is the deepest setting — only worth it when your plan covers the extra cost.
- `autoCompactWindow` controls how full the conversation gets before Claude auto-compresses earlier messages. Raising it lets you stay in one session longer without losing context — safe on plans with bigger context windows. Wasted on a 200K-context model (the window itself forces compaction sooner).

Restart Claude Code after changing.

## Customizing further

Every stack-flavored pair under `global/stacks/<name>/` is opinionated for the named stack — its concrete advice doesn't translate verbatim to other stacks. The two-file shape IS the lesson:

- `CLAUDE.md.template` (~40 lines) — only the must-always-load rules. Eight numbered points + the pointer to the rest.
- `flavor-skill/SKILL.md` (~170–240 lines) — How to work with me / Decisions / First touch / Workflow / Signaling / Code output / Verification / Debugging / Stop conditions / Stack defaults / Security / Project conventions. Loaded on-demand by Claude when stack-relevant work or questions fire.

Rewrite the contents to match your project:

- **Stack defaults** (in the skill) → your actual stack.
- **Stop conditions** (in the skill) → add anything your domain demands (HIPAA boundaries, payment ledger writes, etc.).
- **Anthropic API** (in the skill) → reflects defaults that work today; verify the model IDs are current when you read this.
- **Forbidden** list (in the skill) → add to, don't remove.
- **Always-on block** (in CLAUDE.md) → only edit if you really want a rule loaded every session. The default eight points are the user's "I most regret you forgetting" list.

To ship a new stack variant: copy an existing pair to `global/stacks/<your-name>/{CLAUDE.md.template,flavor-skill/SKILL.md}`, rewrite the stack-specific sections, then pass `--stack=<your-name>` at install time. Both files must be present — the installer validates and refuses an unpaired stack. Upstream PRs welcome for any major-stack template not already covered.

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
