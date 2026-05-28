# Section: audit-04-skill-triggers

> Section 4 of the audit pass. See `docs/PROJECT_PLAN.md`.
> **Stub — Session 1 to be fully detailed just before this section starts.**
> **Audit phase: WRITE FINDINGS ONLY** (description-rewrite proposals only; no SKILL.md edits in this section).
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints.
> Depends on Section 1 for INDEX/router accuracy baseline.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — run `/prep audit-04-skill-triggers` first; check carried-forward cross-section notes; verify the heartbeat-hook caveat (Session log `touched:` lines may include working-tree dirty files, not edits made by this section).

## Section goal

Audit the op-* skill triggering accuracy. Do `description:` fields fire when they should, and stay silent when they shouldn't? Identify ambiguous descriptions, overlapping triggers between siblings, and skills whose triggers don't match their current body.

## Done criteria

- [ ] Every op-* SKILL.md `description:` field reviewed.
- [ ] Overlap pairs identified (e.g., op-foo and op-bar both fire on phrase X).
- [ ] Drift pairs identified (description claims trigger Y but body procedure addresses Z).
- [ ] Existing benchmark history in `tests/skill-triggers/` consulted; if descriptions changed materially since last run, flag for re-run (cost-gated).
- [ ] Proposed description revisions written into the "Findings" table (still no SKILL.md edits).
- [ ] Findings appended; blocking entries to `FIXES.md`.

## Out of scope

- Architectural / router-shape audit (Section 1).
- SKILL.md edits — that's an apply session, not this audit.
- Running the trigger benchmark itself — cost-authorized separately.

## Files to read for project understanding

- `CLAUDE.md` — skill discipline rules.
- `skills/core/op-*/SKILL.md` — all 22 (open on-demand during the audit).
- `tests/skill-triggers/` — any prior benchmark output / fixtures.
- `chapters/persistence/13*` — skill design guidance.
- `FIXES.md` — current open queue.
- This file.

## Session 1 — Trigger-accuracy review (to be detailed)

**Status**: `pending`

Sketch:

1. Extract every op-* `description:` field into a comparison table.
2. Group by domain (workflow, persistence, signaling, etc.); look for overlap between siblings.
3. Compare description to body to find drift (does the body still address what the description promises?).
4. Propose revisions in the Findings table.
5. Findings + FIXES triage.

## Findings

_(populated when session runs)_

## Session log

_(empty)_
