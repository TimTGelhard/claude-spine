# Changelog

All notable changes to **claude-spine** are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/spec/v2.0.0.html).

`git pull` is the update mechanism — there is no package registry. New entries land at the top.

---

## [Unreleased]

### Pillar 4 — First-run discovery surface

A fresh-install user who opened Claude Code without reading the README saw no in-session prompt — the discovery surface for `/onboard` and the 21 op-* skills was "go read the repo." Pillar 4 closes that for the three highest-impact paths: a quiet auto-welcome on first run (file-existence-gated, not message-content-gated), a `/spine` command that prints the full skill / command / chapter map on demand, and a much richer `op-onboard` completion handoff that names every available command and points at the natural next action. Per [`FIXES.md`](FIXES.md) Pillar 4 (P4.1 + P4.2 + P4.3). P4.4 (landing-page screenshot + profile example) is post-launch content work.

The in-flight `op-onboard` subscription-aware settings tune also lands in this entry — it shares the same surface (the post-essentials writeback step) and was committed together to avoid two passes over the same file region.

#### Added

- `skills/core/op-welcome/` — auto-firing skill. When `~/.claude/claude-spine-profile.md` is missing (fresh install), emits one quiet welcome block at the start of the first conversation pointing the user at `/onboard`. Silent once the profile exists. Once-per-conversation, file-existence-gated. Orthogonal to `op-spine-active`'s trigger (project state, not profile state) — both can co-fire on a fresh-install plan-driven project.
- `global/commands/spine.md` — `/spine` command. Reads the spine on-disk and prints: profile path + status, slash-commands list, op-* skills with one-line triggers, chapter root, bucket state, pending-suggestions count. Read-only, single-shot. Counts everything from disk so the output never goes stale.
- `skills/core/op-onboard/SKILL.md` — **subscription-based settings tune.** After essentials are saved, proposes raising `autoCompactWindow` and `effortLevel` in `~/.claude/settings.json` for Max 20× users (the spine ships Pro-safe defaults). Plain-English explanation block + explicit Apply/Skip approval — never silent. Write surface is allow-listed to two keys; aborts if the file format diverges from defaults.
- `skills/core/op-onboard/SKILL.md` — **rich completion handoff.** After the profile is written, emits one structured "you're set up" block summarizing what was captured, whether settings.json was tuned, and listing all eight slash commands with one-line uses. Replaces the previous terse three-bullet farewell.

#### Changed

- `README.md` — skill count 20 → 21 in all live-claim positions (5 lines). Phrasing updated to "(19 task-routers + 2 ambient: cold-start and first-run welcome)." `/spine` added to the slash-commands table; command count "Seven" → "Eight."
- `landing/index.html` — "20 op-* skills" → "21 op-* skills."
- `install.sh` — final summary replaces the terse `==> done.` + verify-hint block with a structured "what just happened" + "Next steps" panel that names `/onboard` and `/spine` directly. Idempotency line added.
- `tests/installer/test-dry-run.sh` — skill-coverage list updated to include `op-prepare`, `op-spine-active`, `op-welcome` (was missing all three); summary-line assertions updated to match the new install.sh output (`installing hooks`, `claude-spine is installed.`, `Type  /onboard` block).
- `skills/core/op-onboard/SKILL.md` — description tightened: removes the implicit "auto-fires when profile missing" trigger (`op-welcome` now owns that surface) so this skill only fires on explicit invocation. Mode-selection #1 reworded as "`/onboard` with no profile yet" — the *greeting* is `op-welcome`'s job, the *interview* still runs on first explicit `/onboard`.
- `skills/core/op-onboard/questions-essential.md` — post-Q6 flow rewritten as three numbered steps (save → propose settings tune → ask about deep) so the settings-tune step is a first-class part of the essentials flow, not buried.

### L10 — Ambient workflow refactor

Plan-driven workflow shifts from explicit ceremony (`/session-start` → `/session-end`) to an ambient default where boundary work happens automatically. Original goals (cold-start resistance, scope discipline, multi-session continuity) preserved. Initial L10 kept the legacy commands as escape hatches; L10.1 (below) removed them once the ambient flow was confirmed sufficient.

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

### L10.1 — Legacy session commands removed

Vibecoder default fully realized: no escape-hatch commands, no two-doors-to-one-room confusion. Plan mode (Shift+Tab Tab) is the recommended gate primitive for safety-critical sessions.

#### Removed

- `global/commands/session-start.md` — was the gated cold-start command. For safety-critical work that needs a code-gate, use Claude Code's built-in plan mode (Shift+Tab Tab) instead.
- `global/commands/session-end.md` — was a pure alias for `/done` with no unique behavior.

#### Changed

