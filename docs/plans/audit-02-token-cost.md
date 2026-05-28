# Section: audit-02-token-cost

> Section 2 of the audit pass. See `docs/PROJECT_PLAN.md`.
> **Stub — Session 1 to be fully detailed just before this section starts** (per `chapters/workflow/05h-multi-session-planning.md`: plan sections lazily, not all upfront).
> **Audit phase: WRITE FINDINGS ONLY.** No edits to `chapters/`, `skills/core/`, code, or templates.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — run `/prep audit-02-token-cost` first; check carried-forward cross-section notes; verify the heartbeat-hook caveat (Session log `touched:` lines may include working-tree dirty files, not edits made by this section).

## Section goal

Audit the project's first load-bearing claim — **token efficiency is the central design constraint** — by measurement. Quantify router vs chapter sizes, find redundancy across chapters, identify heavy-load session shapes, and (if LC1 is authorized) run the benchmark to produce the spine-on vs spine-off number that the project's headline depends on.

## Done criteria

- [ ] Router size distribution measured and recorded (median + outliers).
- [ ] Chapter size distribution measured and recorded (median + outliers > 200 lines flagged).
- [ ] Redundancy scan complete — at least 5 concept-grep passes across `chapters/` (e.g., "subscription tier", "router shape", "RLS", "cold-start", "anti-drift") to find duplicate teaching.
- [ ] Heavy-load session shapes identified — the 3 most-loaded combinations of skill + chapters in real session shapes.
- [ ] LC1 benchmark either run (numbers in `benchmarks/tokens/REPORT.md` + linked from README) or explicitly deferred (LC1 stays in `FIXES.md` with a clear next-step gate; A1 partial-residue cleanup decided).
- [ ] Findings appended to this file; blocking entries to `FIXES.md`.

## Out of scope

- Architecture / router-shape audit (Section 1 owns it).
- Personalization or skill-trigger audit (Sections 3, 4).
- Any chapter, skill, or code edits.

## Files to read for project understanding

- `CLAUDE.md` — the token-efficiency claim, under "What makes this project genuinely different §1".
- `benchmarks/tokens/README.md` (if present) — harness usage.
- `benchmarks/tokens/` directory contents — current state of partial results (A1 in `FIXES.md`).
- `FIXES.md` — LC1 status and A1 escalation context.
- `docs/PROJECT_PLAN.md`.
- This file.

## Session 1 — Token-cost measurement (to be detailed)

**Status**: `pending`

Detail before starting. Sketch:

1. Inventory: line counts + estimated token counts for every router and every chapter.
2. Redundancy scan: grep N high-signal concepts across `chapters/`, find duplicate teaching.
3. Heavy-load shape simulation: list the 3 most expensive cold-start paths (skill + chapters loaded).
4. LC1 decision: run the harness (if authorized) or defer with clear gate.
5. Findings + FIXES triage.

## Findings

_(populated when session runs)_

## Session log

_(empty)_
