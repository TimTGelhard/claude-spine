# CLAUDE.md — working on claude-spine

This is the project's own calibration file. Committed; read first when Claude opens this repo. If you (Claude) are about to edit anything in this codebase, read this top to bottom before touching files.

For personal layered overrides, use `CLAUDE.local.md` (gitignored — see `.gitignore`).

---

## What this project IS

**An installable operating-discipline layer for Claude Code.** It is not a tutorial, not a tip library, not a prompt pack. It teaches Claude Code how to *behave well at scale* — across sessions, across projects, across users — by shipping:

- 23 `op-*` routing skills that load on demand
- 84 atomic chapters — one concept per file, lean but complete
- A profile-driven personalization layer (`/onboard`)
- Project templates the user copies into real work
- A neutral global install (settings.json + hooks + commands) wired into `~/.claude/`
- An opt-in personal skill library ("the bucket") for patterns each user accumulates

For people **already running real Claude Code sessions on real projects** who want their workflow to stop leaking quality. Not "Claude for beginners." Operating discipline you'd otherwise build by trial-and-error over months.

The README is the audience-facing pitch. **This file is the maintainer-facing soul.**

---

## What makes this project genuinely different

Three claims, each load-bearing:

### 1. Token efficiency is the central design constraint

Every loaded byte costs the user — in dollars and in context-window pressure. The spine inverts the usual "more documentation = more capability" assumption:

- **Skills are routers, not content.** Each `op-*` SKILL.md decides *which chapter to read*; the chapter does the teaching. If a SKILL.md is carrying procedure steps, question banks, or teaching material, it has stopped being a router — the detail belongs in an adjacent file (`procedure.md`, `questions-deep.md`, `hook-tune.md`, etc.). Length is a symptom, not a target — most routers come in lean because routing is genuinely short, but the discipline is "router shape," not "≤N lines."
- **Chapters are atomic.** One concept per file, decomposed on real seams. Lean but complete — long enough to actually explain the concept, short enough that loading it costs only what the concept is worth. Claude loads `04a-model-tiers.md` for a model question, not the whole foundations folder.
- **INDEX.md is the lightweight fallback.** When no skill matches, INDEX maps topic → file in one round-trip.
- **The bucket is default-off** (since round 6). Most users never grow a personal library; loading the bucket-loop machinery for them is waste.
- **Heavy plugins flipped default-off.** Vercel / Playwright / frontend-design no longer ship enabled; each loads ~20 skills + knowledge into every session start.
- **Hooks split.** Default-on hooks are minimal and security-class (env-leak guards, writeback, notification). Heavy hooks (typecheck-after-edit, format-on-save) are opt-in via `/onboard --deep`.
- **Subscription tune.** `autoCompactWindow` + `effortLevel` are sized to the user's plan in `op-onboard`'s subscription-tune step — Free users don't get Max-class defaults that burn their daily limit.