- `chapters/workflow/05j-cold-start-protocol.md` — rewritten without the gated variant. Plan mode is the recommended gate primitive.
- References to the removed commands dropped or replaced in: `chapters/workflow/05h-multi-session-planning.md`, `chapters/workflow/05i-execution-plan-anatomy.md`, `INDEX.md`, `README.md`, `global/INSTALL.md`, `global/commands/prep.md`, `global/commands/done.md`, `skills/core/op-spine-active/SKILL.md`, `skills/core/op-prepare/SKILL.md` + `procedure.md`, `templates/PROGRESS.md`, `templates/SECTION_PLAN.md`, `templates/SESSION_STARTER.md`, `init.sh`.

### Onboarding — Claude subscription awareness

Defaults today assume a Max-tier user with cheap Opus and 1M-context access. That misreads the Free / Pro segment and under-uses what Max users could be doing. Step one: ask the user which plan they're on; capture daily usage and cost sensitivity in the deep interview. Behavior changes that actually consume the captured field are queued separately ([`docs/SUBSCRIPTION-AWARENESS.md`](docs/SUBSCRIPTION-AWARENESS.md)) so the question can land without waiting on the multi-session implementation work.

#### Added

- `skills/core/op-onboard/questions-essential.md` — new Q1 "Which Claude subscription do you use?" with Free / Pro / Max 5× / Max 20× options (Other = free-text for Team / Enterprise / API). Existing Q1–Q5 renumber to Q2–Q6.
- `skills/core/op-onboard/questions-deep.md` — new Section 0 (subscription) with 0A "daily Claude usage" and 0B "cost sensitivity". Deep-question count 15 → 17.
- `skills/core/op-onboard/profile-template.md` — new `Subscription` section at the top of the profile with `Plan`, `Daily usage`, `Cost sensitivity` fields.
- `docs/SUBSCRIPTION-AWARENESS.md` — planning doc tracking the multi-session work to actually adjust behavior based on the captured plan (model recommendations, ultra-review framing, parallel-subagent caution, fresh-terminal cadence, etc.). Status: queued, not started.

#### Changed

- `skills/core/op-onboard/SKILL.md` — trigger description mentions subscription as a captured field; mode-selection counts updated to 6 essentials / 17 deep.
- `global/commands/onboard.md` — description updated to 6-question essentials / ~17-question deep.
- `skills/core/op-onboard/questions-deep.md` — every existing deep question rewritten in the same plain-language non-coder style as the essentials (parenthetical glosses for jargon, situational labels instead of survey buckets). Matches the style note added at the top of the file.

### Pre-launch cleanup — v1 root stubs removed

The 18 one-line redirect files at the repo root (`01-first-principles.md` … `18-anti-patterns.md`) have been deleted. They were kept earlier on the theory that external links (blog posts, gists, agent prompts) might point at them, but with public launch (L7) not yet shipped there are no external links to break. The original v1 bodies remain in `docs/v1-archive/` and the v1 → v2 navigation map in `V1-CHAPTERS-DEPRECATED.md` is unchanged — only the root stubs are gone.

#### Removed

- 18 v1 redirect stubs at repo root: `01-first-principles.md`, `02-context-window-truth.md`, `03-limits.md`, `04-models-and-economics.md`, `05-workflow.md`, `06-feature-sizing.md`, `07-collaboration-modes.md`, `08-brownfield.md`, `09-prompting.md`, `10-visuals.md`, `11-proactive-signaling.md`, `12-skills-memory-claudemd.md`, `13-custom-skills.md`, `14-hooks-and-automation.md`, `15-tool-palette.md`, `16-subagents.md`, `17-recovery-playbook.md`, `18-anti-patterns.md`.

#### Changed

- `V1-CHAPTERS-DEPRECATED.md` — top paragraph and "Why" passage rewritten to describe the new reality (bodies in `docs/v1-archive/`, no root stubs). Trailing "When are v1 stubs going away?" section replaced with "Where do the v1 bodies live now?" pointing at the archive directory.
- `docs/SUBSCRIPTION-AWARENESS.md` — table reference to `04-models-and-economics.md` repointed at `chapters/foundations/04a-model-tiers.md`.

### Pre-launch gates

Remaining gates before public launch (tracked in [`LAUNCH.md`](LAUNCH.md)):

- **L4c** — token-efficiency benchmark (spine-on vs spine-off) for demo numbers.
- **L7a / L7c / L7d / L7e** — landing-page hardening (built CSS, OG image, waitlist wiring), demo recording, public launch.

Internal drift tracked in [`FIXES.md`](FIXES.md) (the prior 2026-05-27 pre-launch sweep is archived at [`docs/archive/JANITOR-2026-05.md`](docs/archive/JANITOR-2026-05.md); its `PERSONALIZATION.md` retirement and `EXPLAINER.md` pricing-language reframe items have shipped, only the deferred `install.sh` polish from L4c remains).

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
