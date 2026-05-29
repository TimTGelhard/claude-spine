# Section: audit-06-tests-docs

> Section 6 of the audit pass — **the last audit.** See `docs/PROJECT_PLAN.md` for the master plan.
> **Audit phase: WRITE FINDINGS ONLY.** No edits to `chapters/`, `skills/core/`, `global/`, `tests/`, code, or templates — even the broken cross-refs and missing tests this section finds. Findings are text; writing tests + repairing refs is the apply phase.
> **🔒 No apply session runs until all six audit sections are `done`. This is the sixth.** When this section closes, the all-six-before-apply gate lifts and the apply phase unlocks. See `docs/PROJECT_PLAN.md` § Constraints.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — the four conditions. This section's `/prep` pass (2026-05-29) satisfies condition 1.
> Depends on Section 1 (counts / INDEX) + Section 5 (discipline) — so this section audits coverage + freshness rather than re-deriving baselines, and **consolidates** the cross-audit "no self-lint" thread rather than re-discovering it.

## Section goal

Audit **test coverage + documentation freshness** — the two surfaces the prior five audits deferred here. Three mechanical sweeps + one synthesis:

1. **Test coverage** — map every `tests/run.sh` suite to the feature(s) it guards; list untested code paths (hooks without tests, `install.sh` branches, `/onboard` variants) with a rough close-effort estimate.
2. **Cross-reference validity** — verify links + anchor citations resolve across `INDEX.md`, `README.md`, `EXPLAINER.md`, `RECONSTRUCTION.md`, `CHANGELOG.md`, and `chapters/` (audit-01 F8 methodology: broken `## heading` anchors, not just bare file paths).
3. **Archive + freshness** — `docs/archive/` preambles point at live successors (rule 5); `docs/evaluation/` + the `docs/plans/audit-0*` files' archive status; the live model-version rot (`MODELS.md` + `04a` list Opus 4.7, running model is 4.8); `landing/index.html` structural / link freshness (counts already swept by audits 01 / 05).

**The headline candidate — the capstone of the whole six-audit pass.** Three audits independently hit the same root cause: **the spine has no automated self-linting, so drift accumulates silently between manual audits** — audit-03 (no field→consumer coverage test), audit-04 (no overlap-regression check), audit-05 (no rule-lint). Each proposed its own verify command: A12 `/profile verify`, audit-04 `/trigger verify`, audit-05 `/discipline verify`. Audit-06's synthesis: are these one `/verify` family, and is "no self-lint" itself the meta-gap the entire audit pass kept rediscovering? This is the finding that ties the pass together — **confirm + frame it, don't re-derive the three inputs.**

## Done criteria

- [ ] Each `tests/run.sh` fast suite mapped to the feature(s) it guards; the API-cost `tests/skill-triggers/` suite noted separately.
- [ ] Untested code paths listed with a close-effort estimate (hooks lacking tests — the notification hook appears untested; `install.sh` branches; `/onboard` essentials / `--deep` / subscription-tune / hook-tune variants — only `extras-merge` is tested).
- [ ] Test-count claims verified against disk: `CLAUDE.md` Stack says "~57 cases across 6 sub-suites"; "Before claiming done" says "6 suites, ~65 cases"; `run.sh` lists **7** fast suites. Drift flagged (a count surface audit-05's rule-11 sweep — 23 / 84 / 10 — did not cover).
- [ ] Cross-references in `INDEX` / `README` / `EXPLAINER` / `RECONSTRUCTION` / `CHANGELOG` verified live (no dead file refs); chapter anchor-citations swept for broken `## heading` refs **beyond** the 2 known (A13 items 4 + 5 — cite, do not re-log); new instances listed.
- [ ] `docs/archive/` (11 files) each carry a live-successor preamble (rule 5); `docs/evaluation/` (REPORT + STRESS-TEST) + the `docs/plans/audit-0*` plans' archive status decided / flagged; model-version rot cited (consolidate audit-05, don't re-measure).
- [ ] `landing/index.html` structural / link freshness swept; "CHANGELOG `Fixed` claims match disk" spot-check run (audit-05 found the `04a` "replaced with pointers" overclaim — confirm there are no others).
- [ ] **Verify-command synthesis:** A12 + `/trigger verify` + `/discipline verify` consolidated into one recommendation; "no self-lint = the cross-audit meta-gap" framed as the capstone finding.
- [ ] Findings appended; blocking → `FIXES.md` (`A17` / extend A12); read-only verified via `git diff` against the session-start commit; **all-six-before-apply gate status recorded** (lifts at `/done`).

