# Section: audit-05-self-discipline

> Section 5 of the audit pass. See `docs/PROJECT_PLAN.md` for the full master plan.
> **Audit phase: WRITE FINDINGS ONLY.** No edits to `chapters/`, `skills/core/`, `global/` (hooks / settings / commands), code, or templates — even though this section's findings (PF2–PF5) *target* `global/`. Findings are text; the fixes are an apply session.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints — interleaving audit + apply breaks coherence across sections.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — the four conditions every audit session must satisfy (this section's `/prep` pass, completed 2026-05-29, satisfies condition 1).
> Depends on Section 0 (`op-approach`, for PF1). Reads against the same frozen post-Section-0 snapshot as audits 01–04, and **consolidates** their rule-relevant findings rather than re-discovering them.

## Section goal

Audit whether the project follows its own discipline — the one audit that holds the spine to *its own declared standard*. Two surfaces: (1) the **12 anti-drift rules** in `CLAUDE.md` § "Anti-drift", scored pass / fail / partial against actual repo state; (2) the anti-pattern chapters `chapters/anti-patterns/18a–18h` — for each anti-pattern the spine *teaches*, does the spine itself *commit* it? Find the places where "discipline taught" diverges from "discipline lived."

Two things make this section different from a from-scratch sweep:

- **Consolidation, not re-discovery.** Audits 01–04 already surfaced rule-relevant findings (INDEX gap → rule 4; router-shape drift → rule 6; the `Prep*` hardcode → rule 10; count-claim residuals → rule 11). Audit-05 *cites and consolidates* these into a single rule-adherence scorecard — it does not re-open them. Re-finding them would itself violate the cross-section-coherence discipline this audit checks for.
- **The audit phase is itself a dogfooding sample.** Running this very audit surfaced four infrastructure bugs (PF2–PF5) — the spine's own workflow machinery (`spine-writeback.sh`, `op-spine-active`, `/done`, `settings.json`) not living up to the discipline. Confirming + escalating those is core to this section, not incidental.

The headline candidate: load-bearing **claim #1** ("token efficiency is the central design constraint") as *worded* in `CLAUDE.md` L34 / `README` / `landing` is contradicted by the spine's *own* measurement (audit-02 LC1: spine-on **+75.9%** input tokens). The purest "taught ≠ lived" instance available — confirm it as a self-discipline finding and check whether the A1 reframe surface is complete.

## Done criteria

