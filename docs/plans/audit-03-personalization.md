# Section: audit-03-personalization

> Section 3 of the audit pass. See `docs/PROJECT_PLAN.md`.
> **Stub — Session 1 to be fully detailed just before this section starts.**
> **Audit phase: WRITE FINDINGS ONLY.** No edits to `chapters/`, `skills/core/`, code, or templates.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — run `/prep audit-03-personalization` first; check carried-forward cross-section notes; verify the heartbeat-hook caveat (Session log `touched:` lines may include working-tree dirty files, not edits made by this section).

## Section goal

Audit the project's second load-bearing claim — **personalization is real, not decorative** — by verifying that every profile field declared in `skills/core/op-onboard/profile-template.md` has at least one real consumer in `chapters/`, `skills/`, or `global/`, and that every consumer claimed in `chapters/personalization/19g-field-effects.md` actually reads what it claims to read.

## Done criteria

- [ ] Every field in `profile-template.md` grep'd across the repo; consumer count recorded.
- [ ] Every consumer claimed in `19g-field-effects.md` verified to actually consume the named field (by grep + file inspection).
- [ ] Decorative fields (no real consumer) listed.
- [ ] Orphan consumers (skill/chapter reads a field not declared in the profile template) listed.
- [ ] `FIXES.md` A2 entries cross-checked (already names 4 known decorative fields: Plans dir G2, Push-back Q4, Active signals D1, Session shape G1). Confirm + close or extend severity.
- [ ] Findings appended; blocking entries to `FIXES.md`.

## Out of scope

- Architectural / router-shape audit (Section 1).
- Skill-trigger accuracy (Section 4).
- Profile UX / question wording — that's a separate UX pass, not in this audit.

## Files to read for project understanding

- `CLAUDE.md` — the personalization claim, under "What makes this project genuinely different §2".
- `chapters/personalization/19g-field-effects.md` — the field → consumer map (canonical source of truth).
- `chapters/personalization/19a-overview.md`, `19b-profile-and-onboarding.md`, `19f-subscription-aware.md` — for field-consumption patterns.
- `skills/core/op-onboard/profile-template.md` — the field list.
- `FIXES.md` — A2 cluster.
- This file.

## Session 1 — Field/consumer coverage audit (to be detailed)

**Status**: `pending`

Sketch:

1. Extract field list from `profile-template.md`.
2. Extract claimed consumers from `19g-field-effects.md` (each row in the table).
3. For each field: grep across `chapters/` + `skills/` + `global/`; verify consumer claim.
4. List decorative fields (no consumer) and orphan consumers (read field not declared).
5. Confirm or extend `FIXES.md` A2.
6. Findings + FIXES triage.

## Findings

_(populated when session runs)_

## Session log

_(empty)_