## Out of scope (do not drift here)

- **Writing tests / repairing refs / archiving files.** Apply phase, after all six audits are `done`. Findings are text.
- **Re-running the trigger benchmark.** audit-04 recommended NO-SPEND (only 3 / 18 descriptions changed since 2026-05-27); a meaningful re-run needs eval-sets for the 5 uncovered skills + a harness confound fix. audit-06 *records the harness-methodology + eval-set recommendation* — it does not run the benchmark unless separately cost-authorized at execution time.
- **Re-discovering prior audits' findings.** The 2 known broken refs (A13), the count sweep (23 / 84 / 10 = audit-05 rule 11, complete incl. the `/explain` 9→10 ripple), the model-ID duplication (A16.5), the verify-command *inputs* (A12 / `/trigger` / `/discipline`) are all escalated. **Cite + consolidate; do not re-open.**
- **Architecture / token-cost / personalization / skill-trigger / self-discipline audits** (Sections 1–5, all done). audit-06 *uses* their baselines, doesn't re-derive them.

If a finding belongs to the apply phase, capture it in "Cross-section notes" below and move on. Do not bundle.

## Files to read for project understanding (cold-start orientation)

Read in this order at session start. Stop after this list — pull individual chapter files, `landing/index.html`, `install.sh`, and the model-tier files on-demand during the build steps, not as orientation budget.

