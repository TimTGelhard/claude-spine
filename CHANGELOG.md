# Changelog

All notable changes to **claude-spine** are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/spec/v2.0.0.html).

`git pull` is the update mechanism — there is no package registry. New entries land at the top.

---

## [Unreleased]

### L10 — Ambient workflow refactor

Plan-driven workflow shifts from explicit ceremony (`/session-start` → `/session-end`) to an ambient default where boundary work happens automatically. Original goals (cold-start resistance, scope discipline, multi-session continuity) preserved; legacy commands kept as escape hatches.

#### Added

- `skills/core/op-spine-active/` — auto-firing skill. At the start of any conversation in a directory containing `docs/plans/` + `docs/PROGRESS.md`, loads the active session entry, announces scope in 3-4 lines, and proceeds to build. Ambient replacement for `/session-start`.
- `global/hooks/spine-writeback.sh` — Stop hook. After every assistant turn, appends a one-line heartbeat to the active section's `## Session log` block recording which files changed. Idempotent (skips repeats sans timestamp), graceful (silent no-op outside plan-driven dirs, never blocks Claude on failure).
- `global/commands/done.md` — `/done` command. Walks the verify list, rolls up heartbeats into one PROGRESS.md log entry, advances the PROGRESS pointer, stages doc changes, suggests a commit message. Primary writeback command in the ambient flow.

#### Changed

- `global/commands/prep.md` — added Step 0: auto-runs `~/.claude-spine/init.sh .` if `docs/` doesn't exist. Removes the manual shell step before opening Claude on a new project.
- `global/commands/session-start.md` — top note marks it as **legacy / power-user**. Same gated protocol; default is now ambient. Use this when you explicitly need a "no code until you say go" gate.
- `global/commands/session-end.md` — top note marks it as **legacy alias for `/done`**. Same writeback protocol.
- `global/settings.json` — wires the Stop hook (`spine-writeback.sh`); adds `Bash(*claude-spine/init.sh:*)` to the allow list so `/prep` Step 0 doesn't prompt.
- `install.sh` — hook installer refactored to loop over `global/hooks/*.sh` (was hardcoded single-file). Picks up `spine-writeback.sh` automatically; future hooks land without installer changes.
- `global/INSTALL.md` — "Plan-driven workflow" rewritten with ambient default; explicit-command flow moved to a "Power-user / explicit mode" subsection.
- `README.md` — slash-commands table updated: `/done` added; `/session-start` + `/session-end` marked legacy; status blurb mentions ambient flow.

### Pre-launch gates

Remaining gates before public launch (tracked in [`LAUNCH.md`](LAUNCH.md)):

- **L4c** — token-efficiency benchmark (spine-on vs spine-off) for demo numbers.
- **L7a / L7c / L7d / L7e** — landing-page hardening (built CSS, OG image, waitlist wiring), demo recording, public launch.

Internal cleanup tracked in [`docs/JANITOR.md`](docs/JANITOR.md): `PERSONALIZATION.md` retirement, `EXPLAINER.md` pricing-language reframe, and the deferred `install.sh` polish from L4c.

---

## [0.9.0] — 2026-05-27

First tagged release. Architecture frozen, personalization loop shipped, plan-driven workflow shipped, clean-room install verified, self-tests passing. Awaiting public launch (L7a / L7c / L7d / L7e).

### Added

#### v2 architecture

- **80 atomic chapter files** under `chapters/<topic>/`, one concept per file (~150-line ceiling, real-seam decomposition). Index at [`INDEX.md`](INDEX.md); inverse map at [`V1-CHAPTERS-DEPRECATED.md`](V1-CHAPTERS-DEPRECATED.md).
- **19 core skills** in `skills/core/op-*/` — pure routers from task intent to the right atomic file(s). None hold chapter content; SKILL.md bodies stay 34–65 lines. `op-prepare` and `op-curate` are folder skills (router `SKILL.md` + adjacent procedure file) when the procedure runs long.
- **5 personalization chapters** (`chapters/personalization/19a`–`19e`) — net-new in v2.
- **Plan-driven workflow.** Adds `skills/core/op-prepare/SKILL.md` + three new workflow chapters (`05h-multi-session-planning.md`, `05i-execution-plan-anatomy.md`, `05j-cold-start-protocol.md`) + three new templates (`PROJECT_PLAN.md`, `SECTION_PLAN.md`, `PROGRESS.md`) + three slash commands (`/prep`, `/session-start`, `/session-end`) + `init.sh` to scaffold project docs from templates.

#### Personalization loop

- `op-onboard` — first-run interview, writes `~/.claude/claude-spine-profile.md` (5 essentials + opt-in `/onboard --deep` for the full set). Re-runnable via `/onboard` or `/onboard --deep`.
- `op-suggest` + `/suggest` — capture friction during normal sessions to `bucket/SUGGESTIONS.md`. Locked four-condition trigger (explicit user signal, 2+ repeat friction, end-of-session reflection, explicit command).
- `op-curate` + `/curate` + `/curate --review-stale` — review pending suggestions, apply or reject, with hard refusals on `chapters/`, `skills/core/`, profile, and global stub.

#### Personal skill library ("the bucket")

- `bucket/` ships empty by design. Each user builds their own library.
- `op-add-skill` + `/add-skill` — gated skill-creation (3+-paste-in rule from [`13d-skill-anti-patterns.md`](chapters/persistence/13d-skill-anti-patterns.md)).
- `op-bucket-router` — fallback router. Reads `bucket/INDEX.md` (auto-maintained) only when no core skill matched.
- `/refresh-bucket` — rebuilds `bucket/INDEX.md` from disk; preserves `Added` dates.

