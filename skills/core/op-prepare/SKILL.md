---
name: op-prepare
description: Use when starting a new project from scratch, scoping a major new capability in an existing project (>2 sessions of work), or whenever the user describes a multi-session piece of work and no project plan exists yet. Fires on phrases like "I want to build X", "let's start a new project", "let's plan the next big feature", "scope this out", "I have an idea for...", or when /prep is invoked. Walks the planning pass — brief → architecture → master plan → first section plan. Routes to chapters 05h (planning hierarchy), 05i (plan anatomy), and 05j (cold-start protocol) of claude-spine.
---

# op-prepare — the planning pass

The planning pass is one dedicated session before any code. Output is the plan files, nothing else. Done right, every subsequent session is cold-start-resistant and scope-locked.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading with the Read tool. `install.sh` ensures `~/.claude-spine` resolves to your spine clone.

## What to read first

In this order, before doing anything else:

1. `~/.claude-spine/chapters/workflow/05h-multi-session-planning.md` — the 4-level hierarchy.
2. `~/.claude-spine/chapters/workflow/05i-execution-plan-anatomy.md` — what each plan file contains.
3. `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md` — the rules every fresh session follows (so you write plans that work *with* the protocol).

These templates are the output shape — load as references when drafting:

- `~/.claude-spine/templates/PROJECT_BRIEF.md`
- `~/.claude-spine/templates/ARCHITECTURE.md`
- `~/.claude-spine/templates/PROJECT_PLAN.md`
- `~/.claude-spine/templates/SECTION_PLAN.md`
- `~/.claude-spine/templates/PROGRESS.md`

## The pass — what to actually do

### Step 1 — Confirm we're planning, not coding

State to the user: "This is a planning pass. Output will be plan files in `docs/`, no code. Continue?"

If user says "just start coding," push back once: this session locks scope for many future sessions — the upfront cost pays back 10x. If they still insist, hand off to `op-workflow` instead.

### Step 2 — Establish the brief

Check whether `docs/PROJECT_BRIEF.md` exists.

- **If it doesn't:** ask the user for the brief. One big prompt covering: what they're building, who for, key constraints, what success looks like, any non-negotiables (security, compliance, performance). Then write `docs/PROJECT_BRIEF.md` from their input using `~/.claude-spine/templates/PROJECT_BRIEF.md` as scaffold.
- **If it does:** read it. Treat it as input.

### Step 3 — Ask clarifying questions (only the ones that change the plan)

Don't ask everything. Ask only what affects:

- Section count or ordering
- Stack / architecture choices
- Security / compliance constraints
- Definition of "done" for the project as a whole
- Hard dependencies on external systems (Stripe approval, third-party API access, etc.)

For 2-3 architectural choices, surface alternatives with honest tradeoffs (per global CLAUDE.md). Never silently pick the first thing.

Cap at 5-7 questions in one round. More than that, you're trying to plan in detail what should be deferred to per-section planning.

### Step 4 — Draft `docs/ARCHITECTURE.md`

Stack, layout, data model, key boundaries. See `~/.claude-spine/chapters/workflow/05c-stage-2-architect.md` for what goes in.

Keep it high-level — schemas, route shape, where server/client boundary lives, what's in `lib/server` vs `lib/`. Not implementation detail.

### Step 5 — Draft `docs/PROJECT_PLAN.md`

Ordered sections with dependencies. Use `~/.claude-spine/templates/PROJECT_PLAN.md` as scaffold.

Typical sections for a CRUD-shaped app:

1. foundation (scaffolding + first deploy)
2. auth (login + RLS baseline)
3..N. resources (one section per major resource)
N+1. integrations (Stripe, webhooks, email, file storage)
N+2. landing (public marketing pages — can run in parallel with resources)
N+3. hardening (states, perf, a11y, security review)
N+4. ship (deploy + post-deploy smoke)

Adjust order to match real dependencies. Auth always before user-scoped resources. RLS planned in the section that introduces the table, not retro-fitted later.

Target: 5-12 sections for a typical MVP. More than 15, your sections are too granular — merge.

### Step 6 — Draft `docs/plans/<section-1>.md` — the FIRST section only

Use `~/.claude-spine/templates/SECTION_PLAN.md` as scaffold. Break the section into 2-5 sessions. Each session entry has:

- Goal (one line)
- Files to read (exact list)
- Files to write/edit (scope)
- Build steps (3-7 high-level items)
- Verify (concrete checks)
- Output (commit hint + plan-file updates)

Keep each session entry under 100 lines. If it needs more, the session is too big — split.

**Do NOT pre-plan sections 2..N in detail.** Section plans drift as earlier sections discover real shape. The master plan stays in sync; only the active section plan is fully detailed.

### Step 7 — Initialize `docs/PROGRESS.md`

Use `~/.claude-spine/templates/PROGRESS.md`. Set:

- Active section: section 1
- Active session: session 1 from the section file
- Last session outcome: "(no sessions run yet)"
- Blockers: (empty)
- Next session reading list: copied from session 1's "Files to read" entry

### Step 8 — Hand back to user

Report concisely:

- `docs/PROJECT_BRIEF.md` — drafted (or read, if it existed)
- `docs/ARCHITECTURE.md` — drafted with: stack, layout, data model, boundaries
- `docs/PROJECT_PLAN.md` — drafted with N sections
- `docs/plans/<section-1>.md` — drafted with M sessions
- `docs/PROGRESS.md` — initialized, pointing at section 1 session 1
- Next step: user reviews. Push back welcomed before any code. When ready, `/session-start` begins the first session.

## When to draft subsequent section plans

Just-in-time, right before that section starts. Two options:

1. **User runs `/prep <section-name>`** to plan one section explicitly.
2. **`/session-start` detects** that the next active section has no plan file yet → halts and tells the user "section N has no plan; run `/prep` first."

Don't draft section 2 during the section 1 planning pass — wait for section 1 work to inform it.

## Anti-patterns

- **Pre-planning every section in detail upfront.** Plans drift. Detail section N when section N starts.
- **Writing code in the planning pass.** Plans only. The next session executes.
- **Asking the user 20 clarifying questions.** Ask only what changes the plan structure. Defer rest to per-section planning.
- **Skipping the brief.** "I'll figure it out from chat messages" loses fidelity. Write the brief file.
- **Bloating session entries.** A session entry should be <100 lines. If it needs more, the session is too big — split.
- **Silently picking architectural choices.** Per global CLAUDE.md, surface 2-3 alternatives with tradeoffs before deciding.
- **Locking the plan as a contract.** Plans are working documents. Update them when reality diverges — see [05j](~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md) "Hard rules".

## Sibling skills

- Per-session execution: `op-workflow` (chapter 05d) — what each session does inside its scope.
- Brownfield discovery before planning: `op-brownfield`.
- Collaboration mode (planner / executor / reviewer): `op-collaboration-modes`.
- After plans exist: `/session-start` and `/session-end` carry the work.

## TL;DR

- One dedicated planning session before any code.
- Output: `PROJECT_BRIEF.md`, `ARCHITECTURE.md`, `PROJECT_PLAN.md`, first `SECTION_PLAN`, initialized `PROGRESS.md`.
- Subsequent sections planned just-in-time, not all upfront.
- Then `/session-start` and `/session-end` carry the work.
- Never write code in this skill — that's for `op-workflow` + the cold-start protocol.
