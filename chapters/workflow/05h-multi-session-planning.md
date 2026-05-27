# 05h — Multi-session planning: think big first, execute small later

The default failure mode for multi-session projects: re-explaining the project at every session. Slow, drift-prone, and the explanation degrades each time it gets re-spoken.

The fix: **plan the whole project once, upfront, in a dedicated planning pass. Execute the resulting plan section-by-section, one terminal session per session-plan.**

## The 4-level hierarchy

Every project that needs >3 build sessions uses this structure:

```
1. PROJECT_BRIEF.md            — User's input + clarified scope (Stage 0)
2. PROJECT_PLAN.md             — Master plan: ordered sections + deps + status
3. docs/plans/<section>.md     — One file per section. Holds N session-plans.
4. SESSION (the terminal)      — Cold-start reads just the active session-plan
```

Information flows downward; status flows upward. The brief drives the master plan; the master plan drives section plans; section plans drive sessions; session outcomes update section plans, which update the master plan.

The artifact at each level has a defined shape — see [05i — Execution plan anatomy](05i-execution-plan-anatomy.md).

## When to use this model

- **New project, expected >3 build sessions.** Always plan first.
- **Existing project, adding a major new capability** (>2 sessions of work). Plan that capability as its own section, append to `PROJECT_PLAN.md`.
- **Inheriting a brownfield project.** Run discovery first (see [08a](08a-discovery-sequence.md)), then plan the work as sections.

For one-off bug fixes or single-session features, skip this — plan the work mentally and execute. Overhead would exceed payoff.

## The planning pass

One dedicated session, before any code. Output is the plan files, nothing else.

1. **User writes the brief.** As much detail as possible: what you're building, who for, key constraints, what success looks like. This is the only "big explanation" the project should ever need.
2. **Claude reads the spine** — this file, [05a](05a-stage-0-decide.md), [05c](05c-stage-2-architect.md), [06](06-feature-sizing.md).
3. **Claude asks clarifying questions** — only the ones that change the plan. On architectural choices, surface 2-3 alternatives with honest tradeoffs (per global CLAUDE.md, never silently pick).
4. **Claude drafts `ARCHITECTURE.md`** — stack, layout, data model, key boundaries.
5. **Claude drafts `PROJECT_PLAN.md`** — ordered sections with dependencies.
6. **Claude drafts a section plan for the first section** (`docs/plans/<section-1>.md`).
7. **Claude initializes `PROGRESS.md`** — pointer to section 1, session 1.
8. **User reviews.** Push back on the section list or session breakdown before code starts.

**Plan subsequent sections lazily, just-in-time before each one starts.** Don't pre-detail every session of every section upfront. Plans drift as earlier work uncovers real shape. The master plan stays in sync from day one; section plans get filled in right before their section runs.

## Why think big first

- **One full explanation, not N partial ones.** Each cold session reads the active session entry (~1-2K tokens), not the whole project model (~10-15K).
- **Scope is locked before code starts.** No mid-build "wait, should we also..." — that's a future section.
- **Dependencies are visible.** You see auth blocks dashboard blocks billing before you commit to an order.
- **Claude doesn't re-derive state every session.** The plan IS the state. `PROGRESS.md` is just the pointer.
- **Push-back is cheap before code, expensive after.** A bad section ordering caught at plan time is a 5-minute fix. After 3 sessions of code, it's a rewrite.

## What this replaces

| Old approach | Plan-driven approach |
|---|---|
| Paste a 6-paragraph orientation prompt every session | The `op-spine-active` skill auto-loads the active session plan |
| Re-explain "where we are" verbally each session | Pointer in `PROGRESS.md` → section plan → session entry |
| Decide scope at the start of every session | Scope decided once, in the section plan, before code |
| End-of-session: update `PROGRESS.md` from memory | `/done` updates the section plan + `PROGRESS.md` pointer; the Stop hook `spine-writeback.sh` traces work in between |
| Discover halfway through that auth wasn't planned | Auth is section 2; you see it before you start section 5 |

## Anti-patterns

- **Planning every section in detail upfront.** Plans drift. Detail section N when section N starts.
- **Writing code in the planning pass.** Plans only. The next session executes.
- **Asking the user 20 clarifying questions.** Ask only what changes the plan structure. Defer the rest to per-section planning.
- **Skipping the brief.** "I'll figure it out from chat messages" loses fidelity. Write the brief file.
- **Bloating session entries.** A session entry should be <100 lines. If it needs more, the session is too big — split.

## Cross-references

- Brief contents and Stage 0: [05a — Stage 0 Decide](05a-stage-0-decide.md)
- Architecture document: [05c — Stage 2 Architect](05c-stage-2-architect.md)
- Plan-file anatomy: [05i — Execution plan anatomy](05i-execution-plan-anatomy.md)
- Cold-start rules every session follows: [05j — Cold-start protocol](05j-cold-start-protocol.md)
- Per-session ritual: [05d — Stage 3 Build](05d-stage-3-build.md)
- Session sizing: [06 — Feature sizing](06-feature-sizing.md)

## TL;DR

- Multi-session projects: plan the whole project once, then execute section-by-section.
- 4 levels: brief → master plan → section plans → sessions.
- The planning pass is one dedicated session. Output: `PROJECT_BRIEF.md`, `ARCHITECTURE.md`, `PROJECT_PLAN.md`, first `SECTION_PLAN`, initialized `PROGRESS.md`.
- Plan subsequent sections just-in-time, not all upfront.
- Cold sessions read the active session entry, not the whole project model.