`benchmarks/tokens/` **measures** the per-load cost — it does not advertise a saving. LC1 (Sonnet 4.6, 2026-05-28; see `benchmarks/tokens/REPORT.md`) refuted the naive "spine saves tokens" framing: spine-on used **+76.6 % more input tokens** than spine-off (+28.6 % cost/call). What holds under measurement is **bounded per-load cost** (heaviest single on-demand load ≈ 8.2k tokens = 4.1 % of Sonnet's 200k window — green-zone) plus **routing accuracy** (measured by `tests/skill-triggers/`, not this harness).

When you edit anything, ask: *does this keep each on-demand load within its bounded per-load budget, and does it sharpen routing so the right file loads on the right query?* Bounded + well-routed is the answer — not "cheaper than vanilla," which LC1 refuted.

### 2. Personalization is real, not decorative

`/onboard` writes `~/.claude/claude-spine-profile.md`. The profile is **read by downstream chapters and skills, not just captured.** Two users get genuinely different advice:

- **Subscription tier** (`Plan:` field, Q1) → `chapters/personalization/19f-subscription-aware.md` has 8 levers × 4 tiers; routing skills branch on it. A Free user asking about parallel-subagent fan-out gets "2-3 in series"; a Max 20× user gets "10+ in parallel."
- **Push-back intensity** (Q4) → `op-signaling` reads it. "Just do it" suppresses non-blocking concerns; "Teach me along the way" surfaces every trade-off.
- **Answer length** (Q5a) + **Reasoning depth** (Q5b) — orthogonal; cover the four-corner space (terse-answer-only ↔ verbose-with-rationale).
- **Cost sensitivity** (0B) → an API-on-Bedrock user with Very-careful spending gets Pro-class defaults despite high tier.
- **Profile-settable defaults** under `## Spine defaults` — curation nudge thresholds, session sizing, plan-dir layout, cue phrases. **Hard-coded magic numbers are an anti-pattern** here. If a user might want to change a threshold, surface it as a profile field.
- **Section W** (conditional) — UI artifacts only: deploy target + database default. Drives template/DEPLOY variant pick.

The full field → consumer map is `chapters/personalization/19g-field-effects.md`. **When you add a new field, you must add a row to 19g** — otherwise the field is decorative.

### 3. The discipline is *opinionated but neutral by default*

The spine has strong opinions about how Claude Code should be used. But the default install is stack-agnostic. Stack opinions live in:

- `global/stacks/<name>/CLAUDE.md.template` — opt-in via `--stack=<name>` flag (today: `ts-next-supabase`, `python-django`)
- `templates/examples/<stack>/` — worked stack-specific examples; the main `templates/*.md` files are agnostic skeletons
- `global/settings-extras/+*.json` — drop-in JSON fragments; `/onboard --deep` proposes merges based on Q3/Q8/Q9 answers, never silent-merges
- `docs/MODELS.md` — single source of truth for Anthropic model IDs + plan tiers (chapters cite this; a registry-citing convenience mirror like `04a` may reproduce the table, but the registry wins on conflict)

**A user on a stack we don't ship gets the discipline; they fill in their own stack.** The spine's job is to teach the *shape*, not impose the *contents*.

---

## Architecture — five layers

```
┌─────────────────────────────────────────────────────────┐
│  L1 — Core skills (skills/core/op-*)                    │
│      22 routers. SKILL.md decides which chapter to      │
│      read; teaching material lives elsewhere. Big       │
│      procedures live in adjacent files                  │
│      (op-prepare/procedure.md, op-onboard/*.md, etc.)   │
├─────────────────────────────────────────────────────────┤
│  L2 — Atomic chapters (chapters/<topic>/<NN-name>.md)   │
│      ~80 files. One concept per file. Lean but complete │
│      — sized to what the concept needs, no padding.     │
│      Organized by topic: foundations / workflow /       │
│      prompting / signaling / persistence / tools /      │
│      subagents / recovery / anti-patterns /             │
│      personalization                                    │
├─────────────────────────────────────────────────────────┤
│  L3 — INDEX (INDEX.md)                                  │
│      Topic → file map. Fallback router when no skill    │
│      fires. Each section names its routing skill.       │
├─────────────────────────────────────────────────────────┤
│  L4 — Personal bucket (bucket/) — opt-in                │
│      Empty by design. Each user builds via op-add-skill │
│      + op-curate. Default-off since round 6.            │
│      Core skills age slowly (discipline);               │
│      bucket skills can age fast (stacks/projects)       │
│      without rotting the spine.                         │
├─────────────────────────────────────────────────────────┤
│  L5 — Global install (global/)                          │
│      ~/.claude/CLAUDE.md stub + settings.json + hooks   │
│      + commands + stacks/ + settings-extras/.           │
│      Wired by install.sh; idempotent; backed up before  │
│      overwrite.                                         │
└─────────────────────────────────────────────────────────┘
```

Every layer routes downward. No layer reads upward (skills don't know which chapters cite them; chapters don't know which skill loaded them). This is the only way to keep token cost bounded.

---

## Core features in detail

### Personalization loop

- `/onboard` (essentials, 10 questions) → writes profile → optionally runs `subscription-tune` (settings.json tweaks)
- `/onboard --deep` → 10 essentials + 18 deep + up to 2 conditional Section W + 2 opt-in hook prompts → optionally runs `subscription-tune` → optionally runs `hook-tune` → optionally runs `extras-merge` → `handoff`
- `op-suggest` (4-condition narrow trigger) appends to `bucket/SUGGESTIONS.md`
- `op-curate-nudge` (default-off via Bucket loop) fires once per session if 5+ pending + last curate >30 days
- `op-curate` walks the queue; **never writes to `chapters/` or `skills/core/`** (hard refusal — those are spine surfaces, not personal)
- `op-add-skill` enforces the 3+-paste-in rule (don't add a skill for one occurrence)

### Push-back / signaling

- `op-signaling` skill + `chapters/signaling/` — when to flag scope drift, contradictions, context-fill, contradictory user instructions
- Tone is calibrated by Q4 (`Push-back: Just do it | Mention concerns | Argue your side | Teach me along the way`)
- Default chapters: 11-overview, 11a-scope-flagging, 11b-contradiction, 11c-context-pressure
- **The spine is not a yes-man.** "Just do it" still surfaces blockers; it suppresses *non-blocking* concerns.

### Security stance

- **Unconditional rules** (no profile toggle, no opt-out):
  - `global/hooks/block-env-staging.sh` denies `git add .env*`
  - `global/hooks/block-env-commit.sh` denies `git commit` if `.env*` is staged
  - `chapters/anti-patterns/18f-security.md` lists the catalog (secrets in source, CORS `*` on user data, dynamic eval, SQL injection, RLS-from-day-1)
- Hard rules in 18f use unconditional "always / never" framing **on purpose** — they're security-class, not stylistic. Round 6's anti-pattern softening pass explicitly left 18f as-is.
- Default `settings.json` is broad-allow but harmless — `npm`, `cargo`, `gh pr view`, etc. Nothing executes secrets or modifies anything destructive.
- The settings-extras / VCS-host fragments are append-only via `jq unique` — never replace or remove user entries.

### Subagent use

- `op-subagents` skill + `chapters/subagents/`
- Subagents are an instrument, not a hammer. **Token cost is real and gets billed at the parent level.**
- Right shape: parallel independent research, deep code audits, scoped tasks where main context shouldn't bloat
- Wrong shape: "delegate thinking" so the main agent gets to skim, spawning for tiny tasks that fit in-context
- Per-plan defaults in 19f (Free: avoid; Pro: 2-3 in series; Max 5×: 3-5 parallel; Max 20×: 10+ parallel)

### Workflow discipline

- `op-prepare` + `/prep` — plans a new project or section. Files only that session.
- `op-spine-active` — ambient cold-start; fires when `docs/plans/` + `docs/PROGRESS.md` exist in the project
- `/done` — closes a build session: verify checklist, roll up Stop-hook heartbeats, stage doc changes, suggest commit message
- `spine-writeback.sh` Stop hook — appends turn heartbeats to the active section plan, captures cross-session notes, fires long-session signal at 30 turns / 2h
- Six session types (`chapters/workflow/06-feature-sizing.md`): Build / Debug / Refactor / Explore / Review / Explain — each has its own "done" definition

---

## Anti-drift — the discipline this project applies to itself

The spine teaches discipline. **It must follow its own.** Specifically:

1. **`FIXES.md` is an action queue, not a narrative dump.** Every entry is a discrete, triageable item an apply session can pull from. Audit history, design rationale, and "what we discovered" prose belong in section Findings tables, `docs/archive/<name>-<date>.md`, or commit / PR text — not FIXES. Length is a symptom of queue-shape violation, not the discipline itself: when FIXES drifts into history (rewind: pre-cleanup it had grown to 2300 lines), the fix is to extract the narrative to an archive and leave the action items behind, not to invoke an arbitrary line ceiling. If 6 audits produce 80 legitimate action items, FIXES carries 80 — that's healthy. 80 lines of narrative essays is not.
2. **`CHANGELOG.md` is canonical Keep-a-Changelog.** Slim `Added / Changed / Fixed / Removed` bullets per version. Not per-pillar essays. Design rationale goes in commit messages and PR descriptions, not here.
3. **`RECONSTRUCTION.md` is frozen architecture + a frozen build journal.** New work doesn't append here; it goes in CHANGELOG.
4. **`INDEX.md` is a chapter router**, not a doc index. Each section names its routing skill.
5. **Point-in-time audits → `docs/archive/<name>-<date>.md`** with a one-line archive preamble pointing at the live successor. Don't leave audits in the repo root.
6. **Routing skills stay router-shaped.** SKILL.md decides which chapter or adjacent file to load; it doesn't carry the teaching itself. If SKILL.md is growing, the question is "is this still routing, or has it become content?" — content goes in an adjacent file. The line count usually drops out of router-shape; chasing the line count alone misses the point.
7. **Atomic chapters are sized to the concept, not to a number.** Lean but complete — every line earns its keep. If a file is growing because it's holding two concepts, split on the real seam. If it's growing because the concept genuinely needs the space, let it. The win is "Claude loads exactly what it needs," not "every file is short."
8. **Templates stay stack-agnostic.** Worked examples go under `templates/examples/<stack-name>/` with a "this is a worked example" preamble.
9. **No new top-level Markdown files** without checking that FIXES / CHANGELOG / RECONSTRUCTION / INDEX / EXPLAINER / README / CONTRIBUTING / this file don't already cover the need.
10. **Hard-coded magic numbers are a smell.** If a threshold matters to a user, surface it as a profile field under `## Spine defaults`.
11. **When a question changes, sweep the count claims.** Counts live in README, EXPLAINER, install.sh, INSTALL.md, 19b, `/onboard` command description, `op-welcome`, `op-onboard/SKILL.md`. The single-source-of-truth pattern (e.g. `docs/MODELS.md`) is preferable to sweeping.
12. **Date-bound model IDs live in `docs/MODELS.md` — the registry.** Chapters cite it, never hard-code names. The one sanctioned exception is a registry-citing *convenience mirror* (today only `04a-model-tiers.md`) that may reproduce the table but must declare the registry wins on conflict. An *un-cited* duplicate is the anti-pattern.

---

## Stack

- bash 5+ / jq / git / coreutils. macOS or Linux. Windows requires WSL today (B10 native-installer is on the open queue).
- Markdown for everything user-facing.
- Shell scripts for tests (`tests/run.sh` orchestrates ~57 cases across 6 sub-suites).
- One Python script (`tools/token-check.py`) — vendored, optional.
- No Node, no Python web framework, no runtime dependencies beyond what's already on a developer machine.

---

## Where things live

| Path | Purpose |
|---|---|
| `README.md` | Audience-facing project pitch |
| `INDEX.md` | Chapter routing fallback |
| `CHANGELOG.md` | Release narrative (Keep-a-Changelog format) |
| `FIXES.md` | Action queue — discrete triageable items only (narrative belongs elsewhere) |
| `RECONSTRUCTION.md` | Frozen v2 architecture decisions + build journal |
| `EXPLAINER.md` | Plain-English framing for skeptics |
| `CONTRIBUTING.md` | Single-maintainer policy |
| `CLAUDE.md` | This file. Maintainer-facing project soul. |
| `chapters/<topic>/` | Atomic chapters — one concept per file, sized to fit the concept |
| `skills/core/op-*/` | Routing skills (+ adjacent files for big procedures) |
| `global/` | Installer artifacts (settings.json, hooks, neutral/, stacks/, settings-extras/, commands/) |
| `templates/` | Project doc templates (stack-agnostic main + `examples/<stack>/`) |
| `tests/` | Shell test fixtures (hooks/, onboard/, installer/, skill-triggers/) |
| `bucket/` | Empty by design; users fill it |
| `landing/` | Public landing page (`index.html` + assets) |
| `benchmarks/tokens/` | Token-efficiency benchmark harness |
| `docs/MODELS.md` | Anthropic model + plan-tier registry (single source of truth) |
| `docs/archive/` | Frozen point-in-time docs (audits, planning docs, phase reports) |
| `docs/v1-archive/` | Preserved v1 chapter bodies |

---

## Current state (2026-05-29)

- v2 architecture shipped, all 6 pre-launch pillars + bias-audit rounds 1–7 + doc cleanup + post-launch trim landed.
- Counts: **23 op-* skills, 10 slash commands, 6 hooks (4 default-on, 2 opt-in), 84 chapters, 10 essentials + 18 deep + up to 2 conditional + 2 hook prompts.**
- Open queue is `FIXES.md` — currently LC1–LC6 (manual launch tasks) + BA3 (per-platform DEPLOY variants, pull-driven) + Pass-4 remaining (C-block, B10, P4).
- Past 0.10.0; 0.11.0 cut; `[Unreleased]` carries the post-launch RECONSTRUCTION trim entry.

---

## When working on this project

Read order for a cold session:

1. **This file** (CLAUDE.md) — soul + constraints
2. **`FIXES.md`** — what's open
3. **`README.md`** — if you need the audience framing
4. **`INDEX.md`** — when picking a chapter

For "why is X shaped this way?": `RECONSTRUCTION.md`.
For "what shipped, when": `CHANGELOG.md`.
For "what changes per Claude plan?": `chapters/personalization/19f-subscription-aware.md`.
For "what does each profile field actually do?": `chapters/personalization/19g-field-effects.md`.

**Before editing:**
- Is this a one-fix? Check whether FIXES.md names it. If yes, the FIXES entry has the context.
- Is this adding content? Honor the size ceilings. Adjacent files for big procedures; new atomic chapter for new concepts.
- Is this a new top-level doc? Almost certainly no. Find the existing live home.
- Is this a docs cleanup? Same archive pattern: `git mv` to `docs/archive/<name>-<date>.md`, prepend a preamble, sweep references.

**Before claiming "done":**
- Run `tests/run.sh` (6 suites, ~65 cases). It should pass.
- If you touched a skill description, the trigger benchmark in `tests/skill-triggers/` may need a re-run (costs API spend — only run if a description meaningfully changed).
- Sweep count claims if you changed a count.
- Update FIXES.md if you closed an open item.
- Add to CHANGELOG `[Unreleased]` — bullet form, terse, *under* an Added/Changed/Fixed/Removed heading.

**Never:**
- Let `FIXES.md` drift from action queue into narrative dump (audit history, rationale, "what we discovered"). When it does, the fix is extracting the narrative to an archive and keeping action items behind — not trimming by line count.
- Add per-pillar / per-round essays to CHANGELOG. Slim KCH bullets only.
- Create new top-level docs ad-hoc. Use the existing 8.
- Edit `chapters/` or `skills/core/` in response to a single user complaint — those are stable surfaces. Route fixes via FIXES.md and consider whether the fix belongs in a personal bucket skill instead.
- Hard-code a threshold a user might reasonably want to override. Profile field under `## Spine defaults` is the right home.
