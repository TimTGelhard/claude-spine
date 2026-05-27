# v1 chapters — deprecation index

The 18 numbered chapters at the repo root (`01-first-principles.md` through `18-anti-patterns.md`) are **v1 stubs**, kept for external-link preservation. New work should read the v2 atomic files in [`chapters/`](chapters/) (the router map is [`INDEX.md`](INDEX.md)).

This file is the inverse of [`INDEX.md`](INDEX.md): the router groups files by topic; this file groups them by *source* v1 chapter so an old link can find its new home in one step.

## Why v1 chapters were deprecated

v2 organizes content by *the question being answered*, not by chapter number. A single v1 chapter typically held 3–5 distinct concepts that lived together because the original drafting batched them; v2 splits each chapter on real seams (the [decomposition rule](RECONSTRUCTION.md#architecture-frozen-decisions)) so Claude loads one slice per task instead of an entire chapter.

The v1 files aren't deleted because external links — blog posts, gists, agent prompts, bookmarks — may already point at them. Each v1 file now carries a one-line deprecation header pointing at the v2 location, plus a link back to this index.

## v1 → v2 map

### 01 — First principles → [`chapters/foundations/`](chapters/foundations/)
- [`01a-llm-loop.md`](chapters/foundations/01a-llm-loop.md) — the LLM loop
- [`01b-three-levers.md`](chapters/foundations/01b-three-levers.md) — context, scope, verification
- [`01c-failure-modes.md`](chapters/foundations/01c-failure-modes.md) — drift, dilution, hallucination

### 02 — Context window truth → [`chapters/foundations/`](chapters/foundations/)
- [`02-context-budget.md`](chapters/foundations/02-context-budget.md) — green/yellow/red zones, compaction, restart *(no split — single file, renamed)*

### 03 — Limits → [`chapters/foundations/`](chapters/foundations/)
- [`03a-hard-limits.md`](chapters/foundations/03a-hard-limits.md) — what Claude can't do
- [`03b-soft-limits.md`](chapters/foundations/03b-soft-limits.md) — what Claude does badly
- [`03c-project-fit.md`](chapters/foundations/03c-project-fit.md) — project-type fit

### 04 — Models and economics → [`chapters/foundations/`](chapters/foundations/)
- [`04a-model-tiers.md`](chapters/foundations/04a-model-tiers.md) — Opus / Sonnet / Haiku
- [`04b-plan-and-fast-mode.md`](chapters/foundations/04b-plan-and-fast-mode.md) — plan + fast modes
- [`04c-budget-and-cost.md`](chapters/foundations/04c-budget-and-cost.md) — budget, weekly limits, API vs Code

### 05 — Workflow → [`chapters/workflow/`](chapters/workflow/)
- [`05-overview.md`](chapters/workflow/05-overview.md) — 7-stage workflow overview
- [`05a-stage-0-decide.md`](chapters/workflow/05a-stage-0-decide.md) — Decide
- [`05b-stage-1-prep.md`](chapters/workflow/05b-stage-1-prep.md) — Prep
- [`05c-stage-2-architect.md`](chapters/workflow/05c-stage-2-architect.md) — Architect
- [`05d-stage-3-build.md`](chapters/workflow/05d-stage-3-build.md) — Build
- [`05e-stage-4-integrate.md`](chapters/workflow/05e-stage-4-integrate.md) — Integrate
- [`05f-stage-5-harden.md`](chapters/workflow/05f-stage-5-harden.md) — Harden
- [`05g-stage-6-ship.md`](chapters/workflow/05g-stage-6-ship.md) — Ship

### 06 — Feature sizing → [`chapters/workflow/`](chapters/workflow/)
- [`06-feature-sizing.md`](chapters/workflow/06-feature-sizing.md) — one session = one feature *(no split — single file, renamed)*

### 07 — Collaboration modes → [`chapters/workflow/`](chapters/workflow/)
- [`07a-executor-mode.md`](chapters/workflow/07a-executor-mode.md) — executor
- [`07b-reviewer-mode.md`](chapters/workflow/07b-reviewer-mode.md) — reviewer
- [`07c-explainer-mode.md`](chapters/workflow/07c-explainer-mode.md) — explainer
- [`07d-planner-mode.md`](chapters/workflow/07d-planner-mode.md) — planner
- [`07-mode-switching.md`](chapters/workflow/07-mode-switching.md) — switching modes mid-session

### 08 — Brownfield → [`chapters/workflow/`](chapters/workflow/)
- [`08a-discovery-sequence.md`](chapters/workflow/08a-discovery-sequence.md) — discovery sequence
- [`08b-safety-patterns.md`](chapters/workflow/08b-safety-patterns.md) — safety patterns
- [`08c-teaching-unfamiliar.md`](chapters/workflow/08c-teaching-unfamiliar.md) — teaching Claude unfamiliar code
- [`08d-rewrites.md`](chapters/workflow/08d-rewrites.md) — rewriting legacy

### 09 — Prompting → [`chapters/prompting/`](chapters/prompting/)
- [`09a-five-principles.md`](chapters/prompting/09a-five-principles.md) — five principles
- [`09b-prompt-structure.md`](chapters/prompting/09b-prompt-structure.md) — prompt structure
- [`09c-examples-and-anti-examples.md`](chapters/prompting/09c-examples-and-anti-examples.md) — examples + anti-examples

### 10 — Visuals → [`chapters/prompting/`](chapters/prompting/)
- [`10-visuals.md`](chapters/prompting/10-visuals.md) — screenshots, mockups, diagrams *(no split — single file, moved into prompting/)*

### 11 — Proactive signaling → [`chapters/signaling/`](chapters/signaling/)
- [`11-overview.md`](chapters/signaling/11-overview.md) — premise, phrasing, cadence, anti-patterns
- [`11a-context-signals.md`](chapters/signaling/11a-context-signals.md) — context-filling
- [`11b-scope-signals.md`](chapters/signaling/11b-scope-signals.md) — scope creep
- [`11c-drift-signals.md`](chapters/signaling/11c-drift-signals.md) — drift
- [`11d-verification-signals.md`](chapters/signaling/11d-verification-signals.md) — verification gaps (incl. end-of-session)
- [`11e-meta-scope.md`](chapters/signaling/11e-meta-scope.md) — proposal vs build mode

### 12 — Skills, memory, CLAUDE.md → [`chapters/persistence/`](chapters/persistence/)
- [`12a-three-layers-overview.md`](chapters/persistence/12a-three-layers-overview.md) — three layers compared
- [`12b-claudemd.md`](chapters/persistence/12b-claudemd.md) — CLAUDE.md
- [`12c-memory.md`](chapters/persistence/12c-memory.md) — memory system

### 13 — Custom skills → [`chapters/persistence/`](chapters/persistence/)
- [`13a-skill-anatomy.md`](chapters/persistence/13a-skill-anatomy.md) — anatomy (frontmatter, body, triggers)
- [`13b-trigger-descriptions.md`](chapters/persistence/13b-trigger-descriptions.md) — making skills fire
- [`13c-skill-design-patterns.md`](chapters/persistence/13c-skill-design-patterns.md) — design patterns
- [`13d-skill-anti-patterns.md`](chapters/persistence/13d-skill-anti-patterns.md) — anti-patterns + revised library thesis

### 14 — Hooks and automation → [`chapters/persistence/`](chapters/persistence/)
- [`14a-settings-cascade.md`](chapters/persistence/14a-settings-cascade.md) — settings cascade
- [`14b-hook-recipes.md`](chapters/persistence/14b-hook-recipes.md) — hook recipes (typecheck, format, notify, env-leak block)

### 15 — Tool palette → [`chapters/tools/`](chapters/tools/)
- [`15-selection-principles.md`](chapters/tools/15-selection-principles.md) — selection principles
- [`15a-file-ops.md`](chapters/tools/15a-file-ops.md) — file ops (Read/Edit/Write/NotebookEdit)
- [`15b-search.md`](chapters/tools/15b-search.md) — search (grep, find, Agent Explore)
- [`15c-execution.md`](chapters/tools/15c-execution.md) — execution (Bash, Monitor, backgrounding)
- [`15d-planning.md`](chapters/tools/15d-planning.md) — planning (plan mode, TaskCreate)
- [`15e-delegation.md`](chapters/tools/15e-delegation.md) — delegation (Agent — tool mechanics)
- [`15f-scheduling.md`](chapters/tools/15f-scheduling.md) — scheduling (ScheduleWakeup, /loop, /schedule, Cron)
- [`15g-web.md`](chapters/tools/15g-web.md) — web (WebFetch, WebSearch)
- [`15h-mcp.md`](chapters/tools/15h-mcp.md) — MCP integrations
- [`15i-slash-commands.md`](chapters/tools/15i-slash-commands.md) — slash commands *(added in v2 — no v1 equivalent)*

### 16 — Subagents → [`chapters/subagents/`](chapters/subagents/)
- [`16a-when-to-delegate.md`](chapters/subagents/16a-when-to-delegate.md) — when delegation wins / loses (incl. writing a brief)
- [`16b-agent-types.md`](chapters/subagents/16b-agent-types.md) — agent types + custom subagents + orchestrator trap
- [`16c-parallel-and-background.md`](chapters/subagents/16c-parallel-and-background.md) — parallel + background patterns

### 17 — Recovery playbook → [`chapters/recovery/`](chapters/recovery/)
- [`17a-failure-triage.md`](chapters/recovery/17a-failure-triage.md) — failure-mode triage table
- [`17b-recovery-moves.md`](chapters/recovery/17b-recovery-moves.md) — recovery moves (restart, verify, isolate, rebuild) + update-the-system + when-to-walk-away
- [`17c-high-stakes-cases.md`](chapters/recovery/17c-high-stakes-cases.md) — secrets leaked, mid-flight migration, auth/RLS data leak, lost comprehension

### 18 — Anti-patterns → [`chapters/anti-patterns/`](chapters/anti-patterns/)
- [`18a-prompting.md`](chapters/anti-patterns/18a-prompting.md) — prompting + communication anti-patterns
- [`18b-scope.md`](chapters/anti-patterns/18b-scope.md) — scope
- [`18c-context.md`](chapters/anti-patterns/18c-context.md) — context
- [`18d-tools.md`](chapters/anti-patterns/18d-tools.md) — tools
- [`18e-verification.md`](chapters/anti-patterns/18e-verification.md) — verification
- [`18f-security.md`](chapters/anti-patterns/18f-security.md) — security (authoritative forbidden list)
- [`18g-workflow.md`](chapters/anti-patterns/18g-workflow.md) — workflow
- [`18h-long-term.md`](chapters/anti-patterns/18h-long-term.md) — long-term project
- [`18-meta-patterns.md`](chapters/anti-patterns/18-meta-patterns.md) — meta (extending the manual, etc.) + cross-catalog TL;DR

## v2 content with no v1 source

Five files in `chapters/personalization/` are net-new in v2 (Phase 8, shipped 2026-05-27):

- [`19a-overview.md`](chapters/personalization/19a-overview.md) — personalization overview (three layers, the loop)
- [`19b-profile-and-onboarding.md`](chapters/personalization/19b-profile-and-onboarding.md) — profile + `/onboard`
- [`19c-suggestion-loop.md`](chapters/personalization/19c-suggestion-loop.md) — suggestion-capture loop
- [`19d-curation-session.md`](chapters/personalization/19d-curation-session.md) — curation sessions (`/curate`)
- [`19e-extending-the-bucket.md`](chapters/personalization/19e-extending-the-bucket.md) — skill vs chapter, gates, GC

One file in `chapters/tools/` is also new: `15i-slash-commands.md` (above). The rest of `chapters/` traces back to a v1 chapter.

## When are v1 stubs going away?

Not on a fixed timeline. They cost ~5 KB of repo size and a few extra entries in `ls`. The deprecation header at the top of each file points readers at the v2 equivalents; this index gives the full map. Removing the root files would break any external link (blog posts, gists, agent prompts) that points at them. The trade-off favors keeping them until v2 has been canonical long enough that v1 links are rare in the wild.