- [ ] Each of the **12** anti-drift rules scored pass / fail / partial against repo state, with a `file:line` evidence pointer per verdict (scorecard table; consolidations cite the prior audit's finding, not re-derived).
- [ ] Each anti-pattern chapter `18a–18h` scanned; per chapter, a "does the spine commit this? Y/N + evidence" verdict (deduped against the rule walk where they overlap — e.g. 18g ≈ rule 1).
- [ ] PF1–PF5 each confirmed (extent + fix locus) or downgraded with a stated reason; PF2–PF5 escalated to `FIXES.md` (new `A16` cluster — the four audit-infrastructure bugs).
- [ ] Hard-coded magic numbers (rule 10) grepped across `skills/`, `chapters/`, `global/commands/`; each hit triaged override-worthy (→ profile field) vs intrinsic. A2.5 (`Prep*`) consolidated, not re-found.
- [ ] Claim-#1 framing check: is `CLAUDE.md` L34 / `EXPLAINER` / `README` "saves tokens" wording contradicted by LC1, and does `FIXES.md` A1's reframe-surface list name every surface (it currently names README + landing — does it omit `CLAUDE.md` L34 / `EXPLAINER`)?
- [ ] `FIXES.md` verified action-queue-shaped (rule 1) + `CHANGELOG.md` spot-checked for Keep-a-Changelog conformance (rule 2).
- [ ] Findings appended; blocking entries to `FIXES.md`; cross-section notes for audit-06 populated; read-only compliance verified via `git diff` against the session-start commit.

## Out of scope (do not drift here)

- **Applying any fix.** PF2–PF5 target `global/` files; the proposed fixes are *Findings-table text + FIXES entries*. Editing `spine-writeback.sh`, `op-spine-active`, `done.md`, or `settings.json` is the apply phase — sequenced after all six audits are `done`.
- **Re-discovering audits 01–04's findings.** Rule 4 (INDEX gap, audit-01 F4 → A13), rule 6 (router-shape drift, audit-04 F7 + audit-01 F2/F3), rule 10 (the `Prep*` hardcode, audit-03 A2.5), rule 11 (count residuals, audit-01 F5/F6 + the audit-04 `/explain` ripple) are already escalated. **Cite them; do not re-open.**
- **Architecture layout** (Section 1, done), **token-cost measurement** (Section 2, done — audit-05 *uses* LC1's number, doesn't re-measure), **personalization wiring** (Section 3, done), **skill-trigger accuracy** (Section 4, done).
- **Test coverage / cross-reference validity / archive freshness** (Section 6) — log anything that touches it in Cross-section notes; don't bundle. (Rule 5's "are completed audit files archived?" question borders audit-06 — flag, don't resolve.)

If a finding touches another section's surface, capture it in "Cross-section notes" below and move on. Do not bundle.

## Files to read for project understanding (cold-start orientation)

Read in this order at session start. Stop after this list — pull individual anti-pattern chapters and the PF-target files on-demand during the build steps, not as part of the orientation budget.

1. `docs/PROJECT_PLAN.md` — § Constraints (audit-phase boundary + the all-six-before-apply rule) + § Audit-phase pre-flight protocol (the four conditions; heartbeat caveat = PF2).
2. `CLAUDE.md` — § "Anti-drift — the discipline this project applies to itself" (the **12 numbered rules** — the primary measuring stick) + the three load-bearing claims (claim #1 = the L34 framing under audit) + the "Never" list.
3. `chapters/anti-patterns/18a`–`18h` — the catalog of anti-patterns the spine teaches; read each (they're short). The dogfooding target.
4. `FIXES.md` — rule-1 audit subject (is it action-queue-shaped?) + the open A-clusters (A1 reframe surface, A2.5 `Prep*`, A13 drift, A15 triggers) to consolidate against + the next free cluster number (A16).
5. `CHANGELOG.md` — rule-2 audit subject (Keep-a-Changelog conformance; spot-check `[Unreleased]` + `[0.11.0]`/`[0.10.0]`).
6. `RECONSTRUCTION.md` (rule 3, frozen?), `INDEX.md` (rule 4), `README.md` + `EXPLAINER.md` (rules 8/11 + claim-#1 framing) — the top-level discipline surfaces under audit. Skim; deep-read only the parts a rule check points at.
7. `docs/archive/` — `ls` only: confirm point-in-time audits were archived (rule 5).
8. `chapters/workflow/05k-work-shapes.md` + `skills/core/op-approach/SKILL.md` — PF1 (verify the Section-0 integration; the 05h / op-prepare / INDEX cross-refs). NB audit-04 F1 already found `op-workflow`↔`op-prepare` collide — check whether `op-approach` adds a *third* planning-cluster collision.
9. The PF-target files, opened on-demand at step 1: `global/hooks/spine-writeback.sh` (~L247, PF2), `skills/core/op-spine-active/SKILL.md` (Step 2, PF3), `global/commands/done.md` (Step 2.1, PF4), `global/settings.json` (the `Read(**/*token*)` deny matcher, PF5).
10. `docs/plans/audit-01-architecture.md`, `audit-02-token-cost.md`, `audit-03-personalization.md`, `audit-04-skill-triggers.md` — § Findings + § Cross-section notes of each. The consolidation source: every rule-relevant finding to cite rather than re-derive.
11. The profile (`~/.claude/claude-spine-profile.md`) § "Spine defaults" — the set of thresholds *correctly* surfaced as profile fields (the rule-10 "good" reference; A2.5 is the "surfaced but not read" exception).
12. This file.

## Cross-section notes carried forward from audits 01–04

Per pre-flight protocol rule 4 (cross-section notes propagate manually). These are the rule-relevant findings audit-05 **consolidates** — each becomes a *cited* scorecard row, not a re-discovery:

- **[LOAD-BEARING] PF1 methodology (audit-01).** Grep-verify every "the spine does X" / "rule N is followed" claim against disk *before* recording a verdict. Audit-05 is the most claim-dense audit (12 rules + 8 chapters of self-assessment) — every pass/fail must be `file:line`-confirmed. PF1 caught Claude's own fabrications in audits 02/03 (invented citations, wrong field names); expect the same risk here.
- **[LOAD-BEARING] A1 reframe (audit-02 F0 / LC1).** Spine-on measured **+75.9%** input tokens vs spine-off. Claim #1's *wording* (CLAUDE.md L34 / README / landing) is contradicted. Audit-05 confirms this as the headline self-discipline finding and checks A1's reframe-surface completeness — **do not re-measure** (audit-02 owns the number).
- **Rule 4 — `INDEX.md` missing the `11g` row (audit-01 F4 → A13).** Cite in the rule-4 scorecard row; already escalated.
- **Rule 6 — router shape (audit-04 F7 + audit-01 F2/F3).** `op-curate`'s *description* over-covers (recites body procedure); `op-onboard`/`op-approach`/`op-prepare` carry redundant TL;DRs. Audit-04 explicitly handed audit-05 the **framing question**: does rule 6 ("routing skills stay router-shaped") extend to the `description:` field — the every-session classifier surface? Confirm + frame; cite F7, don't re-audit.
- **Rule 10 — the `Prep*` reverse-violation (audit-03 A2.5).** The 3 `Prep*` Planning fields are surfaced in the profile but hardcoded in `procedure.md`/`prep.md` — "a rule-10 violation in reverse." The rule-10 scorecard row's primary confirmed instance. Cite, consolidate.
- **Rule 11 — count-claim sweep (audit-04 `/explain` ripple + audit-01 F5/F6).** `/explain` added the 10th slash command; `op-welcome`'s body now says "10 slash commands" — did *every* count surface get the 9→10 sweep? Plus audit-01's README chapter-folder-enum residuals. Re-verify the 23 / 84 / 10 counts **as of now** across README/EXPLAINER/install.sh/19b/op-welcome/op-onboard/landing.
- **[LOAD-BEARING] The mechanize-the-discipline-check pattern (audit-04 F2/F3 + A12 + A15).** `op-persistence`/`op-signaling` were tightened once yet inter-skill overlaps survived (no overlap-regression check); A12 proposes `/profile verify`; audit-04 proposed `/trigger verify`. Three audits independently found the same root cause: **the spine has no automated self-linting, so drift accumulates silently between audits.** Audit-05's synthesis: is a `/discipline verify` warranted, and is "no self-lint" itself a discipline gap? → hand to audit-06.
- **Heartbeat caveat (PF2 / pre-flight rule 3).** `Session log` `touched:` lists the whole dirty working tree, not per-turn deltas. Verify read-only compliance via `git diff` against the session-start commit at `/done`, NOT the Session log. (Live evidence accruing in this file's own Session log + Pending block — see the self-referential 15:33 capture below.)
- **Coherence caveat — concurrent `/explain` + staged prior closes.** The working tree carries the staged audit-03/04 closes + uncommitted `/explain` residue. They appear in every heartbeat but are **not** audit-05 mutations. Verify by authorship + `git diff`. Same class as audit-03's 42nd-field and audit-04's op-welcome caveats.

## Cross-section notes (this section's own — populated as Session 1 runs)

- **For audit-06 (tests + docs).** (a) The mechanize-the-discipline-check pattern above — propose a `/discipline verify` (lint the 12 rules: count-claim consistency, FIXES queue-shape, no model-IDs outside `docs/MODELS.md`, an INDEX row per chapter) as the audit-06/apply analog of A12 `/profile verify` + A15 `/trigger verify`. The absence of self-linting is the shared root cause of inter-audit drift. (b) Rule 5: when the audit phase closes, should `docs/plans/audit-0*` move to `docs/archive/`? They're point-in-time audit records living as plan files — borders audit-06's archive-freshness check. (c) Whether `CHANGELOG`/`FIXES` shape needs a test fixture.
- **For the apply phase.** `A16` = the four audit-infrastructure bugs (PF2 heartbeat delta-tracking, PF3 `op-spine-active` stub-handler, PF4 `/done` section-status sweep, PF5 deny-matcher overreach). **Ordering tension (flag, don't resolve):** PF2 pollutes the audit trail and audit-06 will suffer the same false positives — but the all-six-before-apply hard rule forbids fixing it between audits. Audit-06 lives with the git-diff workaround (as 02–05 did); PF2 is an early-apply candidate the moment the phase closes.
- **For A1 (token-cost reframe).** If the claim-#1 framing check finds `CLAUDE.md` L34 / `EXPLAINER` carry the contradicted "saves tokens" wording and A1's surface list omits them, **extend A1** (don't open a new entry) — A1 is the canonical reframe home.

## Pre-flagged findings (captured before Session 1 runs)

User-validated issues to confirm + escalate during Session 1. Do not skip — these are not hypotheses, they have already been validated in conversation. Session 1's job is to confirm extent + propose the fix locus, then escalate to `FIXES.md`.

- **PF1 — Work-shape-aware preparation discipline (feature shipped 2026-05-28; verify integration).** Conversation 2026-05-28: when planning a multi-section audit, the spine had no chapter or skill that surfaced the rule "if apply sessions interleave with audit sessions, apply-N mutates state audit-N+1 was about to read — findings become incoherent across sections and apply sessions can re-break each other's fixes." Caught by the user, not the spine. The user widened the catch into a structural ask: make preparation-first thinking a core spine feature, with auto-fire trigger recognition. Built as Section 0 of the project plan (`docs/plans/section-0-approach-feature.md`) BEFORE this audit begins. **What was shipped**: `skills/core/op-approach/SKILL.md` (auto-fires on big-work phrases) + `chapters/workflow/05k-work-shapes.md` (7-shape catalog: Build / Audit / Refactor / Migration / Investigation / Research / Cleanup with phase order + hard rule + traps per shape) + cross-references in `chapters/workflow/05h-multi-session-planning.md` anti-patterns and `skills/core/op-prepare/SKILL.md` (sibling skills + when-NOT-to-fire) + `INDEX.md` row. Audit-shape's hard rule (cross-section coherence) now lives natively in 05k. **Session 1's job (changed from "escalate the gap"): confirm the integration is wired correctly + propose any remaining refinements** — specifically: (a) trigger description still right? does it overlap dangerously with op-prepare? (b) does `op-prepare/procedure.md` need a "first call op-approach" step? (c) should `chapters/anti-patterns/18g-workflow.md` carry a sibling entry on work-shape-blindness? **Severity**: `info` (was `blocking` before Section 0 shipped).

- **PF2 — Heartbeat hook reports working-tree dirty files, not per-turn delta (drift / hook bug).** `global/hooks/spine-writeback.sh:247` computes the `CHANGED` heartbeat list via `git status --porcelain | head -n 8` — capturing **everything dirty in the working tree**, not files modified this turn. Live evidence in `docs/plans/audit-02-token-cost.md`'s Session log: two heartbeats dated 2026-05-28 14:46 / 14:53 list `chapters/anti-patterns/18d-tools.md`, `chapters/anti-patterns/18f-security.md`, `CHANGELOG.md`, etc. — none of which were edited by audit-02 (Session 1 status: `pending`; never started). Those entries are pre-existing round-6 / launch-prep dirt that became "touched:" the moment PROGRESS.md pointed at audit-02. **Effect**: audit-phase Session logs make it look like `chapters/` is being edited under the READ-ONLY rule — a false alarm that erodes trust in the audit trail and misleads `op-spine-active` on the next conversation's cold-start. **Fix locus**: rewrite the `CHANGED=` block in `spine-writeback.sh` to compute delta-since-last-turn (e.g., diff against a `$TMPDIR/.spine-last-heartbeat-tree-state` marker, or against `HEAD@{session-start}` if a SESSION_ID-keyed marker file is created at session open). **Also surfaced this `/prep`:** the hook mis-filed a 15:33 heartbeat under `## Pending cross-session notes` rather than `## Session log`, and captured its *own* prior note line as a "cue phrase" (self-referential — see the Pending block below). Fold both into PF2's extent during Session 1. **Severity**: drift (false alarm in the audit trail, not a discipline violation by the audit phase itself).

- **PF3 — `op-spine-active` has no "section stubbed / awaiting `/prep`" handler (design gap).** Skill's Step 2 currently handles three cases: missing active section field, missing section file, session marked `done`. There is no case for "section file exists, session status = `pending`, body is a 5-line sketch awaiting `/prep`." When the active pointer lands on a stubbed audit section (the post-`/done` resting state for audit-02..06), the skill announces scope from the sketch and proceeds to build — exactly the wrong move. PROGRESS.md's "Next session reading list" carries the "run `/prep` first" directive narratively, but the skill itself doesn't enforce it. **Fix locus**: `skills/core/op-spine-active/SKILL.md` Step 2 — add a fourth bullet: "Session entry status = `pending` AND body contains a sketch marker (`to be detailed` / `(to be drafted via /prep)` / `Sketch:` heading) → tell the user *'Section is stubbed; run `/prep <section>` to detail Session 1 before executing.'* Stop here." (The current `audit-02-token-cost.md` pre-flight block plus the Audit-phase pre-flight protocol in PROJECT_PLAN.md compensate textually until this lands.) **Severity**: design gap (the existing flow doesn't error, but defaults to the wrong path on stubbed sections — making the audit-phase lazy-planning rule depend on user discipline rather than skill enforcement).

- **PF4 — `/done` doesn't sweep the section file's own Session 1 status (drift).** `global/commands/done.md` Step 2.1 says: *"Session status — change from `in-progress` to: `done` | `blocked` | `in-progress`."* This step is interpreted by running sessions as updating PROGRESS.md's active-session-status, not the section file's per-session-entry Status. Live evidence: `docs/plans/section-0-approach-feature.md:53` still reads `**Status**: in-progress` for Session 1, even though Section 0 is marked done in PROGRESS.md and PROJECT_PLAN.md Status log records the close. The drift is cosmetic for closed sections (Section 0 is shipped) but indicates a hole in `/done`'s self-completion sweep that could matter when a re-opened section reads its own status. **Fix locus**: `global/commands/done.md` Step 2 — clarify that BOTH PROGRESS.md and the section file's session entry need the status update, or restructure Step 2.1 to read *"edit the section file's Session N entry Status"* with PROGRESS.md getting a separate explicit pointer-update bullet under Step 4. **Severity**: drift (closed sections retain stale per-session status; not blocking but surfaces during inspection).

- **PF5 — `Read(**/*token*)` deny rule blocks reading audit-02 section file (drift / safety-rule overreach).** Settings.json's secret-file deny matcher false-positives on `docs/plans/audit-02-token-cost.md` because the section name contains the literal substring `token`. Symptom: `Read` errors with *"File is in a directory that is denied by your permission settings"*; Bash `cat` / `awk` under the same matcher also blocked. **Effect**: `op-spine-active`'s Step 1 (*"Read `<plans-dir>/<active-section>.md`"*) cannot complete on this user's install while audit-02 is active without a workaround (`cp` to non-matching path, then Read). Audit-01 already flagged this in Cross-section notes; PF5 captures the fix-locus assignment. **Fix locus**: tighten `global/settings.json` deny matcher from `Read(**/*token*)` to `Read(**/*_token*)` (requires the underscore prefix common to `auth_token`, `access_token`, etc.) — or add explicit allow `Read(docs/plans/**)`. Repaired matcher applies to future installs via the install.sh template; the user's running `~/.claude/settings.json` would need a one-line manual sync until next `/onboard --deep` settings-merge. **Severity**: drift / overreach (security rule catches more than intended; user-facing breakage now visible on audit-02).

## Rule-check map (reference for build step 2)

Per-rule check + known consolidation. ✎ = audit-05 owns fresh; ↻ = consolidate a prior audit (cite, don't re-open).

| # | Rule (`CLAUDE.md` § Anti-drift) | Check against repo | Source |
|---|---|---|---|
| 1 | FIXES = action queue, not narrative | Read FIXES end-to-end; every entry discrete + triageable? Judge the heavy inline blocks (A1 "LC1 EXECUTED…", A2 cluster) against rule 1's own "action-context vs narrative-essay" test | ✎ |
| 2 | CHANGELOG = Keep-a-Changelog | `[Unreleased]` + `[0.11.0]`/`[0.10.0]`: slim Added/Changed/Fixed/Removed, no per-pillar essays | ✎ |
| 3 | RECONSTRUCTION frozen | `git log -- RECONSTRUCTION.md`: recent *content* appends? (a forward-pointer edit is fine) | ↻ audit-01 F7 |
| 4 | INDEX = chapter router; sections name their skill | Every chapter file has an INDEX row? Each INDEX section names its routing skill? | ↻ audit-01 F4 → A13 |
| 5 | point-in-time audits → `docs/archive/` | `ls docs/archive/`; root + `docs/` clear of stray audits? (`docs/plans/audit-*` are live until the phase closes — note, don't fault) | ✎ |
| 6 | routers stay router-shaped | Spot-check long SKILL.md bodies route-not-teach + **the new question: does rule 6 extend to `description:`?** (F7) | ↻ audit-04 F7 + audit-01 F2/F3 |
| 7 | chapters atomic, sized to concept | Spot-check the longest chapters — any holding two concepts on a real seam? | ✎ spot-check |
| 8 | templates stack-agnostic | `templates/*.md` agnostic; worked examples under `examples/`? (only-one-web-example = A4 incompleteness, not a violation) | ↻ A4 / BA3 |
| 9 | no new top-level MD ad-hoc | `ls *.md` at root — only the 8 sanctioned docs? (the audit phase added none — it used `docs/plans/`) | ✎ confirm |
| 10 | no hard-coded magic numbers a user would override | grep thresholds in `skills/`, `chapters/`, `global/commands/`; triage vs the profile's surfaced `## Spine defaults` set | ↻ audit-03 A2.5 |
| 11 | sweep count claims on change | Re-verify 23 / 84 / 10 across README/EXPLAINER/install.sh/19b/op-welcome/op-onboard/landing **as of now** (the `/explain` 9→10 ripple) | ↻ audit-04 + audit-01 F5/F6 |
| 12 | model IDs in `docs/MODELS.md` only | grep `chapters/` for `claude-opus-`/`claude-sonnet-`/`claude-haiku-` literals — should be zero outside `MODELS.md` | ✎ |

## Section-level open questions

- **Session shape.** Proposed: **one session** with a documented clean split, matching audits 01–04. Natural split if the entry/file balloons: Session 1 = the 12-rule scorecard + PF1–PF5 + magic-number grep + claim-#1 + FIXES/CHANGELOG shape (the checklist-shaped, closed-end work); Session 2 (only if needed) = the exhaustive 18a–18h per-chapter dogfooding writeup (the open-ended part). Close Session 1 at a clean break if the file nears 300 lines or the entry nears 100.
- **`A16` vs fold.** PF2–PF5 are discrete, action-shaped infra fixes → a new `A16` cluster (keeps them out of A13's doc-drift class). Pure consolidations (rules 4/6/10/11) get **no** new FIXES entries — they cite A13/A15/A2.5. The claim-#1 finding **extends A1**, not a new entry.
- **Does "read-only" cover `global/`?** Resolved at `/prep`: **yes.** PF2/PF4/PF5 target `global/hooks`, `global/commands`, `global/settings.json`; PF3 targets `skills/core/`. All read-only this phase — findings are text, fixes are apply-time. The banner names `global/` explicitly because this is the first audit whose findings target it.

---

## Session 1 — Self-discipline sweep

**Status**: `pending`

**Goal**: Produce a triaged Findings artifact that — for the 12 anti-drift rules (scorecard, pass/fail/partial + `file:line`), the 8 anti-pattern chapters (does-the-spine-commit-it verdict), and PF1–PF5 (confirmed extent + fix locus) — records where "discipline taught" diverges from "discipline lived," **consolidating** audits 01–04's rule-relevant findings rather than re-discovering them. Plus the claim-#1 framing check and a magic-number triage. No code/chapter/global edits — findings are text; fixes are apply-time.

**Files to read** (orient list — exact cold-start budget): the 12-item list under "Files to read for project understanding" above. The `18a–18h` chapters and the PF-target files (`spine-writeback.sh`, `op-spine-active`, `done.md`, `settings.json`) are opened on-demand during steps 1–4.

**Files to write/edit** (scope — anything else is out of bounds without an explicit pause):

- This section file — § Findings (scorecard + dogfooding table + PF confirmations), § Session log, § "Cross-section notes (this section's own)".
- `FIXES.md` — open `A16` (PF2–PF5 infra bugs + any blocking rule violation); **extend A1** if the claim-#1 reframe surface is incomplete; cite (do **not** duplicate) A13/A15/A2.5 for consolidated rows.
- `docs/PROGRESS.md` — advance pointer to `audit-06-tests-docs` at `/done`.

**Strictly out of scope:** any `chapters/`, `skills/core/`, `global/` (hooks/settings/commands), code, or template edit — even the PF2–PF5 targets. Proposed fixes are Findings-table text.

**Build steps**:

1. **Confirm + escalate PF1–PF5.** For each: open the cited locus, confirm the issue persists, gauge extent, propose the fix locus. PF1 (`info`) — verify the `op-approach`/05k integration (trigger specificity; does it add a *3rd* planning-cluster collision beyond audit-04 F1's op-workflow↔op-prepare; does `procedure.md` need a "call op-approach first" step; does `18g` warrant a sibling entry). PF2 — `spine-writeback.sh` ~L247 `CHANGED=` reads `git status --porcelain` (whole dirty tree); this session's own heartbeats are live evidence (incl. the 15:33 mis-file + self-referential capture). PF3 — `op-spine-active` Step 2 has no "pending + sketch" case. PF4 — `done.md` Step 2.1 doesn't sweep the section file's per-session Status (`section-0…md:53` still `in-progress`). PF5 — `settings.json` `Read(**/*token*)` over-matches (audit-02: Read **and** Bash both blocked → deadlock when the file exists). Escalate PF2–PF5 to `A16`.
2. **Score the 12 anti-drift rules** per the Rule-check map above. One scorecard row per rule: verdict (pass/fail/partial) + `file:line` evidence. For ↻ rows, **cite** the prior audit's finding — do not re-open. Apply PF1 methodology: confirm each verdict against disk before recording it.
3. **Dogfood anti-pattern chapters 18a–18h.** For each chapter, name the anti-pattern it teaches and check whether the spine commits it (`file:line` or "clean"). Dedup against step 2 where they overlap (18g workflow ≈ rule 1 FIXES discipline; 13d skill-anti-patterns ≈ rule 6) — cite the rule row, don't double-count.
4. **Claim-#1 framing + magic-number grep.** (a) Does `CLAUDE.md` L34 / `EXPLAINER` / `README` carry the "saves tokens / fewer tokens than vanilla" framing that LC1 (+75.9%) contradicts? Does `FIXES.md` A1's reframe-surface list name every such surface? Record the gap → extend A1. (b) grep `skills/`, `chapters/`, `global/commands/` for threshold literals (`30`, `7200`, `90`, `6`, `5`, `100`, `300`, `3`); triage each override-worthy (→ profile field) vs intrinsic against the profile's `## Spine defaults`. Consolidate A2.5.
5. **FIXES (rule 1) + CHANGELOG (rule 2) shape pass.** The detailed read behind step 2's R1/R2 verdicts: is every FIXES entry discrete + triageable, or has narrative crept in? Is CHANGELOG slim-bullet Keep-a-Changelog?
6. **Triage + cross-section notes.** Append the Findings tables; open `A16` (PF2–PF5 + any blocking rule violation); extend A1 if warranted; populate this section's Cross-section notes (audit-06 self-lint + archive-freshness; apply-phase ordering). Verify read-only via `git diff` against the session-start commit (heartbeat caveat: `touched:` ≠ mutation).

**Verify**:

- Scorecard covers all **12** rules — each with a verdict + `file:line`; ↻ rows cite the prior audit (not re-derived), ✎ rows show fresh evidence.
- All **8** anti-pattern chapters (18a–18h) scanned — each with a "spine commits? Y/N + evidence" verdict; overlaps with the rule walk are deduped by citation, not double-counted.
- PF1–PF5 each resolved: confirmed (extent + fix locus) or downgraded with reason; PF2–PF5 in `A16`.
- Magic-number grep run; every hit triaged. Claim-#1 framing gap recorded + A1 extended (or "A1 surface already complete").
- **Consolidation honored:** no rule-relevant finding from audits 01–04 re-opened — each appears as a citation. (This is the cross-section-coherence discipline the audit itself checks for.)
- `FIXES.md` is queue-shaped after the session; CHANGELOG spot-check recorded.
- **No `chapters/`/`skills/core/`/`global/`/code/template edits** — verified via `git diff` against the session-start commit at `/done` (heartbeat `touched:` includes the whole dirty tree, incl. staged prior closes + `/explain` residue — not proof of audit mutation).

**Output**:

- Commit message hint: `docs(audit): section 5 — self-discipline sweep findings`
- Update at `/done`: this section file (Findings filled, status `done`), `docs/PROGRESS.md` (pointer → `audit-06-tests-docs`, refresh reading list), `FIXES.md` (`A16` cluster + any A1 extension).

---

## Findings

_(populated when Session 1 runs — PF1–PF5 confirmations + the 12-rule scorecard + the 18a–18h dogfooding table. Per the spine's token-discipline, verdicts record `file:line` evidence pointers, not recopied rule text.)_

## Session log

_(per-turn heartbeats appended automatically by `spine-writeback.sh` Stop hook — `touched:` reflects the whole dirty working tree, not per-session deltas; verify real mutations via `git diff` at `/done`. This is PF2, live.)_

- session 1 @ 2026-05-29 15:28 — touched: FIXES.md docs/PROJECT_PLAN.md benchmarks/sessions/
- session 1 @ 2026-05-29 15:33 — touched: benchmarks/sessions/
- `/prep` pass (2026-05-29): stub (PF1–PF5 pre-flagged + a 6-step sketch) elaborated into a fully-detailed Session 1 entry. Scope = the 12 anti-drift rules (scorecard) + 18a–18h dogfooding + PF1–PF5 confirmation + magic-number grep + claim-#1 framing check. **Consolidation mandate** set: cite audits 01–04's rule-relevant findings (A13 rule 4; A15/audit-01 rule 6; A2.5 rule 10; audit-04/audit-01 rule 11), do not re-discover. Read-only widened to include `global/` (PF2–PF5 target it). `A16` reserved for the four audit-infra bugs; the claim-#1 finding extends A1. Cross-section notes carried forward from all four prior audits (PF1 methodology + A1 reframe load-bearing). Single-session shape with documented split. Writes confined to this file (+ a PROGRESS pointer refresh). Pre-flight rule 1 satisfied for audit-05.

## Pending cross-session notes

_Auto-captured by `spine-writeback.sh` from cue phrases in assistant turns. `/done` reviews this list and either promotes entries to **Cross-section notes** above or discards them. Hook is append-only; never edits this block once written._

- (turn @ 2026-05-29 15:28) No `## Pending cross-session notes` block (Stop hook captured none). Cross-section notes for audit-05/06 + A1 written.
- (turn @ 2026-05-29 15:33) (turn @ 15:28) No `## Pending cross-session notes` block (Stop hook captured none)...           ← self-referential junk
- (turn @ 2026-05-29 15:45) **Live PF2 evidence.** While running this `/prep`, the Stop hook mis-filed a heartbeat under "Pending cross-session notes" and captured its *own* prior note (self-referential). I folded both into PF2's extent — good dogfooding, but it means this session's own trail is noisy.
