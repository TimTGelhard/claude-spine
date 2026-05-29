# Section: apply-02-skill-triggers

> Second apply section. Clears `FIXES.md` **A15** — the skill-trigger accuracy cluster (1 blocking + 8 drift).
> Plan-driven; 2 sessions. Drafted 2026-05-29 via `/prep` (next cluster by severity after apply-01 closed A1).
> **Source of the apply-ready clauses:** `docs/plans/audit-04-skill-triggers.md` § Findings (F1–F9) — exact `description:`
> revisions live there; FIXES A15 summarizes. **Skills/core edits are sanctioned here** — A15 is an audit-routed
> cluster (not a single user complaint), and the apply phase is edit-allowed against `skills/core/` per
> `docs/PROJECT_PLAN.md` § Phase 2. The "stable surface" rule in `CLAUDE.md` does not block this.

## Section goal

Make load-bearing **claim #1's surviving lever — routing accuracy — true on disk.** apply-01 reframed claim #1 from
"saves tokens" (LC1-refuted) to "bounded per-load cost + routing accuracy"; audit-04 then measured the routing surface
(the 23 `op-*` `description:` fields, the only text Claude sees when choosing a skill) and found **7 harmful overlaps**
— pairs that fire on the same user phrase with no phrase-visible boundary — including one **blocking misroute**
(`op-workflow` ↔ `op-prepare`: a user wanting to *plan* a multi-session build can land in op-workflow's concept
chapters instead of op-prepare's planning pass). This section applies audit-04's apply-ready disambiguation clauses to
the affected `description:` fields, fixing every harmful overlap (Session 1) plus the two description-shape drift items
(Session 2), then compresses + resolves A15. It does **not** run the API routing benchmark — that re-run is deferred to
audit-06's harness fix (see Cross-session notes); the overlap matrix is the design-time routing proxy.

## Done criteria

A non-developer could check these:

- [ ] **Blocking A15.1 fixed:** `op-workflow`'s `description:` distinguishes its conceptual-7-stage role from `op-prepare`'s plan-authoring role (the audit-04 F1 clause), and op-workflow's existing **`## Sibling skills`** section (currently op-collaboration-modes + op-brownfield) gains an `op-prepare` (multi-session plan authoring) bullet. _(Disk-checked at prep: the Sibling-skills section is at SKILL.md L47–50 — audit-04 F1's "48–50" citation is accurate; op-prepare already lists op-workflow back per audit-04, so the cross-link becomes bidirectional.)_
- [ ] **All 7 harmful-overlap pairs from the audit-04 matrix now carry a phrase-visible boundary** — the F1/F2/F3/F5/F6/F8/F9 clauses are present in the named `description:` field(s): op-workflow, op-hooks, op-anti-patterns+op-signaling (cross-ref each), op-bucket-router, op-add-skill, op-foundations, op-collaboration-modes.
- [ ] **The 2 drift fixes landed:** op-curate-nudge's description carries the "when the bucket loop is enabled" gate (F4); op-curate's description is trimmed of body-procedure sentences, keeping trigger + bucket-only scope refusal (F7).
- [ ] **No new harmful overlap introduced** — each edited description re-checked against the audit-04 overlap matrix; no fresh same-phrase collision left without a boundary (e.g. op-workflow's new op-prepare clause must not collide with op-approach).
- [ ] `tests/run.sh` green (7 suites) — frontmatter/structural integrity intact after the edits (run.sh does not test routing; it catches a broken YAML header).
- [ ] **The API routing benchmark was NOT run** (deferred — see Cross-session notes); a one-line "re-run now warranted, blocked on audit-06 `claude -p` confound fix" note is recorded in FIXES + this file.
- [ ] `FIXES.md` A15 compressed to an action-shaped **✅ RESOLVED** entry + pointer to audit-04 Findings (CLAUDE.md rule 1); `CHANGELOG.md` `[Unreleased]` gains one slim `Changed` bullet.

## Cross-session notes

Discoveries from the `/prep` pass (2026-05-29) that both sessions must honor — and Session-1 results Session 2 cites.

- **Disk check (prep) — op-workflow's F1 fix, exact shape.** `skills/core/op-workflow/SKILL.md` has a **`## Sibling skills`** section at **L47–50** (currently `op-collaboration-modes` + `op-brownfield`; omits op-prepare) and a `## Common triggers` section at L36–45 — it does **not** have a "When NOT to use" section. So F1 = (a) append the F1 disambiguation clause to the frontmatter `description:` (L3) **and** (b) add an `op-prepare` (multi-session plan authoring) bullet to that `## Sibling skills` section. audit-04 F1's "SKILL.md:48–50 omits it" citation is **accurate**; op-prepare already lists op-workflow as a sibling (per audit-04), so this makes the cross-link bidirectional. Match the file's existing shape — don't invent a heading.
- **`tests/run.sh` does NOT exercise routing.** Grep-confirmed at prep: `skill-trigger` does not appear in `tests/run.sh`, and no file under `tests/` greps `description:` text. The skill-trigger eval lives in `tests/skill-triggers/run-eval.sh` (API-cost-gated, separate). So a description edit cannot break `tests/run.sh` via a text assertion — but still run it (it parses SKILL.md frontmatter; it will catch a corrupted YAML header).
- **The API routing benchmark is DEFERRED — do NOT run `tests/skill-triggers/run-eval.sh` in this section.** audit-04's recommendation: a re-run becomes *worthwhile* once A15 lands (it changes ~10 descriptions), **but only after audit-06 fixes the `claude -p` routing-skill confound** — running it now reproduces the known 0–20% TP artifact (FP is the only reliable signal today). This section fixes routing "blind," using the audit-04 **overlap matrix as the design-time proxy**; empirical confirmation rides a later authorized re-run. State this caveat honestly at close — don't claim routing is "verified."
- **eval-set sanity check (no API spend):** `tests/skill-triggers/eval-sets/` holds eval-sets for a subset of skills. For any edited skill that *has* one, read it and confirm the disambiguation **sharpens toward** (does not flip) the already-expected target — the expected answers should not change. (audit-04: only 3/18 benchmarked descriptions had changed since 2026-05-27; the eval-sets expect the *correct* skill already.)
- **Session 1 → Session 2 handoff (filled at S1 `/done`, 2026-05-30):**
  - **8 files edited** (all `skills/core/*/SKILL.md` `description:` only; op-workflow also got one `## Sibling skills` bullet): `op-workflow` (F1 blocking), `op-hooks` (F2), `op-anti-patterns` + `op-signaling` (F3, both sides), `op-bucket-router` (F5), `op-add-skill` (F6), `op-foundations` (F8), `op-collaboration-modes` (F9). `git diff --stat`: 9 insertions / 8 deletions; **no body, no `chapters/`, no `tests/`** edits.
  - **Clause adapted beyond audit-04 verbatim — F3 went bidirectional.** audit-04's F3 proposed-revision text gave only the op-anti-patterns side; this section's Files-to-edit list calls for *both* descriptions to cross-ref, so the layering is documented symmetrically (op-anti-patterns → "cadence is op-signaling 11e"; op-signaling → "catalog is op-anti-patterns 18-meta"; both end "both intentionally fire"). Every other clause is audit-04's text, adapted only for grammatical fit into the live sentence.
  - **Overlap-matrix re-check (build step 3) — clean.** No edited description creates a fresh same-phrase / no-boundary collision. Confirmed specifically: op-workflow's new op-prepare clause does **not** collide with op-approach (op-approach fires on work-*shape* "audit/refactor/migrate" *before* op-prepare; op-workflow's clause names only the plan-authoring *pass*). op-hooks' F2 still contains "from now on, when X, do Y" but now as an explicit pointer to op-persistence — phrase-visible boundary, not a re-collision.
  - **Eval-set sanity check (no API spend) — 7/8 sharpen, 1 flip for S2 to record.** `tests/skill-triggers/eval-sets/op-hooks.json` **line 4** ("…should this be a hook, a CLAUDE.md instruction, or a skill? What's the right home?" → `should_trigger: true` for op-hooks) encodes the **pre-F2** overlap; F2 deliberately makes op-persistence the front door for that pure decision, so that expected answer is now **stale**. NOT changed here (`tests/` out of scope for A15). **S2 action:** fold "incl. `op-hooks.json` L4 expectation now stale post-F2 → re-point to op-persistence (or mark `should_trigger:false`) before any authorized re-run" into the deferred-benchmark one-liner recorded in FIXES. The other 7 edited skills' eval-sets sharpen toward their existing targets (no flips).

