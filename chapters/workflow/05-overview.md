# 05 — The seven-stage workflow

The spine of any non-trivial Claude Code project. Each stage has a clear goal, a deliverable, and an exit condition.

```
0. Decide       → Is this worth building? Scope it.
1. Prep         → Markdown files, stack, dependencies, decisions.
2. Architect    → Schema, routes, components, security boundaries.
3. Build        → One feature per session, with verification.
4. Integrate    → Wire features together, smoke test.
5. Harden       → Edge cases, error states, accessibility, perf.
6. Ship         → Deploy + monitor + retro.
```

## The two stages everyone skips

**Stage 0 (Decide)** and **Stage 5 (Harden)** are the ones most operators drop. Skipping 0 means churning in build sessions on questions you should have settled cold. Skipping 5 means shipping the missing-state bugs that make up the bulk of real production incidents.

If you only fix one habit, fix one of these two.

## Each stage at a glance

| Stage | Time | Deliverable | Atomic file |
|---|---|---|---|
| 0 — Decide | 15–60 min | `PROJECT_BRIEF.md` | [05a-stage-0-decide.md](05a-stage-0-decide.md) |
| 1 — Prep | 1–2 hrs | Working "hello world" deploy | [05b-stage-1-prep.md](05b-stage-1-prep.md) |
| 2 — Architect | 30–90 min | `ARCHITECTURE.md` | [05c-stage-2-architect.md](05c-stage-2-architect.md) |
| 3 — Build | per feature | Shipped feature + smoke pass | [05d-stage-3-build.md](05d-stage-3-build.md) |
| 4 — Integrate | every 3–5 features | Smoke list passes end-to-end | [05e-stage-4-integrate.md](05e-stage-4-integrate.md) |
| 5 — Harden | 1–3 sessions | Completeness checklist passes | [05f-stage-5-harden.md](05f-stage-5-harden.md) |
| 6 — Ship | 1 session | Live, audited, handed over | [05g-stage-6-ship.md](05g-stage-6-ship.md) |

## How stages and sessions relate

A session is one terminal. A stage is a phase of the project. They don't map 1:1:

- Stage 0 happens before you open Claude Code.
- Stages 1, 2, 4, 6 are typically **one session each**.
- Stage 3 is **N sessions**, one per feature.
- Stage 5 is **a few sessions**, one per cross-cutting concern (accessibility pass, perf pass, error-state pass).

The rule that holds across stages: one session = one focused job. Don't combine stages in a single terminal — by the time you start the next phase, your context is half-full of the previous one. See [06-feature-sizing.md](06-feature-sizing.md).

## Anti-patterns

- **"Just have Claude figure it out."** Without Stage 0 you'll discover what you wanted only after building the wrong thing.
- **"I'll write the markdown files after the MVP works."** You won't, and every session re-derives the project from scratch.
- **"One big {{PR_OR_MR}} at the end."** Massive diffs hide bugs — commit per feature.
- **"Skip Stage 5, the user won't notice."** They will. Missing-state bugs are the most common production issues.
- **Combining stages in one session** — especially prep + first feature.

## TL;DR

- 7 stages, not 4. Stage 0 and Stage 5 are the ones you skip.
- One session = one feature, fresh terminal each time.
- Every build session ends with: verify + commit + `PROGRESS.md` updated.
