# Section: audit-05-self-discipline

> Section 5 of the audit pass. See `docs/PROJECT_PLAN.md`.
> **Stub — Session 1 to be fully detailed just before this section starts.**
> **Audit phase: WRITE FINDINGS ONLY.** No edits to `chapters/`, `skills/core/`, code, or templates.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints.

## Section goal

Audit whether the project follows its own discipline. Walk the **12 anti-drift rules** declared in `CLAUDE.md` and the rules in `chapters/anti-patterns/` against the actual repo state. Find rule violations introduced by the spine itself — the place where "discipline taught" diverges from "discipline lived."

## Done criteria

- [ ] Each of the 12 anti-drift rules in `CLAUDE.md` checked against repo state. Pass / fail / partial recorded per rule.
- [ ] Each chapter in `chapters/anti-patterns/` (18a–18h) scanned for violations the spine itself commits.
- [ ] Hard-coded magic numbers (anti-drift rule #10) grepped — `30`, `7200`, `5+`, `300`, etc.
- [ ] `FIXES.md` verified action-queue-shaped per rule #1 — every entry discrete + triageable, no narrative drift.
- [ ] `CHANGELOG.md` conforms to Keep-a-Changelog format (rule #2) — spot-check `[Unreleased]` + `[0.11.0]`.
- [ ] Count-claim discipline (rule #11) cross-checked against Section 1 findings (no duplication — extend not duplicate).
- [ ] Findings appended; blocking entries to `FIXES.md`.

## Out of scope

- Architectural-layout audit (Section 1).
- Token-cost analysis (Section 2).
- Personalization-coverage audit (Section 3).
- Skill-trigger accuracy (Section 4).
- Test coverage (Section 6).

## Files to read for project understanding

- `CLAUDE.md` — the 12 anti-drift rules (numbered, under "Anti-drift" section).
- `chapters/anti-patterns/18a..18h` — the catalog of anti-patterns the spine teaches.
- `FIXES.md`, `CHANGELOG.md`, `RECONSTRUCTION.md`, `INDEX.md`, `EXPLAINER.md`, `README.md` — the top-level docs whose discipline is under audit.
- Top of `chapters/` and `skills/core/` for surface inventory.
- `docs/archive/` — to confirm point-in-time docs were properly archived (rule #5).
- This file.

## Pre-flagged findings (captured before Session 1 runs)

User-validated issues to confirm + escalate during Session 1. Do not skip — these are not hypotheses, they have already been validated in conversation. Session 1's job is to confirm extent + propose the fix locus, then escalate to `FIXES.md`.

- **PF1 — Work-shape-aware preparation discipline (feature shipped 2026-05-28; verify integration).** Conversation 2026-05-28: when planning a multi-section audit, the spine had no chapter or skill that surfaced the rule "if apply sessions interleave with audit sessions, apply-N mutates state audit-N+1 was about to read — findings become incoherent across sections and apply sessions can re-break each other's fixes." Caught by the user, not the spine. The user widened the catch into a structural ask: make preparation-first thinking a core spine feature, with auto-fire trigger recognition. Built as Section 0 of the project plan (`docs/plans/section-0-approach-feature.md`) BEFORE this audit begins. **What was shipped**: `skills/core/op-approach/SKILL.md` (auto-fires on big-work phrases) + `chapters/workflow/05k-work-shapes.md` (7-shape catalog: Build / Audit / Refactor / Migration / Investigation / Research / Cleanup with phase order + hard rule + traps per shape) + cross-references in `chapters/workflow/05h-multi-session-planning.md` anti-patterns and `skills/core/op-prepare/SKILL.md` (sibling skills + when-NOT-to-fire) + `INDEX.md` row. Audit-shape's hard rule (cross-section coherence) now lives natively in 05k. **Session 1's job (changed from "escalate the gap"): confirm the integration is wired correctly + propose any remaining refinements** — specifically: (a) trigger description still right? does it overlap dangerously with op-prepare? (b) does `op-prepare/procedure.md` need a "first call op-approach" step? (c) should `chapters/anti-patterns/18g-workflow.md` carry a sibling entry on work-shape-blindness? **Severity**: `info` (was `blocking` before Section 0 shipped).

- **PF2 — Heartbeat hook reports working-tree dirty files, not per-turn delta (drift / hook bug).** `global/hooks/spine-writeback.sh:247` computes the `CHANGED` heartbeat list via `git status --porcelain | head -n 8` — capturing **everything dirty in the working tree**, not files modified this turn. Live evidence in `docs/plans/audit-02-token-cost.md`'s Session log: two heartbeats dated 2026-05-28 14:46 / 14:53 list `chapters/anti-patterns/18d-tools.md`, `chapters/anti-patterns/18f-security.md`, `CHANGELOG.md`, etc. — none of which were edited by audit-02 (Session 1 status: `pending`; never started). Those entries are pre-existing round-6 / launch-prep dirt that became "touched:" the moment PROGRESS.md pointed at audit-02. **Effect**: audit-phase Session logs make it look like `chapters/` is being edited under the READ-ONLY rule — a false alarm that erodes trust in the audit trail and misleads `op-spine-active` on the next conversation's cold-start. **Fix locus**: rewrite the `CHANGED=` block in `spine-writeback.sh` to compute delta-since-last-turn (e.g., diff against a `$TMPDIR/.spine-last-heartbeat-tree-state` marker, or against `HEAD@{session-start}` if a SESSION_ID-keyed marker file is created at session open). **Severity**: drift (false alarm in the audit trail, not a discipline violation by the audit phase itself).

- **PF3 — `op-spine-active` has no "section stubbed / awaiting `/prep`" handler (design gap).** Skill's Step 2 currently handles three cases: missing active section field, missing section file, session marked `done`. There is no case for "section file exists, session status = `pending`, body is a 5-line sketch awaiting `/prep`." When the active pointer lands on a stubbed audit section (the post-`/done` resting state for audit-02..06), the skill announces scope from the sketch and proceeds to build — exactly the wrong move. PROGRESS.md's "Next session reading list" carries the "run `/prep` first" directive narratively, but the skill itself doesn't enforce it. **Fix locus**: `skills/core/op-spine-active/SKILL.md` Step 2 — add a fourth bullet: "Session entry status = `pending` AND body contains a sketch marker (`to be detailed` / `(to be drafted via /prep)` / `Sketch:` heading) → tell the user *'Section is stubbed; run `/prep <section>` to detail Session 1 before executing.'* Stop here." (The current `audit-02-token-cost.md` pre-flight block plus the Audit-phase pre-flight protocol in PROJECT_PLAN.md compensate textually until this lands.) **Severity**: design gap (the existing flow doesn't error, but defaults to the wrong path on stubbed sections — making the audit-phase lazy-planning rule depend on user discipline rather than skill enforcement).

- **PF4 — `/done` doesn't sweep the section file's own Session 1 status (drift).** `global/commands/done.md` Step 2.1 says: *"Session status — change from `in-progress` to: `done` | `blocked` | `in-progress`."* This step is interpreted by running sessions as updating PROGRESS.md's active-session-status, not the section file's per-session-entry Status. Live evidence: `docs/plans/section-0-approach-feature.md:53` still reads `**Status**: in-progress` for Session 1, even though Section 0 is marked done in PROGRESS.md and PROJECT_PLAN.md Status log records the close. The drift is cosmetic for closed sections (Section 0 is shipped) but indicates a hole in `/done`'s self-completion sweep that could matter when a re-opened section reads its own status. **Fix locus**: `global/commands/done.md` Step 2 — clarify that BOTH PROGRESS.md and the section file's session entry need the status update, or restructure Step 2.1 to read *"edit the section file's Session N entry Status"* with PROGRESS.md getting a separate explicit pointer-update bullet under Step 4. **Severity**: drift (closed sections retain stale per-session status; not blocking but surfaces during inspection).

- **PF5 — `Read(**/*token*)` deny rule blocks reading audit-02 section file (drift / safety-rule overreach).** Settings.json's secret-file deny matcher false-positives on `docs/plans/audit-02-token-cost.md` because the section name contains the literal substring `token`. Symptom: `Read` errors with *"File is in a directory that is denied by your permission settings"*; Bash `cat` / `awk` under the same matcher also blocked. **Effect**: `op-spine-active`'s Step 1 (*"Read `<plans-dir>/<active-section>.md`"*) cannot complete on this user's install while audit-02 is active without a workaround (`cp` to non-matching path, then Read). Audit-01 already flagged this in Cross-section notes; PF5 captures the fix-locus assignment. **Fix locus**: tighten `global/settings.json` deny matcher from `Read(**/*token*)` to `Read(**/*_token*)` (requires the underscore prefix common to `auth_token`, `access_token`, etc.) — or add explicit allow `Read(docs/plans/**)`. Repaired matcher applies to future installs via the install.sh template; the user's running `~/.claude/settings.json` would need a one-line manual sync until next `/onboard --deep` settings-merge. **Severity**: drift / overreach (security rule catches more than intended; user-facing breakage now visible on audit-02).

## Session 1 — Self-discipline sweep (to be detailed)

**Status**: `pending`

Sketch:

1. Confirm PF1 integration (feature shipped in Section 0). Read `skills/core/op-approach/SKILL.md` + `chapters/workflow/05k-work-shapes.md` + the 05h / op-prepare / INDEX cross-references. Check: trigger description specific enough? phrases comprehensive? overlap with op-prepare clean? `op-prepare/procedure.md` step needed? `chapters/anti-patterns/18g-workflow.md` sibling entry warranted? Write findings; escalate residue to `FIXES.md` only if real.
2. Walk anti-drift rules 1–12 from `CLAUDE.md`; check each against repo state. Record pass/fail/partial.
3. Walk anti-pattern chapters 18a–18h; for each rule taught, check whether the spine itself respects it.
4. Grep for magic-number / hard-coded threshold smells (rule #10).
5. Spot-check rule #6 (routers stay router-shaped) — overlaps with Section 1, defer to those findings.
6. Findings + FIXES triage.

## Findings

_(populated when session runs — PF1 above will be the first row)_

## Session log

_(empty)_