## Section-level open questions

- **Fold in the F10/F11 polish, or leave it in audit-04?** audit-04 keeps **F10** (op-spine-active: the description undercounts its detection paths — add the profile `Plans dir` field to the override mention) and **F11** (optional NOT-for clauses on op-visuals / op-prompting) **in the audit-04 file as polish — explicitly NOT part of A15.** Default for apply-02: **leave them** (apply-02 = clear A15 = F1–F9; no bundling per CLAUDE.md). They're cheap one-liners on the same surface, so the user may opt to fold F10/F11 into Session 2 — flagged here for an explicit decision, not silently bundled.

## Scope guardrail (whole section)

A15 touches **`skills/core/op-*/SKILL.md` frontmatter `description:` fields** (+ a bullet in op-workflow's `## Sibling skills` section, F1) **only**, plus `FIXES.md` + `CHANGELOG.md` at close (and an optional status-note in `docs/plans/audit-04-skill-triggers.md`). **No `chapters/` edits. No SKILL.md *body* rewrites** — F7 trims the *description*, not the body (the body already covers the mechanics, per audit-04). **No `tests/` edits** — no fixture asserts description text; if `tests/run.sh` flags a frontmatter issue, fix the frontmatter, not the test. **Do NOT run the API routing benchmark** (`run-eval.sh`) — deferred to audit-06. If a fix seems to need a chapter or a SKILL.md body edit, **stop**: that's a different FIXES item, not A15.

---

## Session 1 — Fix the 7 harmful misroutes (the routing-accuracy edits)

**Status**: `done` (2026-05-30)

**Goal**: Every harmful overlap in the audit-04 matrix gains a phrase-visible boundary; the blocking misroute (A15.1, op-workflow ↔ op-prepare) is fixed and lands + verifies first.

**Files to read** (orient before editing — exact list):

- `docs/plans/audit-04-skill-triggers.md` § **Findings** (F1, F2, F3, F5, F6, F8, F9) + § **Overlap matrix** — the apply-ready clauses + the 7 harmful pairs this session must close.
- `chapters/persistence/13b-skill-description-craft.md` — the rubric (what-it-does / triggers / what-it's-NOT-for) every edited description must still satisfy.
- The 8 SKILL.md files in scope (read each *before* editing — PF1; confirm current `description:` + structure): `op-workflow`, `op-hooks`, `op-anti-patterns`, `op-signaling`, `op-bucket-router`, `op-add-skill`, `op-foundations`, `op-collaboration-modes` (all under `skills/core/op-*/SKILL.md`).
- `tests/skill-triggers/eval-sets/` — list it; read the eval-set of any of the 8 that has one (expected-routing sanity check, no API spend).

**Files to write/edit** (scope — anything else is out of bounds):

- `skills/core/op-workflow/SKILL.md` — F1: append disambiguation clause to `description:` (L3) + add an op-prepare bullet to the existing `## Sibling skills` section (L47–50). **[blocking A15.1]**
- `skills/core/op-hooks/SKILL.md` — F2: narrow description to *wiring*; defer the hook-vs-CLAUDE.md-vs-skill *decision* to op-persistence 12a.
- `skills/core/op-anti-patterns/SKILL.md` — F3: add the "meta-scope review cadence → see op-signaling" cross-ref clause.
- `skills/core/op-signaling/SKILL.md` — F3: add the "catalog of anti-patterns when extending the spine → see op-anti-patterns 18-meta" cross-ref clause.
- `skills/core/op-bucket-router/SKILL.md` — F5: add the `/curate` + `/suggest` slash-command carve-out to the "never invents" clause.
- `skills/core/op-add-skill/SKILL.md` — F6: qualify the "remember this" trigger (full reusable *skill* vs op-suggest's lightweight note).
- `skills/core/op-foundations/SKILL.md` — F8: add the "actively dropping mid-session → op-recovery" clause.
- `skills/core/op-collaboration-modes/SKILL.md` — F9: add the "identify the work-shape itself → op-approach" clause.

**Build steps** (high-level):

1. **Read all 8 + the rubric + the audit-04 Findings/matrix.** For each skill, locate the current `description:` and confirm audit-04's clause grafts cleanly onto the live text (PF1 — verify, don't trust the citation; F1's line numbers are already known-stale).
2. **Apply the 7 clauses**, one skill at a time, smallest-blast-radius first; do the **blocking A15.1** first. For op-workflow, also add the op-prepare bullet to its `## Sibling skills` section (L47–50), per the disk-check note.
3. **After each edit, re-check the overlap matrix:** does the new clause introduce a *fresh* same-phrase collision (e.g. op-workflow's op-prepare clause vs op-approach)? If so, adjust the clause so the boundary stays phrase-visible. Keep every description rubric-shaped (13b).
4. **eval-set sanity check** for any edited skill with an eval-set — expected target unchanged (no API spend).
5. **Run `tests/run.sh`** — confirm no frontmatter/structural regression (7 suites green).

**Verify** (concrete):

- For each of the 7 harmful pairs, the disambiguating phrase is present in the named `description:` (e.g. `grep -c op-prepare skills/core/op-workflow/SKILL.md` ≥ 1; the op-prepare distinction is in the *description*, not only the body).
- op-workflow's `## Sibling skills` section now lists op-prepare for multi-session plan authoring (alongside op-collaboration-modes + op-brownfield).
- Overlap-matrix re-check: no edited description creates a new harmful (same-phrase, no-boundary) collision.
- `tests/run.sh` passes (7 suites). The API routing benchmark was **not** run (correct — deferred).

**Output**:

- Commit hint: `fix(skill-triggers): disambiguate 7 harmful op-* overlaps (A15.1 blocking + F2/F3/F5/F6/F8/F9)`
- Update: this section file (Session 1 → `done`; fill the **Session 1 → Session 2 handoff** note in Cross-session notes — the 8 edited files, any adapted clause, the matrix re-check result), `PROGRESS.md` (pointer → Session 2).

---

## Session 2 — Description-shape drift cleanups + close A15

**Status**: `pending`

**Goal**: The 2 router-shape drift items (op-curate-nudge gate, op-curate trim) land; FIXES A15 is compressed + resolved; the deferred-benchmark note is recorded; CHANGELOG updated.

**Files to read**:

- This section file's **Cross-session notes** — Session 1's handoff (cite it; don't re-derive what shipped).
- `docs/plans/audit-04-skill-triggers.md` § **Findings** (F4, F7; + F10/F11 only if the open question is answered "fold in").
- `chapters/persistence/13b-skill-description-craft.md` — the rubric (F7's trim must keep what / triggers / NOT-for; don't strip the scope refusal).
- `FIXES.md` § **A15** — the block to compress.

**Files to write/edit** (scope):

- `skills/core/op-curate-nudge/SKILL.md` — F4: prepend "When the bucket loop is enabled (default-off since round 6), " to the firing condition.
- `skills/core/op-curate/SKILL.md` — F7: trim the apply/reject *procedure* sentences from the `description:`; keep trigger + bucket-only scope refusal (body unchanged).
- `FIXES.md` — compress the A15 cluster (the F1–F9 enumeration → an action-shaped **✅ RESOLVED** entry + pointer to `audit-04` Findings, rule 1); add the "routing benchmark re-run warranted but blocked on audit-06 confound fix" one-liner (or attach it to A15's existing audit-06 note).
- `CHANGELOG.md` — `[Unreleased]` → `Changed`: one slim bullet (skill-trigger descriptions disambiguated; A15 resolved).
- _(optional)_ `skills/core/op-spine-active/SKILL.md` (F10) + `skills/core/op-visuals/SKILL.md` + `skills/core/op-prompting/SKILL.md` (F11) — **only if** the Section-level open question is answered "fold in."
- _(optional)_ `docs/plans/audit-04-skill-triggers.md` — mark the § "Proposed FIXES intake" note "A15 applied 2026-MM-DD" (status-note only; do not re-open the frozen findings).

**Build steps** (high-level):

1. **Apply F4 + F7** (read each SKILL.md first; keep rubric-shaped — F7 must not drop op-curate's bucket-only refusal).
2. **Re-check the overlap matrix** for the two edited skills (op-curate-nudge vs op-curate stays benign; op-bucket-router's F5 carve-out from S1 already covers the `/curate` FP).
3. **Resolve the F10/F11 open question** — fold in (apply the two polish clauses) or leave (note "F10/F11 stay in audit-04 as polish"). Default: leave.
4. **Compress + resolve FIXES A15** — action-shaped RESOLVED entry + pointer (rule 1); record the deferred-benchmark note.
5. **CHANGELOG** `[Unreleased]` Changed bullet.
6. **Run `tests/run.sh`** (frontmatter integrity after the last edits).

**Verify** (concrete):

- op-curate-nudge's `description:` opens with the bucket-loop-enabled gate; op-curate's `description:` no longer carries the apply/reject procedure but still states the bucket-only scope refusal.
- `FIXES.md` A15 is action-shaped (no F1–F9 essay), marked **✅ RESOLVED**, and points to audit-04 Findings; the deferred-benchmark note is present.
- `CHANGELOG.md` `[Unreleased]` has the one new Changed bullet.
- `tests/run.sh` passes (7 suites). The API routing benchmark was **not** run.

**Output**:

- Commit hint: `fix(skill-triggers): close A15 — op-curate-nudge gate + op-curate trim; reframe FIXES`
- Update: this section file (Session 2 → `done`), `PROJECT_PLAN.md` (apply-02 → `done`; Sections table + Status log), `PROGRESS.md` (pointer → `apply-03` — next FIXES cluster by severity, scoped via `/prep`).

## Session log

Append-only. One heartbeat per assistant turn. `/done` rolls these up into a PROGRESS.md entry.

- `/prep apply-02` @ 2026-05-29 — section drafted (2 sessions): S1 fixes the 7 harmful op-* trigger overlaps (A15.1 blocking + F2/F3/F5/F6/F8/F9, 8 SKILL.md files); S2 does the 2 drift cleanups (F4/F7) + closes A15. Chose A15 per FIXES severity (documented lead). Disk-grounded at prep: (1) op-workflow's F1 fix lands in `description:` (L3) + the existing `## Sibling skills` section (L47–50; audit-04's "48–50" citation is accurate); (2) `tests/run.sh` does NOT test routing (it skips `tests/skill-triggers/` — run.sh:13 — which is API-gated + deferred to audit-06's confound fix), so this section uses the audit-04 overlap matrix as the routing proxy. No code/doc edits this session (plan only).
- session 1 @ 2026-05-29 23:56 — touched: docs/PROJECT_PLAN.md benchmarks/sessions/
- session 1 @ 2026-05-30 00:08 — touched: docs/PROJECT_PLAN.md skills/core/op-add-skill/SKILL.md skills/core/op-anti-patterns/SKILL.md skills/core/op-bucket-router/SKILL.md skills/core/op-collaboration-modes/SKILL.md skills/core/op-foundations/SKILL.md skills/core/op-hooks/SKILL.md skills/core/op-signaling/SKILL.md
- Session 1 **done** 2026-05-30. Applied all 7 harmful-overlap clauses (F1 blocking A15.1 + F2/F3/F5/F6/F8/F9) across 8 `skills/core/*/SKILL.md` `description:` fields + op-workflow `## Sibling skills` op-prepare bullet. Verify: 9/9 phrase-boundary greps PASS; `tests/run.sh` 7 suites green; overlap-matrix re-check clean (no new collision; op-workflow↔op-approach checked); API routing benchmark **not** run (deferred). Read-only-to-scope honored — `git diff --stat` shows only the 8 SKILL.md (9 ins/8 del), no body/`chapters/`/`tests/`. Findings for S2: F3 adapted bidirectional (beyond audit-04 verbatim); `op-hooks.json` L4 eval expectation now stale post-F2 (→ fold into S2's deferred-benchmark note). Handoff note above filled. Pointer → Session 2.
- session 2 @ 2026-05-30 00:17 — touched: docs/PROJECT_PLAN.md skills/core/op-add-skill/SKILL.md skills/core/op-anti-patterns/SKILL.md skills/core/op-bucket-router/SKILL.md skills/core/op-collaboration-modes/SKILL.md skills/core/op-foundations/SKILL.md skills/core/op-hooks/SKILL.md skills/core/op-signaling/SKILL.md
