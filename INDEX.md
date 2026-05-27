# INDEX — Router Map

**Purpose:** topic → atomic-file map. Read by Claude when no `op-*` skill fires but the task is manual territory. Also the human table of contents.

**Status:** skeleton — most files don't exist yet. Phases 1–5 populate them. See `RECONSTRUCTION.md` for current progress.

**How to use this file (as Claude):** find the topic that matches the user's task; read only the listed atomic file(s). Don't load whole folders. If no row matches, let `op-bucket-router` read `bucket/INDEX.md` and pick a match from the user's personal library. If still no match, ask the user.

---

## How files are organized

- `chapters/<topic>/<NNx>-<slug>.md` — atomic content files, one concept each, <150 lines.
- The leading number matches the original chapter (01–18); the letter (`a`, `b`, …) marks the split when one chapter became several files.
- "Source" column shows which original chapter the content came from, for cross-reference until v1 is stable.

---

## Foundations — how Claude Code actually works

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| The LLM loop, what each turn is | `chapters/foundations/01a-llm-loop.md` | 01 | written |
| Three levers (context, scope, verification) | `chapters/foundations/01b-three-levers.md` | 01 | written |
| Three failure modes (drift, dilution, hallucination) | `chapters/foundations/01c-failure-modes.md` | 01 | written |
| Context window — green/yellow/red zones, compaction, when to restart | `chapters/foundations/02-context-budget.md` | 02 | written |
| Hard limits (things Claude can't do) | `chapters/foundations/03a-hard-limits.md` | 03 | written |
| Soft limits (things Claude does badly) | `chapters/foundations/03b-soft-limits.md` | 03 | written |
| Project-type fit — what Claude is/isn't good for | `chapters/foundations/03c-project-fit.md` | 03 | written |
| Model tiers — Opus vs Sonnet vs Haiku | `chapters/foundations/04a-model-tiers.md` | 04 | written |
| Plan mode + fast mode | `chapters/foundations/04b-plan-and-fast-mode.md` | 04 | written |
| Budget, weekly limits, API vs Code | `chapters/foundations/04c-budget-and-cost.md` | 04 | written |

## Workflow — how to organize work

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| 7-stage workflow overview | `chapters/workflow/05-overview.md` | 05 | written |
| Stage 0 — Decide (PROJECT_BRIEF before code) | `chapters/workflow/05a-stage-0-decide.md` | 05 | written |
| Stage 1 — Prep (stack, env, first deploy) | `chapters/workflow/05b-stage-1-prep.md` | 05 | written |
| Stage 2 — Architect (ARCHITECTURE.md) | `chapters/workflow/05c-stage-2-architect.md` | 05 | written |
| Stage 3 — Build (one session per feature) | `chapters/workflow/05d-stage-3-build.md` | 05 | written |
| Stage 4 — Integrate | `chapters/workflow/05e-stage-4-integrate.md` | 05 | written |
| Stage 5 — Harden | `chapters/workflow/05f-stage-5-harden.md` | 05 | written |
| Stage 6 — Ship | `chapters/workflow/05g-stage-6-ship.md` | 05 | written |
| One session = one feature — sizing rules | `chapters/workflow/06-feature-sizing.md` | 06 | written |
| Executor mode | `chapters/workflow/07a-executor-mode.md` | 07 | written |
| Reviewer mode | `chapters/workflow/07b-reviewer-mode.md` | 07 | written |
| Explainer mode | `chapters/workflow/07c-explainer-mode.md` | 07 | written |
| Planner mode | `chapters/workflow/07d-planner-mode.md` | 07 | written |
| Mode switching | `chapters/workflow/07-mode-switching.md` | 07 | written |
| Brownfield discovery sequence | `chapters/workflow/08a-discovery-sequence.md` | 08 | written |
| Brownfield safety patterns | `chapters/workflow/08b-safety-patterns.md` | 08 | written |
| Teaching Claude unfamiliar code | `chapters/workflow/08c-teaching-unfamiliar.md` | 08 | written |
| Rewriting legacy | `chapters/workflow/08d-rewrites.md` | 08 | written |

## Prompting — how to interact

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| Five prompting principles | `chapters/prompting/09a-five-principles.md` | 09 | written |
| Prompt structure: CONTEXT/TASK/CONSTRAINTS/EXAMPLES/OUTPUT | `chapters/prompting/09b-prompt-structure.md` | 09 | written |
| Examples and anti-examples | `chapters/prompting/09c-examples-and-anti-examples.md` | 09 | written |
| Visuals — screenshots, mockups, diagrams | `chapters/prompting/10-visuals.md` | 10 | written |

## Signaling — proactive senior-dev behavior

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| Signaling overview — premise, phrasing, cadence, anti-patterns | `chapters/signaling/11-overview.md` | 11 | written |
| Context-filling signals | `chapters/signaling/11a-context-signals.md` | 11 | written |
| Scope-creep signals | `chapters/signaling/11b-scope-signals.md` | 11 | written |
| Drift signals | `chapters/signaling/11c-drift-signals.md` | 11 | written |
| Verification gap signals | `chapters/signaling/11d-verification-signals.md` | 11 | written |
| Meta-scope (proposal vs build mode) | `chapters/signaling/11e-meta-scope.md` | 11 | written |

## Persistence — make Claude smarter over time

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| Three layers compared (CLAUDE.md / skills / memory) | `chapters/persistence/12a-three-layers-overview.md` | 12 | written |
| CLAUDE.md — what it's for, how to write it | `chapters/persistence/12b-claudemd.md` | 12 | written |
| Memory system — when to use it | `chapters/persistence/12c-memory.md` | 12 | written |
| Skill anatomy — frontmatter, body, triggers | `chapters/persistence/13a-skill-anatomy.md` | 13 | written |
| Trigger descriptions — making skills fire | `chapters/persistence/13b-trigger-descriptions.md` | 13 | written |
| Skill design patterns | `chapters/persistence/13c-skill-design-patterns.md` | 13 | written |
| Skill anti-patterns + revised library thesis | `chapters/persistence/13d-skill-anti-patterns.md` | 13 | written |
| settings.json cascade — user/project/local | `chapters/persistence/14a-settings-cascade.md` | 14 | written |
| Hook recipes (typecheck, format, notify, env-leak block) | `chapters/persistence/14b-hook-recipes.md` | 14 | written |

## Tools — which tool when

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| Tool-selection principles | `chapters/tools/15-selection-principles.md` | 15 | written |
| File ops (Read/Edit/Write/NotebookEdit) | `chapters/tools/15a-file-ops.md` | 15 | written |
| Search (grep, find, Agent Explore) | `chapters/tools/15b-search.md` | 15 | written |
| Execution (Bash, Monitor, backgrounding) | `chapters/tools/15c-execution.md` | 15 | written |
| Planning (plan mode, TaskCreate) | `chapters/tools/15d-planning.md` | 15 | written |
| Delegation (Agent — tool mechanics) | `chapters/tools/15e-delegation.md` | 15 | written |
| Scheduling (ScheduleWakeup, /loop, /schedule, Cron) | `chapters/tools/15f-scheduling.md` | 15 | written |
| Web (WebFetch, WebSearch) | `chapters/tools/15g-web.md` | 15 | written |
| MCP integrations | `chapters/tools/15h-mcp.md` | 15 | written |
| Slash commands tier list (Tier 1/2/3 + built-in) | `chapters/tools/15i-slash-commands.md` | 15 | written |

## Subagents — when to delegate

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| When delegation wins / when it loses (incl. writing a good brief) | `chapters/subagents/16a-when-to-delegate.md` | 16 | written |
| Agent types + custom subagents + orchestrator trap | `chapters/subagents/16b-agent-types.md` | 16 | written |
| Parallel + background patterns | `chapters/subagents/16c-parallel-and-background.md` | 16 | written |

## Recovery — when things go wrong

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| Failure-mode triage table | `chapters/recovery/17a-failure-triage.md` | 17 | written |
| Recovery moves (restart, verify, isolate, rebuild) + update-the-system + when-to-walk-away | `chapters/recovery/17b-recovery-moves.md` | 17 | written |
| High-stakes recovery (secrets leaked, mid-flight migration, auth/RLS data leak, lost comprehension) | `chapters/recovery/17c-high-stakes-cases.md` | 17 | written |

## Anti-patterns — explicit "never do this"

| Topic / Trigger | Atomic file | Source | Status |
|---|---|---|---|
| Prompting + communication anti-patterns | `chapters/anti-patterns/18a-prompting.md` | 18 | written |
| Scope anti-patterns | `chapters/anti-patterns/18b-scope.md` | 18 | written |
| Context anti-patterns | `chapters/anti-patterns/18c-context.md` | 18 | written |
| Tool anti-patterns | `chapters/anti-patterns/18d-tools.md` | 18 | written |
| Verification anti-patterns | `chapters/anti-patterns/18e-verification.md` | 18 | written |
| Security anti-patterns | `chapters/anti-patterns/18f-security.md` | 18 | written |
| Workflow anti-patterns | `chapters/anti-patterns/18g-workflow.md` | 18 | written |
| Long-term project anti-patterns | `chapters/anti-patterns/18h-long-term.md` | 18 | written |
| Meta anti-patterns (extending the manual, etc.) + cross-catalog TL;DR | `chapters/anti-patterns/18-meta-patterns.md` | 18 | written |

---

## Fallback: personal skill library

If no row above matches the user's task, the `op-bucket-router` skill takes over: it reads `bucket/INDEX.md` (the user's personal library router at the top of the spine), picks the matching skills, and loads only those files. The bucket INDEX is auto-maintained by `op-add-skill` — users who drop files in manually can run `/refresh-bucket` to update it. If still no match in the bucket either: ask the user.

---

## Read-order for first pass (humans)

When the atomic files exist, the recommended first-read sequence is:

1. `chapters/foundations/01a-llm-loop.md` → `01b-three-levers.md` → `01c-failure-modes.md`
2. `chapters/signaling/11a-context-signals.md` → `11b-scope-signals.md` → `11c-drift-signals.md`
3. `chapters/workflow/07a-executor-mode.md` → `07b-reviewer-mode.md` → `07-mode-switching.md`
4. `chapters/workflow/05-overview.md`
5. `chapters/foundations/04a-model-tiers.md`
6. `chapters/anti-patterns/18-meta-patterns.md`

Then skim the rest. Re-read targeted files when stuck.

---

## Until v2 is complete

The original 18 numbered chapters still live at the repo root (`01-first-principles.md` through `18-anti-patterns.md`) and are the **authoritative source** until each phase atomizes them. If you can't find an atomic file referenced above, fall back to the original chapter.

Progress: see `RECONSTRUCTION.md`.
