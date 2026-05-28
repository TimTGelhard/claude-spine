# Section: audit-01-architecture

> Section 1 of the audit pass. See `docs/PROJECT_PLAN.md` for the full master plan.
> **Audit phase: WRITE FINDINGS ONLY.** Do not edit `chapters/`, `skills/core/`, code, or templates in this section. Blocking findings flow to `FIXES.md` for apply sessions later.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints — interleaving audit + apply breaks coherence across sections.

## Section goal

Audit the project's structural integrity against its own 5-layer architecture (skills → chapters → INDEX → bucket → global) declared in `CLAUDE.md`. Verify that op-* SKILL.md files route rather than carry teaching content; chapters are atomic (one concept per file); INDEX.md matches the actual `chapters/` tree; and the headline count claims (post-Section-0 baseline: **23 op-* / 9 commands / 4 default + 2 opt-in hooks / 84 chapters**) are accurate everywhere they appear.

## Done criteria

- [ ] Every `skills/core/op-*/SKILL.md` reviewed for router shape (content type, not just length).
- [ ] Every `chapters/<topic>/*.md` file > 200 lines spot-checked for multi-concept content.
- [ ] `INDEX.md` cross-checked against actual `chapters/` folders in both directions.
- [ ] Count claims swept across CLAUDE.md, README.md, EXPLAINER.md, install.sh, INSTALL.md, landing/index.html, op-welcome/SKILL.md, op-onboard/SKILL.md, 19b-profile-and-onboarding.md.
- [ ] All findings logged in the "Findings" table below with severity.
- [ ] Blocking findings appended to `FIXES.md` under a new `A13+` cluster.
- [ ] PROGRESS.md advanced to audit-02 at `/done`.

## Out of scope (do not drift here)

- **No edits to `chapters/`, `skills/core/`, or code.** Audit phase = write findings only.
- **No benchmark runs.** Section 2 (`audit-02-token-cost`) owns token-cost measurement.
- **No profile-field auditing.** Section 3 (`audit-03-personalization`) owns personalization.
- **No SKILL.md description rewrites.** Section 4 (`audit-04-skill-triggers`) owns triggering accuracy.
- **No anti-pattern audit beyond architecture.** Section 5 (`audit-05-self-discipline`) owns the broader self-discipline sweep.
- **No test-coverage audit.** Section 6 (`audit-06-tests-docs`) owns tests + docs freshness.

If a finding touches another section's surface, capture it in "Cross-section notes" below and move on. Do not bundle.

## Files to read for project understanding (cold-start orientation)

Read in this order at session start. Stop after this list — do not pull additional files until the procedure step calls for them.

1. `CLAUDE.md` — the project soul. The 5-layer architecture, 12 anti-drift rules, 3 load-bearing claims live here. Canonical reference for "what should be true."
2. `INDEX.md` — chapter routing fallback. Section list ↔ chapter folder map.
3. `RECONSTRUCTION.md` — frozen v2 architectural decisions. Supporting evidence for "why is X shaped this way."
4. `FIXES.md` — current open queue. Anything already named in `A1`–`A12` is known; avoid duplicate findings, escalate severity instead.
5. `docs/PROJECT_PLAN.md` — this audit's master plan.
6. This file.

## Pre-flagged findings (captured before Session 1 runs)

- **PF1 — Count-claim sweep already executed (Section 0, 2026-05-28).** During Section 0's pre-audit feature add, the 11-edit count-claim sweep ran across `CLAUDE.md`, `README.md`, `install.sh`, `skills/core/op-welcome/SKILL.md`, `landing/index.html`. Post-sweep claims read "23 op-* skills" and "84 atomic chapters" (exact numbers, no tilde). The sweep also resolved a pre-existing tilde-claim that the work uncovered: docs previously said `~80 chapters` but actual count was 83 before Section 0; post-feature is exact 84. **Session 1's job (changed from "discover the drift" → "verify the sweep is complete and consistent")**: grep the five files above for any residual stale numbers (`22 op-`, `~80`, `19 task-routers`, `83 atomic`, etc.) the sweep might have missed; cross-check against `EXPLAINER.md`, `global/INSTALL.md`, `op-onboard/SKILL.md`, `chapters/personalization/19b-profile-and-onboarding.md`, `INDEX.md`, `RECONSTRUCTION.md` — any of those that names a count must match the new exact totals. **Severity**: `info` (was `blocking` before Section 0 swept).

## Cross-section notes

Discoveries that affect later sections.

_(populated as findings emerge during Session 1)_

## Section-level open questions

- _(none)_

---

## Session 1 — Architectural integrity sweep

**Status**: `pending`

**Goal**: Produce a triaged findings table naming every router-shape violation, multi-concept chapter, INDEX divergence, and count-claim drift. No code or content edits.

**Files to read** (orient list — exact cold-start budget):

- `CLAUDE.md`
- `INDEX.md`
- `RECONSTRUCTION.md`
- `FIXES.md`
- `docs/PROJECT_PLAN.md`
- This section file.

Additional files opened during the procedure (steps 1–7 below) are read on-demand, not as part of the orientation budget.

**Files to write/edit** (scope — anything else is out of bounds without explicit pause):

