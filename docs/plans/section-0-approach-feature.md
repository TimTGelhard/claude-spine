# Section: section-0-approach-feature

> Section 0 of the audit + apply pass. See `docs/PROJECT_PLAN.md`.
> **Phase 0 = feature build, not audit.** This section *does* edit `chapters/` and `skills/core/`. It happens BEFORE any audit section runs, so the audit-then-apply rule is not violated (rule is "no edits between audits"; no audit has started yet).
> **Audit phase begins after Section 0 is `done`.** Hard rule.

## Section goal

Add a missing core feature: **work-shape-aware preparation discipline** that fires before any non-trivial work and identifies the work shape, default phase structure, hard rule, and common traps for that shape. The miss this addresses: the spine has no skill or chapter today that surfaces the meta-question *"what shape is this work?"* before planning starts. Without it, agents (and users) interleave audit + apply, smuggle feature work into refactors, leave migrations half-done, spike code into production, and delete live code thinking it's dead — all the same family, *work-shape-blindness*.

This section ships:
- `skills/core/op-approach/SKILL.md` — router that fires on big-work phrases and routes to the catalog chapter.
- `chapters/workflow/05k-work-shapes.md` — the 7-shape catalog (Build / Audit / Refactor / Migration / Investigation / Research / Cleanup), each with default phases, hard rule, common traps.
- Cross-references added to `chapters/workflow/05h-multi-session-planning.md` (anti-patterns + see-also), `skills/core/op-prepare/SKILL.md` (note that op-approach fires before it for non-build work), and `INDEX.md` (new row + section-routing annotation).
- Count claims swept (22 → 23 op-* skills; 80 → 81 chapters) across the eight files named in `CLAUDE.md` rule 11.
- `CHANGELOG.md [Unreleased]` entry.
- `audit-05-self-discipline.md` PF1 widened to reflect the feature now exists (audit-05 confirms integration, not gap).

## Done criteria