1. `docs/PROJECT_PLAN.md` — § Constraints (the all-six-before-apply gate — **audit-06 is the sixth**) + § Audit-phase pre-flight protocol (the four conditions; heartbeat caveat = PF2 / A16.1).
2. This file's **"Cross-section notes carried forward from audits 01–05"** block (below) — the consolidated hand-off; the load-bearing inputs for the synthesis + the cross-ref methodology.
3. `tests/run.sh` (the 7 fast suites) + `ls tests/*/` + `tests/skill-triggers/README.md` (+ `eval-sets/` listing) — the coverage surface.
4. `INDEX.md` — the cross-ref + the known rule-4 `11g` gap (audit-01 F4 → A13); on-demand the top-level docs (`README` / `EXPLAINER` / `RECONSTRUCTION` / `CHANGELOG`) for the ref sweep.
5. `FIXES.md` — A12 (`/profile verify`), A15 (`/trigger verify` is in audit-04's notes), A16 (`/discipline verify` is in audit-05's notes), A13 (the 2 known broken refs — cite, don't re-log), + the next free cluster number (**A17**).
6. `docs/archive/` + `docs/evaluation/` (`ls` only) — the archive-freshness surface.
7. `CLAUDE.md` — rule 5 (archive discipline) + the two divergent test-count claims (Stack section + "Before claiming done").
8. This file.

## Sweep map (reference for build steps 1–4)

✎ = audit-06 owns fresh · ↻ = consolidate a prior audit (cite, don't re-open).

| Surface | Check | Source |
|---|---|---|
| `tests/run.sh` suites | Each fast suite → feature it guards; `skill-triggers/` noted as API-cost / manual | ✎ |
| Untested paths | 6 hooks vs 5 tested (notification?); `install.sh` branches; `/onboard` variants | ✎ |
| Test-count claims | `CLAUDE.md` "~57 / 6 sub-suites" vs "6 suites / ~65" vs run.sh's 7 — reconcile | ✎ |
| Test-script hygiene | Any `grep --include=*.md` (or other) silent-no-op-under-zsh patterns | ↻ audit-03 |
| Doc file-refs | `[..](path)` + `path:line` in INDEX/README/EXPLAINER/RECONSTRUCTION/CHANGELOG resolve | ✎ |
| Chapter anchor-cites | Broken `## heading` citations beyond A13 items 4 + 5 | ↻ audit-01 F8 (method) |
| `docs/archive/` | Each file has a live-successor preamble (rule 5) | ✎ |
| `docs/evaluation/` + audit-0* | Archive status; STRESS-TEST.md lacks a date suffix; audit-0* at phase-close | ↻ audit-05 |
| Model-version rot | `MODELS.md` + `04a` list 4.7; running 4.8 | ↻ audit-05 / A16.5 |
| `landing/index.html` | Structural / link freshness (counts already 01 / 05) | ✎ |
| CHANGELOG `Fixed` ↔ disk | Each `Fixed` claim true on disk (04a overclaim caught; others?) | ↻ audit-05 |
| Verify-command family | A12 + `/trigger` + `/discipline` → one recommendation + meta-gap frame | ↻ 03 / 04 / 05 |

## Cross-section notes carried forward from audits 01–05

Per pre-flight protocol rule 4 (cross-section notes propagate manually). These are the audit-06-relevant findings the prior audits handed forward — each becomes a *cited* input, not a re-discovery:

- **[LOAD-BEARING] PF1 methodology (audit-01).** Grep-verify every claim against disk before recording it. The cross-ref sweep especially: confirm each "broken" ref by opening the target, and each "untested path" by reading `run.sh`. PF1 caught Claude's own fabrications (invented citations, wrong field names, zsh-no-op greps) in audits 02 / 03 — same risk in a link-heavy sweep.
- **[LOAD-BEARING] The mechanize-the-discipline thread (audit-03 + 04 + 05).** Three audits, one root cause: **no automated self-lint → silent inter-audit drift.** Inputs already written: A12 `/profile verify` (audit-03 demonstrated its value — it would auto-flag the 4 decorative fields); audit-04's `/trigger verify` (every description scores ≥X on 13b + no two share a trigger phrase without a documented boundary); audit-05's `/discipline verify` (lint the 12 rules: count consistency, FIXES queue-shape, no model-IDs outside `MODELS.md`, an INDEX row per chapter). **audit-06's synthesis = decide one `/verify` family vs three commands + frame "no self-lint" as the meta-gap.** Do NOT re-derive the three inputs.
- **Cross-ref methodology (audit-01 F8).** Sweep for broken *anchor* citations (`## heading` refs) across `chapters/`, not just bare file paths. Two known instances live in A13 (item 4: `14b-hook-recipes.md:55` cites a non-existent `## Hook tuning` heading in `op-onboard/SKILL.md`; item 5: `questions-deep.md:308-317`) — **cite, do not re-log**; hunt for NEW instances of the same class.
- **Benchmark harness (audit-02 F5 + audit-04).** The `claude -p` single-shot router-firing confound makes TP unmeasurable for routing skills (FP is the only reliable signal; the 0–20% TP is an artifact); a meaningful re-run needs (i) eval-sets for the **5 uncovered skills** (`op-approach`, `op-curate-nudge`, `op-prepare`, `op-spine-active`, `op-welcome` — `eval-sets/` holds 18 JSON), and (ii) a multi-turn / interactive-simulation methodology fix. Plus the `claude --version` + binary-mtime preflight (A1 path — a mid-run CLI upgrade wiped audit-02's spine-on phase). **audit-06 owns recording the harness-methodology fix + eval-set-authoring recommendation** (it does not implement them — apply phase).
- **Test-gap (audit-03).** No field→consumer coverage test exists today — confirmed; the 4 decorative fields accumulated silently *because* nothing asserts `19g` truth (A12 is the missing test). Also: audit-03's own `grep --include=*.md` invocations silently no-op'd under zsh (glob expansion) — **check `tests/` for the same silent-pass pattern** (a test that matches nothing and "passes").
- **Count-claim (audit-04 + 05).** The `/explain` 9→10 slash-command sweep is **complete** (audit-05 rule 11 verified across README / EXPLAINER / install.sh / 19b / op-welcome / op-onboard / landing) — cite, don't re-do. But the **test-case / sub-suite count** (`CLAUDE.md`'s "~57 / 6 sub-suites" vs "6 suites / ~65" vs run.sh's 7) is a NEW count surface rule-11 didn't touch — audit-06 owns it.
- **Archive + freshness (audit-05).** `docs/evaluation/{REPORT-2026-05-28.md, STRESS-TEST.md}` live *outside* `docs/archive/` (REPORT is live-referenced by open A1–A12 → defensible until they close; STRESS-TEST.md lacks a date suffix → flag). Open question handed forward: when the audit phase closes, should `docs/plans/audit-0*` move to `docs/archive/`? (point-in-time records living as plan files — decide / flag, don't move). The "CHANGELOG `Fixed` claims match disk" check would have caught the `04a` overclaim — concrete addition to the `/discipline verify` idea. Model-version rot (`MODELS.md` + `04a` → Opus 4.7 while running 4.8) is the live docs-freshness instance (= A16.5's freshness half).

## Cross-section notes (this section's own — populated as Session 1 runs)

- **For the apply phase (the gate lifts when this section closes).** Likely the largest apply candidates: **A17 = the verify-command family** (the cross-audit capstone) + **A16.1 / PF2** (the heartbeat whole-tree bug audit-05 named as *the* early-apply candidate — it pollutes every audit-trail heartbeat, including this file's own). When audit-06 is `done`, `docs/PROJECT_PLAN.md` § Constraints' all-six gate lifts; apply sections are then ordered by `FIXES.md` severity, not by which audit produced the finding.
- _(further notes added as Session 1 runs)_

## Section-level open questions

- **Session shape.** Proposed: **one session with a documented clean split**, matching audits 01–05. Natural split if the entry / file balloons: Session 1 = the 3 mechanical sweeps + the count / freshness residuals (closed-end, checklist-shaped); **Session 2 (only if needed) = the verify-command synthesis + the "no self-lint" capstone frame** (the open-ended, judgment-heavy part). Close Session 1 at a clean break if the file nears 300 lines or the entry nears 100.
- **`A17` vs extend.** Blocking test-coverage / broken-ref findings → a new `A17` cluster (keeps them out of A13's doc-drift class). The verify-command synthesis → **extend A12** (its canonical home) and *cite* `/trigger` (audit-04 / A15-adjacent) + `/discipline` (audit-05 / A16-adjacent) into the consolidated recommendation — don't open three parallel entries. Pure consolidations (model-rot = A16.5, 2 known broken refs = A13) get **no** new entry.
- **Does "read-only" cover `tests/`?** **Yes.** audit-06 reads the test suite and finds gaps, but *writing* tests is the apply phase (stub Out-of-scope confirms). `tests/` joins `chapters/` / `skills/core/` / `global/` / code / templates on the read-only list this phase.

---

## Session 1 — Test + docs freshness sweep + verify-command synthesis

**Status**: `pending`

**Goal**: Produce a triaged Findings artifact covering (a) the test-coverage map + untested paths + count reconciliation, (b) the cross-reference + anchor-citation sweep, (c) the archive / freshness sweep, and (d) the verify-command synthesis that frames "no automated self-lint" as the capstone meta-gap of the whole six-audit pass — **consolidating** audits 01–05's audit-06-bound notes rather than re-discovering them. No code / chapter / global / test edits — findings are text; the fixes are apply-time.

**Files to read** (orient list — exact cold-start budget): the 8-item list under "Files to read for project understanding" above. `landing/index.html`, `install.sh`, individual chapter + the model-tier files (`MODELS.md` / `04a`) are opened on-demand during steps 1–4.

**Files to write/edit** (scope — anything else is out of bounds without an explicit pause):

- This section file — § Findings (coverage map + sweep tables + the synthesis writeup), § Session log, § "Cross-section notes (this section's own)".
- `FIXES.md` — open `A17` (test-coverage gaps + the verify-command consolidation, or extend A12 for the latter); cite (do **not** duplicate) A12 / A13 / A15 / A16 / A16.5 for consolidated rows.
- `docs/PROGRESS.md` — at `/done`: record the audit phase complete + the gate lifting; point at the apply phase (`/prep` of the first apply section).

**Strictly out of scope:** any `chapters/`, `skills/core/`, `global/`, `tests/`, code, or template edit — even writing the missing tests or fixing the broken refs this session finds. Proposed fixes are Findings-table text.

**Build steps**:

1. **Test-coverage map + untested paths + count reconcile.** Read `run.sh` (7 fast suites) + `ls tests/*/` + `skill-triggers/README.md`. Table each suite → feature guarded; note `skill-triggers/` as API-cost / manual. List untested paths (the 6th hook — notification — vs 5 tested; `install.sh` branches; `/onboard` variants) + rough close-effort. Reconcile the test-count claims (`CLAUDE.md` "~57 / 6 sub-suites" vs "6 suites / ~65" vs the actual 7) — flag the drift. Grep `tests/` for `--include=*.md` (or other) silent-no-op glob patterns (audit-03 caveat).
2. **Cross-reference + anchor sweep.** (a) Extract `[..](path)` + `path:line` refs from INDEX / README / EXPLAINER / RECONSTRUCTION / CHANGELOG; confirm each target exists (PF1: open it). (b) Sweep `chapters/` for broken `## heading` anchor citations (audit-01 F8 method) — **beyond** A13 items 4 + 5 (cite those, hunt for new). List new broken refs.
3. **Archive + freshness sweep.** `docs/archive/` (11 files): each has a live-successor preamble (rule 5)? `docs/evaluation/`: REPORT (defensible — live-referenced) + STRESS-TEST.md (no date suffix — flag). `docs/plans/audit-0*`: decide / flag the at-phase-close archive question (don't move). Cite the model-version rot (`MODELS.md` + `04a` → 4.7 vs running 4.8; A16.5 freshness half) — don't re-measure. `landing/index.html`: structural / link freshness only. CHANGELOG `Fixed` ↔ disk spot-check.
4. **Verify-command synthesis (the capstone — or split to Session 2).** Read A12 + audit-04's `/trigger verify` note + audit-05's `/discipline verify` note. Decide: one `/verify` family vs three commands; what each lints; the overlap. Frame "no automated self-lint → silent inter-audit drift" as the meta-gap *this whole pass kept rediscovering* (audit-03 / 04 / 05 each hit it independently). **If the file / entry is ballooning, STOP here — mark Session 1 done at step 3, open Session 2 for this step.**
5. **Triage + cross-section notes + gate.** Append the Findings tables; open `A17` (coverage gaps + the verify-command recommendation) / extend A12; cite A13 / A15 / A16 / A16.5. Populate this section's Cross-section notes (apply-phase ordering: A17 + PF2). Verify read-only via `git diff` against the session-start commit (heartbeat caveat: `touched:` ≠ mutation). **Record that the all-six-before-apply gate lifts** — audit-06 is the sixth.

**Verify**:

- Every `tests/run.sh` suite mapped; untested paths listed with close-effort; the test-count drift reconciled against disk.
- Cross-ref sweep run across the 5 top-level docs + `chapters/` anchors; new broken refs listed (the 2 known A13 ones cited, not re-logged).
- `docs/archive/` preambles checked; `docs/evaluation/` + audit-0* archive status decided / flagged; model-rot + CHANGELOG-`Fixed` spot-checks recorded.
- Verify-command synthesis produces ONE recommendation (family vs three) + the "no self-lint" meta-gap framed — **or** Session 1 is cleanly split at step 3 with Session 2 detailed for the synthesis.
- **Consolidation honored:** no prior-audit finding re-opened — each appears as a citation (the cross-section-coherence discipline the audit pass enforces).
- `FIXES.md` updated (`A17` / A12 extension); read-only verified via `git diff` against the session-start commit at `/done`.
- **All-six gate status recorded** — the apply phase unlocks when this section is `done`.

**Output**:

- Commit message hint: `docs(audit): close section 6 — tests + docs sweep + verify-command synthesis (audit phase complete)`
- Update at `/done`: this section file (Findings filled, status `done`), `docs/PROGRESS.md` (audit phase complete; gate lifted; point at the first apply section's `/prep`), `FIXES.md` (`A17` + A12 extension).

---

## Session 2 — Verify-command synthesis + capstone (only if Session 1 splits)

**Status**: `pending` (sketch — detail at its start only if Session 1 splits at step 3)

Sketch: consolidate A12 `/profile verify` + audit-04 `/trigger verify` + audit-05 `/discipline verify` into one recommendation (a single `/verify` family vs three commands; what each lints; the shared engine). Frame "no automated self-lint → silent inter-audit drift" as the meta-gap the whole six-audit pass kept rediscovering. Decide whether `CHANGELOG` / `FIXES` doc-shape warrants a test fixture (audit-05 open question). Write the final apply-phase handoff (the all-six gate lifts; A17 + PF2 are the lead apply candidates).

## Findings

_(populated when Session 1 runs)_

## Session log

_(per-turn heartbeats appended automatically by `spine-writeback.sh` Stop hook — `touched:` reflects the whole dirty working tree, not per-session deltas (PF2 / A16.1); verify real mutations via `git diff` at `/done`.)_

- `/prep` pass (2026-05-29): stub elaborated into a fully-detailed Session 1 entry (3 mechanical sweeps + the verify-command synthesis capstone). **Consolidation mandate** set: cite audits 01–05's audit-06-bound notes (A12 / `/trigger` / `/discipline` synthesis inputs; A13 2 known broken refs; A16.5 model-rot; the complete 23/84/10 count sweep) — do not re-discover. Read-only widened to include `tests/`. `A17` reserved for coverage gaps + the verify-command recommendation; the synthesis extends A12. Cross-section notes carried forward from **all five** prior audits. Single-session shape with a documented split (Session 2 = the synthesis, only if Session 1 balloons). **Cleared a stray 16:22 PF2 heartbeat** (`touched: FIXES.md PROJECT_PLAN.md benchmarks/sessions/` — whole-tree dirt logged under audit-06 before it ran; live PF2/A16.1 evidence, removed from the stub so the cold-start isn't misled). Pre-flight rule 1 satisfied for audit-06.
- session 1 @ 2026-05-29 18:07 — touched: benchmarks/sessions/