#### Installer + global

- `install.sh` — self-locating, idempotent, backs up overwritten files to `~/.claude-backup-<ts>/`. Symlinks `~/.claude/skills/op-*` → `<spine>/skills/core/op-*` so `git pull` propagates instantly. Flags: `--dry-run`, `--opinionated`, `--keep-legacy`, `--skip-{global,skills,commands,settings,hook}`. macOS + Linux; Windows redirected to WSL.
- `uninstall.sh` — removes spine-owned symlinks only. Leaves `CLAUDE.md`, `claude-spine-profile.md`, `bucket/`, and `settings.json` in place.
- `global/neutral/CLAUDE.md.template` — thin stub (default install).
- `global/opinionated/CLAUDE.md.template` — founder-flavored example (`./install.sh --opinionated`).
- `global/settings.json` — `effortLevel: "high"`, `autoCompactWindow: 180000`, opinionated `permissions.allow` (TS / Next.js / Supabase / Vercel — trim to fit your stack).
- `global/hooks/block-env-staging.sh` — denies `git add .env*` patterns via the PreToolUse hook protocol.

#### Tests + CI

- `tests/hooks/test-block-env-staging.sh` — 12-case fixture (6 should-block, 6 should-allow).
- `tests/installer/test-dry-run.sh` — 48-assertion sweep across 7 install scenarios (default, `--opinionated`, legacy cleanup, `--keep-legacy`, every `--skip-*`, `--help`, unknown-flag rejection). Isolates `HOME` to a temp dir.
- `tests/skill-triggers/` — skill-description benchmark harness using the `skill-creator` plugin. Documented bias toward under-counting routing-skill TP; reliable for FP regression detection.
- `.github/workflows/test.yml` — runs the fast suites (hook + installer) on push to `main` and on pull requests.

#### Documentation

- `README.md` — public-facing entry point (install → first session → architecture).
- `INDEX.md` — atomic-file router map (topic → file).
- `V1-CHAPTERS-DEPRECATED.md` — inverse map (v1 chapter → v2 atomic files).
- `CONTRIBUTING.md` — single-maintainer policy, what's welcome / unlikely, commit style.
- `EXPLAINER.md` — long-form architecture for skeptics.
- `RECONSTRUCTION.md` — v2 build history (Phases 0–8e), frozen architectural decisions.
- `docs/archive/PERSONALIZATION-plan-2026-05.md` — personalization loop design (Phase 8 planning doc, archived 2026-05-27 once the loop shipped).
- `LAUNCH.md` — gap-fixing roadmap from v2 to public launch.
- 9 project-doc templates under `templates/` (project CLAUDE.md, PROGRESS.md, DECISIONS.md, FEATURES.md, ARCHITECTURE.md, PROJECT_BRIEF.md, SMOKE_TESTS.md, DEPLOY.md, SESSION_STARTER.md).

### Changed

- 18 root-level v1 chapter files (`01-first-principles.md` through `18-anti-patterns.md`) are now one-line redirect stubs pointing at the v2 atomic location and at the archived body in [`docs/v1-archive/`](docs/v1-archive/). Bodies preserved for external-link compatibility but moved one folder deeper so the repo root no longer carries 18 deprecation-header files. New work should read the v2 atomic files in `chapters/`.
- The four legacy `op-manual-*` skills (`op-manual-workflow`, `op-manual-tactics`, `op-manual-templates`, `op-manual-recovery`) are superseded by the 18 `op-*` skills. `install.sh` removes the legacy directories from `~/.claude/skills/` and backs them up; `--keep-legacy` opts out.
- `global/settings.json` defaults — `effortLevel` `"xhigh"` → `"high"` and `autoCompactWindow` `800000` → `180000`. The Pro-burning defaults were never the right floor; Max-plan users opt up via the new "Tuning for Max 20x / 1M context" section in `global/INSTALL.md`.
- 14 skill descriptions previously referenced "Claude Code Operator's Manual" (the pre-v2 project name) → swept to `claude-spine`. Cross-references in `op-anti-patterns`, `op-subagents`, `op-persistence`, `op-signaling` to the old `op-manual-*` skill names → swept to current names (or to direct template-folder pointers in the `op-persistence` case).
- `chapters/anti-patterns/18f-security.md` rewritten to be self-contained — no longer references "your global CLAUDE.md" for the forbidden list. `chapters/foundations/04c-budget-and-cost.md` now points at 18f directly. A neutral-stub installer no longer hits a dead reference.

### Fixed

- `global/hooks/block-env-staging.sh` — regex boundary for the leading path prefix was `(\./)?` but the hook's documented patterns included `git add foo/.env.local`. Widened to `(.*/)?` so any leading path is matched. Surfaced by the new hook fixture; covered by 6 should-block + 6 should-allow assertions.

### Decided (no code change)

- **No skill-sharing platform.** The bucket is each user's personal toolbox. There is no curated examples folder, no GitHub topic convention, no Discussions. Rationale in [`README.md`](README.md) and [`bucket/README.md`](bucket/README.md); the speculative-library trap argument lives in [`13d-skill-anti-patterns.md`](chapters/persistence/13d-skill-anti-patterns.md). Revisitable if real user volume produces sustained pressure.
