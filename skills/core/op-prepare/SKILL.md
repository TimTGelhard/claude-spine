---
name: op-prepare
description: Use when starting a new project from scratch, scoping a major new capability in an existing project (>2 sessions of work), or whenever the user describes a multi-session piece of work and no project plan exists yet. Fires on phrases like "I want to build X", "let's start a new project", "let's plan the next big feature", "scope this out", "I have an idea for...", or when /prep is invoked. Walks the planning pass — brief → architecture → master plan → first section plan. Routes to chapters 05h (planning hierarchy), 05i (plan anatomy), and 05j (cold-start protocol) of claude-spine.
---

# op-prepare — the planning pass

One dedicated planning session before any code. Output is plan files in `docs/`, nothing else. Done right, every subsequent session is cold-start-resistant and scope-locked. Full step-by-step pass: [`procedure.md`](procedure.md).

## When to fire

- `/prep` (with or without a section name) → run the procedure.
- User says "I want to build X", "let's start a new project", "let's plan the next big feature", "scope this out", "I have an idea for…" → confirm "planning pass — no code?" then run the procedure.
- Existing project has `docs/PROJECT_BRIEF.md` but no `docs/PROJECT_PLAN.md`, or a major new section has no plan file → run scoped to what's missing (`/prep <section-name>` variant).

## When NOT to fire

- User just wants to code now — push back once on the upfront cost; if still no, hand off to `op-workflow`.
- Plans already exist and section work is mid-flight — the ambient `op-spine-active` skill carries the session.
- Brownfield codebase the user hasn't explored — fire `op-brownfield` first; plan rewrites/extensions only after discovery.
- **Work shape is not Build** (audit, refactor, migration, investigation, research, cleanup) — `op-approach` fires *before* this skill on those shapes, identifies the shape, and routes back here informed by the shape's phase structure + hard rule. See [`chapters/workflow/05k-work-shapes.md`](../../../chapters/workflow/05k-work-shapes.md).

## What to read first

In this order, before drafting anything:

1. `~/.claude-spine/chapters/workflow/05h-multi-session-planning.md` — the 4-level hierarchy.
2. `~/.claude-spine/chapters/workflow/05i-execution-plan-anatomy.md` — what each plan file contains.
3. `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md` — the rules every fresh session follows.
4. [`procedure.md`](procedure.md) — the step-by-step pass.

These templates are the output shape — load as references when drafting:

- `~/.claude-spine/templates/PROJECT_BRIEF.md`
- `~/.claude-spine/templates/ARCHITECTURE.md`
- `~/.claude-spine/templates/PROJECT_PLAN.md`
- `~/.claude-spine/templates/SECTION_PLAN.md`
- `~/.claude-spine/templates/PROGRESS.md`

## Sibling skills

- **Before** this fires (for non-build work): `op-approach` — identifies work shape (Build / Audit / Refactor / Migration / Investigation / Research / Cleanup), surfaces phase structure + hard rule + traps from [`chapters/workflow/05k-work-shapes.md`](../../../chapters/workflow/05k-work-shapes.md), then routes back here informed by the shape.
- Per-session execution: `op-workflow` (chapter 05d) — what each session does inside its scope.
- Brownfield discovery before planning: `op-brownfield`.
- Collaboration mode (planner / executor / reviewer): `op-collaboration-modes`.
- After plans exist: ambient `op-spine-active` + `/done` carry the work.

## TL;DR

- One dedicated planning session before any code.
- Output: `PROJECT_BRIEF.md`, `ARCHITECTURE.md`, `PROJECT_PLAN.md`, first `SECTION_PLAN`, initialized `PROGRESS.md`.
- Subsequent section plans are drafted just-in-time via `/prep <section-name>`, not all upfront.
- Then per-session execution begins (ambient `op-spine-active`).
- Never write code in this skill — that's `op-workflow` + the cold-start protocol.