- [ ] `skills/core/op-approach/SKILL.md` exists. Router-shape (~60 lines). Trigger description covers the audit / refactor / migration / investigation / "improve the project" / "tackle this big thing" / multi-domain phrases. Body routes to `05k` and hands off to `op-prepare`.
- [ ] `chapters/workflow/05k-work-shapes.md` exists. Lists all 7 shapes with default phases, hard rule, common traps. Cross-refs back to existing chapters (05a–05g for Build; 05h for multi-session) and forward to `op-approach`.
- [ ] `chapters/workflow/05h-multi-session-planning.md` carries a "cross-section coherence" anti-patterns entry and a See-Also pointer to `op-approach` + `05k`.
- [ ] `skills/core/op-prepare/SKILL.md` mentions `op-approach` in its "Sibling skills" + "When NOT to fire" sections (op-prepare doesn't replace op-approach; op-approach runs first for non-build).
- [ ] `INDEX.md` Workflow section: new row for `05k-work-shapes.md` and `op-approach` listed in the section-routing annotation line.
- [ ] Count sweep: README, EXPLAINER, install.sh, INSTALL.md, `chapters/personalization/19b-profile-and-onboarding.md`, `global/commands/onboard.md`, `skills/core/op-welcome/SKILL.md`, `skills/core/op-onboard/SKILL.md`, and `CLAUDE.md`'s "Current state" line. 22 → 23 op-* skills; 80 → 81 chapters.
- [ ] `audit-05-self-discipline.md` PF1 re-framed: feature shipped; Session 5's job is now to confirm the integration is wired correctly + propose any small refinements, not escalate the gap.
- [ ] `CHANGELOG.md [Unreleased]` gets `Added` bullets for `op-approach` + `05k-work-shapes.md` and a `Changed` bullet for 05h + op-prepare + INDEX cross-references.
- [ ] `docs/PROGRESS.md` advanced to mark Section 0 `done` and re-point at audit-01.
- [ ] `tests/run.sh` fast suite passes (no test file modified by this section, but a sanity check is cheap).

## Out of scope

- Editing `op-prepare/procedure.md` to inject an explicit "first call op-approach" step — defer to audit-05 / apply phase; the cross-reference in SKILL.md is sufficient for the routing layer to fire op-approach before op-prepare on non-build work.
- Adding `op-approach` to `chapters/anti-patterns/18g-workflow.md` as a sibling entry — defer to audit-05 finding (PF1 sub-locus c).
- Building per-shape sub-skills (`op-audit`, `op-refactor`, etc.) — out of scope; op-approach + 05k catalog is sufficient v1.
- Audit-section work (sections 1–6). Phase 0 ships, then audit-01 begins.
- Apply-section work for any other `FIXES.md` items. Phase 0 is a feature add, not consuming from FIXES.

## Files to read for project understanding

- `CLAUDE.md` — soul + 12 anti-drift rules. Rules 6 (router-shape) + 7 (atomic chapter sizing) + 10 (no magic numbers) + 11 (sweep count claims) apply to this build.
- `INDEX.md` — Workflow section + section-routing annotation conventions.
- `skills/core/op-prepare/SKILL.md` — sibling skill shape, what op-approach should mirror.
- `skills/core/op-spine-active/SKILL.md` — auto-fire pattern reference (op-approach fires similarly when triggers match).
- `chapters/workflow/05h-multi-session-planning.md` — where the anti-patterns entry + see-also goes.
- `chapters/workflow/05i-execution-plan-anatomy.md` — existing sibling for what 05k should mirror in shape.
- `chapters/persistence/13a-skill-anatomy.md` + `13b-trigger-descriptions.md` — skill design conventions.
- This file.

## Session 1 — Build op-approach + 05k

**Status**: `done` (2026-05-28)

Step-by-step:

1. **Insert Section 0** into `PROJECT_PLAN.md` Sections table; renumber dependencies of audit-01..06 to include `0`; expand Order rationale with Phase 0 paragraph; log in Status log.
2. **Create this section plan file** (`docs/plans/section-0-approach-feature.md`).
3. **Update `docs/PROGRESS.md`** to point at section-0 / Session 1.
4. **Write `skills/core/op-approach/SKILL.md`**. Trigger description specific enough to fire on the right phrases without false positives on simple build work. Body: 4-section router (When to fire / What to do / Output shape / Sibling skills + See-also).
5. **Write `chapters/workflow/05k-work-shapes.md`**. Header + 7 shape sections (each: default phases, hard rule, common traps, route-to). Footer: ambiguity guidance + hybrid guidance + TL;DR + cross-references.
6. **Edit `chapters/workflow/05h-multi-session-planning.md`**: add "cross-section coherence" anti-patterns entry; add see-also pointers to `op-approach` + `05k`.
7. **Edit `skills/core/op-prepare/SKILL.md`**: add op-approach to "Sibling skills" + a note under "When NOT to fire" that for non-build multi-session work, op-approach fires first.
8. **Edit `INDEX.md`**: new row for 05k under Workflow; mention `op-approach` in the section-routing annotation line.
9. **Sweep count claims** (rule 11): grep for "22 op-*" / "80 chapter" / equivalent phrasings; bump to 23 / 81 across the 9 files named in Done criteria.
10. **Re-frame audit-05 PF1**: feature shipped; Session 5 confirms integration rather than escalating the gap.
11. **CHANGELOG `[Unreleased]`**: add Added + Changed bullets per the Keep-a-Changelog format (slim).
12. **Status log** in `PROJECT_PLAN.md`: append entry noting Section 0 shipped, audit phase now begins.
13. **Run `tests/run.sh`** fast suite to confirm nothing broke.
14. **Mark Section 0 `done`** and re-point `PROGRESS.md` at `audit-01-architecture` / Session 1.

## Findings

_(this is a build session, not an audit; no findings table needed — decisions captured in the Session log)_

## Session log

_(populated as Session 1 progresses; one bullet per substantive decision or surprise)_
- session 1 @ 2026-05-28 14:12 — touched: .gitignore CHANGELOG.md EXPLAINER.md INDEX.md README.md RECONSTRUCTION.md chapters/anti-patterns/18d-tools.md chapters/anti-patterns/18f-security.md
