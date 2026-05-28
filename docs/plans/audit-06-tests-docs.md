# Section: audit-06-tests-docs

> Section 6 of the audit pass. See `docs/PROJECT_PLAN.md`.
> **Stub — Session 1 to be fully detailed just before this section starts.**
> **Audit phase: WRITE FINDINGS ONLY.** No edits to `chapters/`, `skills/core/`, code, or templates.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints.
> Depends on Section 1 (counts) and Section 5 (discipline) so this section can focus on coverage + freshness rather than re-deriving baselines.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — run `/prep audit-06-tests-docs` first; check carried-forward cross-section notes; verify the heartbeat-hook caveat (Session log `touched:` lines may include working-tree dirty files, not edits made by this section).

## Section goal

Audit **test coverage + documentation freshness**. Map `tests/run.sh` suites to the features they cover, find untested code paths (hooks, install.sh branches, /onboard variants), and sweep documentation cross-references — broken links, orphaned files in `docs/archive/`, stale count claims not already caught by Section 1.

## Done criteria

- [ ] Each suite in `tests/run.sh` mapped to the feature(s) it tests.
- [ ] Untested code paths listed (with rough effort estimate to close).
- [ ] All cross-references in `INDEX.md`, `README.md`, `EXPLAINER.md`, `RECONSTRUCTION.md`, `CHANGELOG.md` verified live (no 404s to other files in the repo).
- [ ] `docs/archive/` files reviewed — any with stale-references back to live docs flagged (each archive file should have a preamble pointing at its live successor, per `CLAUDE.md` rule #5).
- [ ] `landing/index.html` references swept for stale text (Section 1 covered counts; this covers structure / link freshness).
- [ ] Findings appended; blocking entries to `FIXES.md`.

## Out of scope

- Architectural / personalization / token-cost / self-discipline audits (Sections 1, 2, 3, 5).
- Writing new tests — apply session, not this audit.
- Fixing broken refs — apply session.

## Files to read for project understanding

- `tests/run.sh` and `tests/<suite>/` directory structure.
- `README.md`, `INDEX.md`, `EXPLAINER.md`, `CHANGELOG.md`, `RECONSTRUCTION.md`.
- `docs/archive/` (skim for stale preambles + dangling refs).
- `landing/index.html`.
- `FIXES.md`.
- This file.

## Session 1 — Test + docs freshness sweep (to be detailed)

**Status**: `pending`

Sketch:

1. Map test suites to features. Identify untested code paths.
2. Sweep cross-references between top-level docs.
3. Review `docs/archive/` for stale preambles + dangling pointers.
4. Spot-check `landing/index.html` for structural drift (Section 1 already covered counts).
5. Findings + FIXES triage.

## Findings

_(populated when session runs)_

## Session log

_(empty)_
