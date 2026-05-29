# Section: audit-03-personalization

> Section 3 of the audit pass. See `docs/PROJECT_PLAN.md` for the full master plan.
> **Audit phase: WRITE FINDINGS ONLY.** Do not edit `chapters/`, `skills/core/`, code, or templates in this section. Blocking findings flow to `FIXES.md` for apply sessions later.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints — interleaving audit + apply breaks coherence across sections.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — the four conditions every audit session must satisfy (this section's `/prep` pass, completed 2026-05-28, satisfies condition 1).

## Section goal

Audit the project's second load-bearing claim — **personalization is real, not decorative** (`CLAUDE.md` L53–L73) — by verifying the field-consumer contract in **both directions**:

1. **Field → consumer.** Every field declared in `skills/core/op-onboard/profile-template.md` has at least one *real* consumer (see the consumer test below) somewhere in `chapters/`, `skills/`, or `global/`.
2. **Consumer → field.** Every consumer named in the "Read by" column of `chapters/personalization/19g-field-effects.md` actually reads (or instructs Claude to honor) the field its row claims — verified by grep + file inspection, not trusted from the prose.

**The consumer test (decided at `/prep`, 2026-05-28).** A field is **real** if *either*:

- **Mechanical** — a script / skill / hook greps the field and branches on its value (e.g., `spine-writeback.sh` reads the threshold fields; `op-signaling/SKILL.md` Step 0 reads Push-back; `subscription-tune.md` reads Plan), **or**
- **Instruction** — a chapter or skill tells Claude to honor the field *and* the field is present in the profile Claude reads every session (e.g., "Answer length: Terse" has no script grepping it, but `op-prompting` ch.09 instructs Claude to honor it and the profile is in-context).

A field is **decorative** only if **neither** holds — it is captured into the profile and nothing (no mechanism, no instruction) ever acts on its value. Decorative-ness is what claim #2 forbids; a field with no *enforcement mechanism* but a real honoring instruction is **real, not decorative**. (This is the same standard by which A2.1 Plans-dir + A2.2 Push-back were judged "wired.")

## Done criteria

- [ ] **Canonical field list extracted** from `profile-template.md` — every `- **<Field>:**` bullet across all sections (Subscription → Spine defaults). Count recorded; re-derived from disk, not trusted from this file's "~41" prose (per PF1 methodology carried forward — see Cross-section notes).
- [ ] **Claimed-consumer map extracted** from `19g-field-effects.md` — every row across all 9 tables, with its "Read by" cell parsed into named consumers (file paths / skill names / hook names / chapter numbers).
- [ ] **Bidirectional doc reconciliation done:** (a) fields in `profile-template.md` with NO row in `19g` (undocumented field); (b) `19g` rows naming a field NOT in `profile-template.md` (phantom/orphan row). Both lists produced, or explicitly "none."
- [ ] **Per-field consumer verdict recorded** for every field: `mechanical` / `instruction` / `decorative`, with the consumer location(s) (`file:line`) for the first two and "0 consumers" evidence for the third. (Both mechanical and instruction count as real — see consumer test.)
- [ ] **Per-claim verification done:** every `19g` "Read by" entry opened and confirmed to actually read/honor the field — overstated claims (named consumer that doesn't read the field) listed explicitly. Grep-confirmed, not trusted (PF1 methodology).
- [ ] **A2 cluster reconciled.** `FIXES.md` A2 names 4 originally-decorative fields (Plans dir G2, Push-back Q4, Active signals D1, Session shape G1). Independently confirm A2.1 (G2) + A2.2 (Q4) "shipped" claims are real (consumer present + branches/honors); confirm A2.3 (D1) + A2.4 (G1) are still decorative. Reconcile the count: the original stress-test audit named 4 — does the systematic sweep across all ~41 fields surface MORE decorative fields it missed?
- [ ] **All findings logged** in the Findings table with severity (`blocking` / `drift` / `polish`).
- [ ] **Blocking findings appended to `FIXES.md`** — extend the A2 cluster (do not duplicate A2.3/A2.4; confirm + reference), or open a new `A##` cluster for newly-found decorative fields. Keep entries action-shaped.
- [ ] PROGRESS.md advanced to `audit-04-skill-triggers` at `/done`.

## Out of scope (do not drift here)

- **No edits to `chapters/`, `skills/core/`, code, or templates.** Audit phase = write findings only. In particular: **no rewriting `19g`** to make an overstated row true, and **no wiring** the decorative fields — that wiring is A2.3 (D1 → `op-signaling`) + A2.4 (G1 → `op-workflow`/`op-collaboration-modes`) apply work, sequenced after the full audit phase.
- **No profile UX / question-wording audit.** Whether a question is well-phrased, well-ordered, or missing is a separate UX pass. This audit only checks the field→consumer→field contract for fields that *exist*.
- **No architecture / router-shape audit** (Section 1, `audit-01-architecture` — done). If a field's only consumer is a SKILL.md *frontmatter description* (a session-start triggering surface, not a body read), capture it in Cross-section notes for Section 4 — don't judge router shape here.
- **No token-cost audit** (Section 2, `audit-02-token-cost` — done). `op-onboard --deep` being the heaviest load (audit-02 F3) is noted, not re-measured.
- **No skill-trigger accuracy audit** (Section 4, `audit-04-skill-triggers`).
- **No self-discipline sweep** (Section 5, `audit-05-self-discipline`) — though "19g must be true / when you add a field you must add a 19g row" is a `CLAUDE.md` rule; if `19g` overstates, capture the *finding* here and flag the *rule-violation framing* for audit-05 in Cross-section notes.
- **No test-coverage or cross-reference audit** (Section 6, `audit-06-tests-docs`).

If a finding touches another section's surface, capture it in "Cross-section notes" below and move on. Do not bundle.

## Files to read for project understanding (cold-start orientation)

Read in this order at session start. Stop after this list — do not pull additional files until a procedure step calls for them.

1. `docs/PROJECT_PLAN.md` — § Constraints (audit-phase boundary) + § Audit-phase pre-flight protocol (the four conditions; heartbeat caveat: `touched:` lines reflect the dirty working tree, not per-turn deltas).
2. `CLAUDE.md` — load-bearing claim #2 (L53–L73): "Personalization is real, not decorative." The worked examples there (subscription tier, push-back intensity, answer length, cost sensitivity, profile-settable defaults, Section W) name the fields this audit checks. Note especially L72: *"When you add a new field, you must add a row to 19g — otherwise the field is decorative."*
3. `chapters/personalization/19g-field-effects.md` — the canonical field → consumer map. The truth-claim audit-03 verifies. Every "Read by" cell is a claim to confirm.
4. `skills/core/op-onboard/profile-template.md` — the canonical field declaration (what fields a written profile holds). The source of the field list.
5. `chapters/personalization/19a-overview.md`, `19b-profile-and-onboarding.md`, `19f-subscription-aware.md` — for field-consumption patterns; `19f` is the worked example of *deep* wiring (8 levers × 4 tiers) the rest of the profile is measured against.
6. `skills/core/op-onboard/questions-essential.md` + `questions-deep.md` — the *asked* surface (input edge). Used only for the light orphan check (a field asked/stored but documented/consumed nowhere, or vice-versa). NOT the primary axis.
7. `FIXES.md` § A2 cluster (+ A12 `/profile verify` proposal — the command that would mechanize this audit; nice-to-have after A2 lands).
8. `docs/plans/audit-01-architecture.md` § Findings + § Cross-section notes — PF1 partial-overstatement methodology (load-bearing here) + F1 (op-onboard preview extraction, personalization-adjacent, already captured).
9. `docs/plans/audit-02-token-cost.md` § Findings + § Cross-section notes — F2 (`questions-deep.md` L308-317 broken cross-ref, already in A13 — don't re-log) + F3 (op-onboard --deep heaviest load, context only).
10. This file.

## Cross-section notes carried forward from audit-01 + audit-02

Per the audit-phase pre-flight protocol rule 4 (cross-section notes propagate manually), the following apply here:

- **[LOAD-BEARING] PF1 partial-overstatement methodology (from audit-01).** Audit-01's PF1 declared the Section-0 count-claim sweep "complete and consistent"; Session 1 found three residuals. **Implication for audit-03:** treat every *"shipped"* / *"wired"* / *"Read by X"* claim as suspect until grep-confirmed. Specifically — `FIXES.md` A2 says A2.1 (Plans dir) + A2.2 (Push-back) "shipped"; do NOT take that as proof the consumers are real. Open the named consumer, confirm it branches on (mechanical) or instructs Claude to honor (instruction) the field. The whole point of this audit is that `19g`'s claims and FIXES's "shipped" annotations are exactly the kind of prose PF1 taught us to re-verify from disk.
- **F1 op-onboard preview extraction (from audit-01).** Personalization-adjacent (it's the onboarding skill), but it is a router-shape / token-cost finding already captured (audit-01 F1, cost-quantified in audit-02 F4) — **do not re-find it here.** Audit-03's lens is field→consumer, not router shape.
- **F2 questions-deep.md L308-317 broken cross-ref (from audit-02).** Already triaged into the A13 cluster. `questions-deep.md` is in audit-03's read set (the asked surface) — **do not re-log the broken cross-ref**; do continue to use the file for the field-asked orphan check. The broken block (L308-317) is being dropped wholesale by A13; ignore it as a field source.
- **Heartbeat caveat (pre-flight rule 3 / audit-05 PF2).** Verify this session's actual mutations via `git diff` against the session-start commit at `/done`, NOT by reading Session log `touched:` lines (the Stop hook builds `touched:` from the whole dirty working tree, not per-session deltas).

## Cross-section notes (this section's own — populated as Session 1 runs)

- **For audit-04 (skill-triggers).** If any field's only "consumer" turns out to be a SKILL.md *frontmatter description* (i.e., the field name appears in a trigger-classifier description but no skill *body* or chapter reads it), that's a triggering-surface concern, not a body-read consumer. Capture the field + description here; audit-04 owns whether description bytes earn their keep.
- **For audit-05 (self-discipline).** `CLAUDE.md` L72 makes "every field has a 19g row" a project rule, and §2 makes "19g must be true" load-bearing. Any *overstated* `19g` row this audit finds (claimed consumer that doesn't read the field) is a self-discipline rule-violation, not just a doc-drift. Log the finding here; flag the rule-violation framing for audit-05's sweep.
- **For audit-06 (tests + docs).** There is no automated test asserting field→consumer coverage today; `FIXES.md` A12 proposes `/profile verify` as the command that would mechanize exactly this audit. Note for audit-06's test-gap sweep: a missing coverage test is why this drift can accumulate silently between manual audits.

## Section-level open questions

- **Session count.** ✓ Resolved at `/prep` (2026-05-28): **one session**, with a documented clean split point (bidirectional reconcile + per-field consumer verdict = a natural Session-1 close; exhaustive per-claim `19g` verification = a natural Session 2) if the per-claim pass pushes the entry past the 100-line rule. Matches audit-01 + audit-02 (both single-session).
- **Consumer test (mechanical vs instruction).** ✓ Resolved at `/prep` (2026-05-28): **both count as real**; only "neither mechanism nor instruction" is decorative. See § Section goal. The verdict per field is still *recorded* (mechanical / instruction / decorative) so the Findings table shows which real fields have no enforcement teeth.
- **Preliminary doc-reconciliation observation (verify, don't trust).** A `/prep`-time glance suggests the `profile-template.md` field set and the `19g` row set are *aligned* at ~41 (29 interview + 12 spine-defaults) — unlike audit-01, where INDEX was missing a chapter row. If that holds, audit-03's center of gravity is **consumer-claim verification** (does the named consumer actually read?), not doc-row reconciliation. Re-derive both counts from disk to confirm; do not assume alignment.

---

## Session 1 — Field/consumer coverage audit

**Status**: `pending`

**Goal**: Produce a triaged findings table that, for every profile field, records a consumer verdict (mechanical / instruction / decorative) with `file:line` evidence; lists every overstated `19g` claim and every orphan/undocumented field; and reconciles the A2 cluster against the full systematic sweep. No code or content edits.

**Files to read** (orient list — exact cold-start budget): the 10-item list under "Files to read for project understanding" above. Additional files (individual chapters / skills / hooks named in `19g` "Read by" cells) are opened on-demand during steps 4–5, not as part of the orientation budget.

**Files to write/edit** (scope — anything else is out of bounds without explicit pause):

- This section file's "Findings" table + Session log + the "Cross-section notes (this section's own)" block above.
- `FIXES.md` — extend the A2 cluster (confirm/close A2.1–A2.4 + add any newly-found decorative fields as `A2.x`), or open a new `A##` cluster per blocking finding. Action-shaped entries; narrative stays in this file's Findings.
- `docs/PROGRESS.md` — advance pointer to `audit-04-skill-triggers` at `/done`.

**Strictly out of scope:** `chapters/personalization/19g-field-effects.md` (no rewriting overstated rows), any chapter/skill/hook/code/template, `questions-*.md` edits, `profile-template.md` edits. Wiring the decorative fields is A2.3/A2.4 apply work.

**Build steps**:

1. **Extract the canonical field list.** From `profile-template.md`, grep every `- **<Field>:**` bullet across all sections. Record each as `<Field name> (<question code>)` — e.g., `Push-back intensity (Q4)`, `Long-session turn threshold (spine-default)`. Count; note the interview vs spine-defaults split. **Watch the code collision:** profile field codes (`A1` Years coding, `A2` Comfort areas, `B1`, `C1`, …) are NOT the same namespace as `FIXES.md` A-clusters (`A1` token benchmark, `A2` decorative fields). Disambiguate every reference.
2. **Extract the claimed-consumer map.** From `19g-field-effects.md`, parse every table row into `field → [named consumers]`. The "Read by" cells name chapters (by number), skills (by name), hooks, and adjacent files. Build the list verbatim — this is the set of claims to verify in step 5.
3. **Bidirectional doc reconciliation.** Diff the step-1 field set against the step-2 `19g` row set: (a) fields with no `19g` row (undocumented — a `CLAUDE.md` L72 violation); (b) `19g` rows for fields absent from `profile-template.md` (phantom). Also run the *light* orphan check against `questions-essential.md`/`questions-deep.md`: a field stored+documented but never asked, or asked but never stored. Record all three lists (or "none").
4. **Per-field consumer grep (mechanical pass).** For each field, grep its label AND its question code AND any obvious key variants across `chapters/`, `skills/`, `global/` — e.g. `grep -rin -e "push.back" -e "Q4" chapters skills global`. **Exclude the three declaration/doc surfaces** (`profile-template.md`, `19g-field-effects.md`, `questions-*.md`) from the consumer count — those declare/document/ask the field; they are not consumers. A hit elsewhere that *branches on the value* = mechanical consumer (record `file:line`). Zero mechanical hits → candidate decorative; resolve in step 5.
5. **Per-claim verification + instruction pass (the load-bearing step).** For every `19g` "Read by" entry, open the named consumer and confirm it actually reads/honors the field:
   - **Mechanical claim** (e.g., "Read by `spine-writeback.sh`") — confirm the script greps + branches. Overstated if the named file doesn't reference the field.
   - **Instruction claim** (e.g., "Read by every response / `op-prompting` ch.09") — confirm a chapter/skill *instructs* Claude to honor the field AND the field is in `profile-template.md` (so it's in the profile Claude reads). Present instruction + present in profile = real (instruction-consumed).
   - For any field that was zero-mechanical in step 4: check for an instruction consumer here before declaring it decorative. **Decorative = neither mechanical nor instruction.**
   - Apply PF1 discipline throughout: a `19g` "Read by X" that opens to a file not referencing the field is an **overstated claim** — log it.
6. **A2 cluster reconciliation.** Independently confirm: A2.1 Plans dir (G2) — does `spine-writeback.sh` + `op-spine-active` actually read it (mechanical)? A2.2 Push-back (Q4) — does `op-signaling` Step 0 + `11g` actually read/honor it? Confirm A2.3 Active signals (D1) + A2.4 Session shape (G1) are still decorative (neither mechanism nor instruction acts on them). Then the systematic question: across all ~41 fields, are there decorative fields the original 4-field stress-test audit missed?
7. **Log findings + triage.** Append to the Findings table (`F# / Severity / Field-or-Loc / Finding / Recommendation`). Severities:
   - `blocking` — a field the spine *promises* to honor (declared + documented in 19g) but silently ignores (decorative) — a direct contradiction of load-bearing claim #2. Or a `19g` claim materially false (named consumer doesn't read the field).
   - `drift` — undocumented field, phantom 19g row, overstated-but-harmless claim, or decorative-by-design field that should be marked as such.
   - `polish` — wording/precision fix in a 19g cell.
   For every `blocking` finding: extend `FIXES.md` A2 (newly-found decorative fields as `A2.x`, referencing this file) or open a new `A##` cluster. **Do not duplicate A2.3/A2.4** — confirm + reference. Keep FIXES action-shaped.

**Verify**:

- Field-list extraction (step 1) covers every `- **<Field>:**` bullet in `profile-template.md`. Verify the recorded count is re-derived from disk and the interview/spine-defaults split is stated in Findings (do not trust this file's "~41").
- Bidirectional reconciliation (step 3) produces both lists explicitly — undocumented fields AND phantom 19g rows — even if the answer is "none."
- Every field has a recorded verdict (`mechanical` / `instruction` / `decorative`) with `file:line` evidence for the real ones and "0 consumers" evidence for decorative ones. Verify by checking the Findings table (or an inline verdict table) has one row per field — count matches step 1.
- Every `19g` "Read by" claim was spot-verified by opening the named consumer (PF1 methodology). Verify by Findings noting which claims were confirmed vs overstated — not "looks consistent."
- A2.1/A2.2 "shipped" claims independently confirmed real; A2.3/A2.4 confirmed still-decorative. Verify by the A2-reconciliation paragraph in Findings + a count reconciliation against the original 4.
- `FIXES.md` after the session is queue-shaped: discrete, triageable action items; no narrative essays. If the A2 cluster has drifted into narrative, compact back to action items + link to this file's Findings for detail.
- Heartbeat caveat (pre-flight rule 3): actual mutations verified via `git diff` against the session-start commit at `/done`, not by reading Session log `touched:` lines.

**Output**:

- Commit message hint: `docs(audit): section 3 — personalization field/consumer findings`
- Update at `/done`: this section file (Findings filled, status `done`), `docs/PROGRESS.md` (pointer → `audit-04-skill-triggers`, refresh next-session reading list), `FIXES.md` (A2 extended/reconciled, or new `A##` cluster if blocking findings).

---

## Findings

_(populated when Session 1 runs)_

Planned shape: a per-field verdict table (`Field (code) | Section | Verdict mechanical/instruction/decorative | Consumer file:line | Notes`) covering all ~41 fields, followed by the `F# / Severity / …` findings table for the triaged issues (overstated claims, newly-found decorative fields, orphans). All counts re-derived from disk per PF1, not trusted from prose.

## Session log

_(per-turn heartbeats appended automatically by `spine-writeback.sh` Stop hook during the active session — `touched:` reflects the whole dirty working tree, not per-session deltas; verify real mutations via `git diff` at `/done`)_

- session 1 @ 2026-05-28 22:50 — touched: FIXES.md docs/PROJECT_PLAN.md
- `/prep` pass (2026-05-28): stub (56 lines) elaborated into a fully-detailed Session 1 entry. Consumer test (mechanical OR instruction = real) + single-session shape decided. Cross-section notes carried forward from audit-01 (PF1 methodology — load-bearing) + audit-02 (F2/F3 — don't re-find). No `chapters/`/`skills/core/`/code/template edits; writes confined to this file + a minimal `docs/PROGRESS.md` pointer refresh. Pre-flight rule 1 now satisfied for audit-03.