- This section file's "Findings" table (populate).
- `FIXES.md` — append a new `A13+` cluster entry per blocking finding.
- `docs/PROGRESS.md` — advance pointer at `/done`.

**Build steps**:

1. **Inventory.** Capture actual counts:
   ```bash
   wc -l skills/core/op-*/SKILL.md | sort -n
   find chapters -name "*.md" -type f | xargs wc -l | sort -n
   ls chapters/
   ls global/commands/
   ls global/hooks/
   ```
   Record: actual count of op-* skills, slash commands, hooks (default-on + opt-in separately), chapter files, chapter folders.

2. **Router-shape audit.** For each `skills/core/op-*/SKILL.md`:
   - Open and read. Is the body making routing decisions ("if X, read chapter Y") or carrying teaching content (procedure steps, question banks, anti-pattern lists)?
   - Flag any SKILL.md that crosses into teaching. **Length alone is not the diagnosis** — content type is. A 200-line router can be fine; a 60-line skill carrying step-by-step procedure is not.
   - Cross-check against the rule in `CLAUDE.md`: "If a SKILL.md is carrying procedure steps, question banks, or teaching material, it has stopped being a router."
   - Confirm adjacent-file pattern is used where applicable (`op-onboard/questions-deep.md`, `op-prepare/procedure.md`, etc.).

3. **Chapter-atomicity audit.** For each `chapters/<topic>/*.md` over 200 lines:
   - Open and skim for multi-concept content. Does the file teach one concept, or two?
   - If two: name the seam where the file should split.
   - For files under 200 lines: trust them unless a router or INDEX entry suggests something's off.

4. **INDEX accuracy.** Compare `INDEX.md`'s section list against the actual `chapters/` folder list:
   - Folders in `chapters/` not represented in `INDEX.md`.
   - INDEX sections that point at folders that don't exist.
   - Chapter files listed in INDEX but missing from disk (or vice versa).

5. **Count-claim sweep.** Compare actual counts (from step 1) against claims in:
   - `CLAUDE.md` (Current state section).
   - `README.md`.
   - `EXPLAINER.md`.
   - `install.sh` (post-install summary).
   - `global/INSTALL.md`.
   - `landing/index.html`.
   - `skills/core/op-welcome/SKILL.md`.
   - `skills/core/op-onboard/SKILL.md`.
   - `chapters/personalization/19b-profile-and-onboarding.md`.
   - `CHANGELOG.md` `[Unreleased]` and `[0.11.0]`.
   
   Known drift already in `FIXES.md`: **A7** (hook count drift — CLAUDE.md says "6 default + 2 opt-in", actual is "4 default + 2 opt-in") and **A8** (landing page lists 9 chapter folders, actual is 10). Avoid duplicating — confirm + reference, or upgrade severity if appropriate.

6. **Layer-boundary check.** Scan for upward references (chapters citing skills, skills citing each other in non-routing ways). Spot-check 3–5 files chosen randomly across topics.

7. **Log findings.** Append to the "Findings" table below using this format:
   ```
   | F# | Severity | File / Loc | Finding | Recommendation |
   ```
   Severities:
   - `blocking` — must fix before further work in this area.
   - `drift` — count / cross-ref drift, schedule normally.
   - `polish` — improvement, not strictly broken.

8. **Triage to `FIXES.md`.** For every `blocking` finding: append under a new heading `## Architecture-audit follow-ups (A13+, 2026-05-28)` (or extend an existing cluster if appropriate). Keep each entry one paragraph; link back to this section file for detail. **Keep entries action-shaped** — if the cluster needs narrative (rationale, discovery context, comparative analysis), let that live in this section file's Findings table and write a single one-paragraph summary entry in FIXES that links here. Discipline is queue-shape, not line count.

**Verify**:

- Every op-* SKILL.md was opened (not just listed). Verify by checking the inventory output covers all 22.
- Every `chapters/<topic>/` folder appears in the INDEX comparison output.
- Counts sourced from disk (step 1) match each file checked in step 5, or each divergence is logged with file:line reference.
- At least one finding exists in the Findings table OR the section file explicitly states "no findings" with the step-1 inventory snapshot as evidence.
- `FIXES.md` after the session is queue-shaped: every entry a discrete, triageable action item; no narrative essays. If audit-01's cluster has drifted into narrative, compact it back into action items + link to this section file's Findings table for the detail before merge.

**Output**:

- Commit message hint: `docs(audit): section 1 — architectural integrity findings`
- Update at `/done`: this section file (Findings filled, status `done`), `docs/PROGRESS.md` (pointer → `audit-02-token-cost`, refresh next session reading list), `FIXES.md` (new `A13+` cluster entries if any).

---

## Findings

_(populated when Session 1 runs — table format: `| F# | Severity | File / Loc | Finding | Recommendation |`. Severities: `blocking` / `drift` / `polish`.)_

---

## Session log

_(per-turn heartbeats appended automatically by `spine-writeback.sh` Stop hook during the active session)_

### 2026-05-28
- Section drafted. Awaiting Session 1.

- session 1 @ 2026-05-28 15:39 — touched: .gitignore CHANGELOG.md EXPLAINER.md FIXES.md INDEX.md README.md RECONSTRUCTION.md chapters/anti-patterns/18d-tools.md
