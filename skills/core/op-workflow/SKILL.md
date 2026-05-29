---
name: op-workflow
description: Use when starting a new project from scratch, scoping what to build before opening Claude Code, planning the prep / architecture / build / harden / ship sequence, sizing a feature for one session, choosing how to break a too-big feature, or deciding whether the current scope fits in one terminal. For the planning *pass* that actually writes the plan files (brief → architecture → master plan → first section plan), use op-prepare; this skill teaches the 7-stage *concepts* and feature sizing, not the plan-authoring pass. Routes to chapters 05 (the 7-stage workflow) and 06 (feature sizing) of claude-spine.
---

# op-workflow — the 7-stage project workflow + feature sizing

The manual has atomic files for each stage of the workflow and for sizing one feature to one session. Read ONLY the one that matches the current decision.

## Index — workflow stages (chapter 05)

| Question / situation | Atomic file |
|---|---|
| What's the full 7-stage workflow? Where am I in it? | `~/.claude-spine/chapters/workflow/05-overview.md` |
| Stage 0 — Should I even build this? What's the brief? | `~/.claude-spine/chapters/workflow/05a-stage-0-decide.md` |
| Stage 1 — Project scaffolding, no feature code yet | `~/.claude-spine/chapters/workflow/05b-stage-1-prep.md` |
| Stage 2 — Architecture, schema, route shape | `~/.claude-spine/chapters/workflow/05c-stage-2-architect.md` |
| Stage 3 — Per-feature build session ritual | `~/.claude-spine/chapters/workflow/05d-stage-3-build.md` |
| Stage 4 — Integration session (every 3-5 features) | `~/.claude-spine/chapters/workflow/05e-stage-4-integrate.md` |
| Stage 5 — Hardening, completeness checklist, slash commands | `~/.claude-spine/chapters/workflow/05f-stage-5-harden.md` |
| Stage 6 — Ship sequence, security review, post-deploy smoke | `~/.claude-spine/chapters/workflow/05g-stage-6-ship.md` |

## Index — feature sizing (chapter 06)

| Question / situation | Atomic file |
|---|---|
| How much fits in one session? When am I oversized? How do I split? | `~/.claude-spine/chapters/workflow/06-feature-sizing.md` |

## How to use

1. Pick ONE file — the one that matches the user's current decision.
2. Read it. Apply its discipline.
3. Don't paraphrase the file back; act on it.
4. Cross-stage questions (e.g., "am I in Stage 2 or 3?") → read `05-overview.md` first.

## Common triggers

- "Should I just start coding?" → 05a (Stage 0)
- "I'm setting up a new project" → 05b
- "What goes in ARCHITECTURE.md?" → 05c
- "How do I structure a feature session?" → 05d
- "Is this one feature or three?" → 06
- "Claude keeps contradicting itself, did I oversize?" → 06 (signals section)
- "I'm about to deploy, what's the checklist?" → 05g
- "When do I run /security-review and /ultrareview?" → 05f or 05g

## Sibling skills

- Writing the actual plan files for a multi-session build (the planning pass) → `op-prepare`.
- Picking executor / reviewer / explainer / planner mode → `op-collaboration-modes`.
- Inheriting code, returning to old project → `op-brownfield`.
