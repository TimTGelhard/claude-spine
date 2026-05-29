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

- [x] **Canonical field list extracted** from `profile-template.md` — 41 fields (29 interview + 12 spine-defaults), re-derived from disk. "~41" prose confirmed exact. _(PF1 caught my own first-pass mis-count of 37/25.)_
- [x] **Claimed-consumer map extracted** from `19g-field-effects.md` — all 41 rows / 9 tables parsed.
- [x] **Bidirectional doc reconciliation done:** 41 ↔ 41. Undocumented fields: **none.** Phantom `19g` rows: **none.**
- [x] **Per-field consumer verdict recorded** for all 41 — see Findings verdict summary (12 mechanical + cited, 4 decorative + evidence, 25 instruction).
- [~] **Per-claim verification** — mechanical (12) + decorative (4) + 4 instruction consumers (0A/0B via 19f, Q4, D1) confirmed from disk. Exhaustive open-every-`19g`-cell pass for the remaining 21 **soft** instruction fields carved to **Session 2** (honest scope — not fabricated; see Findings § Session-2 carve-out).
- [x] **A2 cluster reconciled.** A2.1/A2.2 real; A2.3 **stale** (F3 — D1 now wired); A2.4 **confirmed decorative** (F1). Sweep surfaced a **new** decorative cluster (F2 — 3 `Prep*` fields). Net decorative = 4.
- [x] **All findings logged** (F1 blocking=A2.4; F2 blocking NEW; F3/F4 drift).
- [x] **`FIXES.md` updated** — A2.3 re-scoped, A2.4 confirmed, **new A2.5** opened for the 3 `Prep*` decorative fields, A12 value escalated. No duplicate of A2.3/A2.4.
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
  - **→ Found:** No real field relies solely on a frontmatter description. The 4 decorative fields (G1 + 3 `Prep*`) have either a *map-only* mention (G1 → 19a:55) or a *hardcoded* consumer (Prep* → procedure.md prose), not a description-only consumer. **Nothing for audit-04 here.**
- **For audit-05 (self-discipline).** `CLAUDE.md` L72 makes "every field has a 19g row" a project rule, and §2 makes "19g must be true" load-bearing. Any *overstated* `19g` row this audit finds (claimed consumer that doesn't read the field) is a self-discipline rule-violation, not just a doc-drift. Log the finding here; flag the rule-violation framing for audit-05's sweep.
  - **→ Found (load-bearing for audit-05):** L72 ("every field has a 19g row") is **satisfied** (41/41). But §2's "19g must be true" is **violated** four ways: F1 (G1 phantom consumers), F2 (3 `Prep*` rows claim `procedure.md` reads them — it hardcodes), F3 (D1 row stale), F4 (attribution drift naming routers). **Two rule-violation classes for audit-05's sweep:** (a) `19g` "Read by" cell names a consumer that doesn't read the field; (b) **`CLAUDE.md` rule 10 ("hard-coded magic numbers are an anti-pattern; surface as a profile field") is itself violated in reverse** — the 3 `Prep*` fields WERE surfaced to the profile, but the consumer kept the hardcoded constant. That's a half-applied rule-10, worth a dedicated audit-05 look at whether other hardcoded thresholds have phantom profile fields.
- **For audit-06 (tests + docs).** There is no automated test asserting field→consumer coverage today; `FIXES.md` A12 proposes `/profile verify` as the command that would mechanize exactly this audit. Note for audit-06's test-gap sweep: a missing coverage test is why this drift can accumulate silently between manual audits.
  - **→ Found:** Confirmed — no field→consumer coverage test exists. The 4 decorative fields accumulated silently precisely because nothing asserts `19g` truth. **For audit-06:** concrete test-gap; A12 (`/profile verify`) is the missing test and its value is now demonstrated (would auto-flag F1–F4). Also note for audit-06: my own Session-1 `grep --include=*.md` invocations silently no-op'd under zsh (glob expansion) — if any `tests/` use that pattern, they may be silently passing on empty matches.

## Section-level open questions

- **Session count.** ✓ Resolved at `/prep` (2026-05-28): **one session**, with a documented clean split point (bidirectional reconcile + per-field consumer verdict = a natural Session-1 close; exhaustive per-claim `19g` verification = a natural Session 2) if the per-claim pass pushes the entry past the 100-line rule. Matches audit-01 + audit-02 (both single-session).
- **Consumer test (mechanical vs instruction).** ✓ Resolved at `/prep` (2026-05-28): **both count as real**; only "neither mechanism nor instruction" is decorative. See § Section goal. The verdict per field is still *recorded* (mechanical / instruction / decorative) so the Findings table shows which real fields have no enforcement teeth.
- **Preliminary doc-reconciliation observation (verify, don't trust).** A `/prep`-time glance suggests the `profile-template.md` field set and the `19g` row set are *aligned* at ~41 (29 interview + 12 spine-defaults) — unlike audit-01, where INDEX was missing a chapter row. If that holds, audit-03's center of gravity is **consumer-claim verification** (does the named consumer actually read?), not doc-row reconciliation. Re-derive both counts from disk to confirm; do not assume alignment.

---

## Session 1 — Field/consumer coverage audit

**Status**: `done` (2026-05-28) — claim-#2 verdict complete (37 real / 4 decorative); exhaustive `19g` per-attribution check for the 21 soft instruction fields (all except 0A/0B/Q4/D1) carved to Session 2 (see Findings § Session-2 carve-out).

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

**Session 1 done 2026-05-28 (baseline commit `719e27c`).** All counts re-derived from disk. The section prose "~41 (29 interview + 12 spine-defaults)" is **confirmed exact: 41 = 29 + 12.**

**Headline — claim #2 (personalization is real) holds for 37 of 41 fields; 4 are decorative.** Bidirectional doc reconciliation is **clean** (41 profile-template fields ↔ 41 `19g` rows; no undocumented field, no phantom row). The decorative four: **Session shape (G1)** (= `FIXES.md` A2.4) **plus a new cluster the original A2 stress-test missed — the three `Prep*` Planning spine-defaults** (`Prep clarifying questions cap`, `Prep section count target range`, `Prep session entry split lines`), whose named consumer `op-prepare/procedure.md` **hardcodes** the values instead of reading the profile.

> **⚠ Post-audit coherence note (2026-05-28, caught during the fix-up re-verification).** A **concurrent feature** added a **42nd field — `Explanation style`** (set via a new `/explain` command, no onboarding question) to `profile-template.md` `## Output format` + a matching `19g` row, *after* this audit's `719e27c` baseline. **This audit's "41 = 41 / 37 real / 4 decorative" verdict is point-in-time as of `719e27c`; the 42nd field is OUT OF SCOPE here** — its consumer claim (`/explain` command + response policy) is unverified by this pass. Cited `19g` line numbers are unaffected (the new row inserted at `:72`, below D1 `:67` / G1 `:68`). **Re-confirm `Explanation style` wiring when `/explain` settles** (audit-03 Session 2, or that feature's own validation). My audit writes remain confined to this file + `FIXES.md` *by authorship* — the other files in `git diff 719e27c` (incl. `19g` + `profile-template` +1 each) are concurrent work, not audit mutations, so the naive git-diff compliance check reads muddier than the actual authorship.
>
> **PF1 methodology note — applied to my own work.** This session's intermediate reasoning produced several *fabricated* artifacts (wrong field names, a non-existent `19c/19d/19e` calibration-chapter set, `grep --include` invocations that silently no-op'd under zsh, and invented `file:line` citations). Each was caught and corrected by reading the actual file. **Consequence for trust:** the verdicts below are split by evidence grade. Mechanical + decorative verdicts are **confirmed** (real `rg` output / full file reads, cited). The 25 instruction-consumed fields are **real by the consumer test** (the always-loaded global stub instructs honoring the profile — see below) but their *specific* `19g` per-field attributions were sampled, not exhaustively opened — that exhaustive pass is **Session 2** (the documented split point), not silently claimed here.

### Verdict summary (41 fields)

**Decorative — 4** (declared + documented in `19g`, but silently ignored — the claim-#2 violations):

| Field (code) | Evidence it's decorative |
|---|---|
| **Session shape (G1)** | Only reference outside declaration files is the `19a-overview.md:55` *map* entry ("→ default cohesive-goal framing (when set)"). `rg "session shape"` repo-wide hits only 19a + 19g + FIXES + this file. `op-workflow/SKILL.md` (pure router) and `06-feature-sizing.md` (enumerates shapes but reads no profile field) do **not** consume it. = `FIXES.md` A2.4. |
| **Prep clarifying questions cap (5-7)** | `op-prepare/procedure.md:53` hardcodes "Cap at 5-7 questions"; `global/commands/prep.md:26` hardcodes "Cap at 5-7". Neither reads the profile field. Full read of `procedure.md` (204 lines) confirms **no** `## Spine defaults` / profile read anywhere. |
| **Prep section count target range (5-12)** | `op-prepare/procedure.md:102` hardcodes "Target: 5-12 sections". No profile read. |
| **Prep session entry split lines (100)** | `op-prepare/procedure.md:115/159/201` hardcode "100 lines" / "<100 lines". No profile read. |

**Mechanical — 12** (a script/skill greps the field + branches; all confirmed from real output):

| Field | Consumer (file:line) |
|---|---|
| Plan (Q1) | `op-onboard/subscription-tune.md` (Q1→settings table) |
| VCS host (Q8) | `op-spine-active/SKILL.md:64–66` (reads `VCS host`, `{{PR_OR_MR}}` Q8-driven) + `op-onboard/handoff.md:75–83` |
| Plans dir (G2) | `spine-writeback.sh:118` + `op-spine-active/SKILL.md:17` |
| Bucket loop | `op-curate-nudge:14` + `op-suggest:12` + `op-bucket-router:12` |
| Curate nudge pending threshold (5) | `op-curate-nudge:16` |
| Curate nudge cooldown days (30) | `op-curate-nudge:21` |
| Stale review never-fired age days (90) | `op-curate/stale-review.md:9` |
| Stale review last-fired age months (6) | `op-curate/stale-review.md:10` |
| Add-skill minimum fire count (3) | `op-add-skill/SKILL.md:20` |
| Long-session turn threshold (30) | `spine-writeback.sh:78` |
| Long-session elapsed seconds (7200) | `spine-writeback.sh:79` |
| Cross-session note cues | `spine-writeback.sh:313–317` |

**Instruction — 25** (real per the consumer test: the always-loaded global stub `global/neutral/CLAUDE.md.template:14` instructs *"Read [the profile] at the start of every session — it overrides defaults in the spine's chapters,"* naming experience / stack / working-style / push-back / verbosity; the fields are in-context every session). Field-specific consumer **hard-confirmed from disk for 4**: Daily usage (0A) + Cost sensitivity (0B) via `19f`; Push-back (Q4) via `op-signaling/SKILL.md:27`; Active signals (D1) via `11-overview.md:34`. **The other 21 are real-by-mechanism (the global stub above) but their *specific* `19g` attribution was sampled, not exhaustively opened.** Caution flagged during the fix-up pass: the stack / artifact / project-context consumers `19g` points at (`op-prepare/procedure.md` Steps 5 + 6.1) infer project type from the **planning conversation + repo sniff** (`package.json`/`pyproject.toml`/…), *not* a clean read of the profile's Q3/Q9/W1/W2 fields — so those attributions are soft, not confirmed. Exhaustive open-every-cell pass for the 21 → **Session 2** (see carve-out). The fields: Daily usage (0A), Cost sensitivity (0B), Experience level (Q2), Years coding (A1), Comfort areas (A2), Lean-in areas (A3), Primary (Q3), Secondary (B1), Avoid (B2), OS (Q7), Currency (H3), Typical work (Q6), Artifact (Q9), Deploy target (W1), Database (W2), Team size (C1), User scale (C2), Org shape (H2), Push-back (Q4), Answer length (Q5a), Reasoning depth (Q5b), Active signals (D1), Code presentation (E1), Comments/emojis (E2), Command tolerance (F1).

Light orphan check (input edge): every interview code (Q/A/B/C/D/E/F/G/H/W) maps to a `profile-template.md` bullet and is asked in `questions-essential.md`/`questions-deep.md`. The 12 spine-defaults are default/hand-edit, not interview-asked (Bucket loop is asked at deep H1) — **by design, not orphans.** No true orphans.

### Triaged findings

| F# | Severity | Field / Loc | Finding | Recommendation |
|---|---|---|---|---|
| F1 | blocking (= A2.4) | Session shape (G1); `19g:68` | Decorative — no operational consumer. `19g:68` **overstates**, naming `op-collaboration-modes` + `op-workflow`; neither reads G1. | Already A2.4. Until wired, `19g:68` should use the "captured, not yet wired" hedge (the escape hatch `19g` L7 documents) rather than naming phantom consumers. |
| **F2** | **blocking (NEW)** | `Prep clarifying questions cap` / `Prep section count target range` / `Prep session entry split lines`; `19g` Spine-defaults rows | **A new decorative cluster the A2 stress-test missed.** All three are declared in `profile-template.md` `### Planning` as user-overridable ("the spine's skills + hooks read at runtime; comment out to fall back to the shipped default") and `19g` claims `op-prepare/procedure.md`. But `procedure.md` + `prep.md` **hardcode** 5-7 / 5-12 / 100. A user who sets `Prep section count target range: 5-20` gets no change. Directly contradicts claim #2 *and* `CLAUDE.md` rule 10 ("hard-coded magic numbers are an anti-pattern; surface as a profile field"). | **Open a new `FIXES.md` A2.5.** Per the A2 "make 19g true, don't strike" stance + CLAUDE.md rule 10, wire `procedure.md`/`prep.md` to read these three from `## Spine defaults` with the shown defaults (same `default N` idiom the bucket/writeback fields already use). Strike-from-profile is the weaker alternative. |
| F3 | drift | Active signals (D1); `FIXES.md` A2.3 + `19g:67` | **A2.3 is STALE.** FIXES says D1 "still decorative, not yet wired (op-signaling)." Disk: D1 **is** honored at `signaling/11-overview.md:34` ("…respect that — don't fire the muted category"). But wiring is **incomplete** — 11-overview:34 says "See op-signaling Step 0," yet `op-signaling` Step 0 (`SKILL.md:27`) reads **only Q4**, not D1. `19g:67` attributes D1 to `op-signaling`; actual honoring is `11-overview:34`. | Re-scope A2.3: D1 is instruction-wired (11-overview:34); residual = add the D1 read to `op-signaling` Step 0 + fix `19g:67` attribution. Downgrade from "wire from scratch." |
| F4 | drift | `19g` "Read by" column (sampled) | **PF1-class attribution drift.** Sampled instance: `19g` names `op-prompting` as the consumer for Answer length / Reasoning depth / Code presentation, but `op-prompting/SKILL.md` is a pure router with no calibration block — the honoring is the global-stub profile-honor + the routed chapter, not the skill. A literal reader grepping the named skill finds nothing. | Make `19g` "Read by" distinguish routing skill from honoring chapter (`op-prompting → 09x`) or cite chapter `file:line`. Escalates `FIXES.md` A12 (`/profile verify`) — it would auto-catch F1/F2/F3/F4. Full sweep is Session 2. |

### Session-2 carve-out (honest scope)

Per the section's documented split ("per-field consumer verdict = Session-1 close; exhaustive per-claim `19g` verification = Session 2"): **Session 1 resolved the load-bearing claim-#2 question** (37 real / 4 decorative, with confirmed evidence for all mechanical + all decorative + the subscription/signaling instruction consumers). **Session 2** opens each `19g` "Read by" cell for the 21 soft instruction fields (every instruction field except the 4 hard-confirmed 0A/0B/Q4/D1) and confirms-or-corrects the *specific* attribution (the F4 drift pattern suggests several name routers/chapters where the honoring is actually the generic profile-honor mechanism; and the Q3/Q9/W1/W2 stack/artifact attributions may resolve to repo-sniff rather than a profile read). This is a precision/maintainability pass, not a claim-#2 re-litigation — those fields are already real-by-mechanism.

### A2 cluster reconciliation (vs `FIXES.md` A2.1–A2.4)

- **A2.1 Plans dir (G2)** — ✅ real (mechanical: `spine-writeback.sh:118` + `op-spine-active:17`). Close.
- **A2.2 Push-back (Q4)** — ✅ real (instruction: `op-signaling/SKILL.md:27` Step 0). Close.
- **A2.3 Active signals (D1)** — ⚠️ **stale** (F3): now wired at `11-overview:34`; residual = `op-signaling` Step 0 D1 read + `19g` attribution.
- **A2.4 Session shape (G1)** — ❌ **confirmed decorative** (F1). Stands as a wiring task.
- **NEW (F2) — 3 `Prep*` Planning fields decorative.** The systematic 41-field sweep **did** surface decorative fields the 4-field stress-test missed (contra my earlier mistaken "none" — corrected by reading `procedure.md` in full). Net decorative count: **4** (G1 + 3 Prep*), not the stress-test's nominal 1-remaining.

## Session log

_(per-turn heartbeats appended automatically by `spine-writeback.sh` Stop hook during the active session — `touched:` reflects the whole dirty working tree, not per-session deltas; verify real mutations via `git diff` at `/done`)_

- session 1 @ 2026-05-28 22:50 — touched: FIXES.md docs/PROJECT_PLAN.md
- `/prep` pass (2026-05-28): stub (56 lines) elaborated into a fully-detailed Session 1 entry. Consumer test (mechanical OR instruction = real) + single-session shape decided. Cross-section notes carried forward from audit-01 (PF1 methodology — load-bearing) + audit-02 (F2/F3 — don't re-find). No `chapters/`/`skills/core/`/code/template edits; writes confined to this file + a minimal `docs/PROGRESS.md` pointer refresh. Pre-flight rule 1 now satisfied for audit-03.
- **Session 1 done (2026-05-28, baseline commit `719e27c`).** 41 fields verified; **37 real (12 mechanical, 25 instruction), 4 decorative.** Bidirectional reconciliation clean (41↔41). Decorative: Session shape (G1, =A2.4) + **new cluster** — 3 `Prep*` Planning fields (`procedure.md`/`prep.md` hardcode 5-7 / 5-12 / 100 instead of reading the profile). Findings F1 (G1, =A2.4 blocking), F2 (3 `Prep*`, NEW blocking → A2.5), F3 (A2.3 stale — D1 wired at `11-overview:34`), F4 (19g attribution drift, sampled). Exhaustive `19g` per-attribution check for the 21 soft instruction fields (all except 0A/0B/Q4/D1) → Session 2. **PF1 paid off repeatedly:** caught section-prose vs disk (41 confirmed) AND multiple of my own mid-session fabrications (wrong field names, non-existent chapters, `grep --include` no-ops under zsh, invented citations) — all corrected by reading actual files; only disk-grounded claims written. **Read-only compliance:** mutations confined to this file + `FIXES.md` (verify at `/done` via `git diff 719e27c`). Pointer advance to `audit-04-skill-triggers` deferred to `/done`.
- session 1 @ 2026-05-29 14:12 — touched: benchmarks/sessions/
- session 1 @ 2026-05-29 14:24 — touched: FIXES.md benchmarks/sessions/
- session 1 @ 2026-05-29 14:32 — touched: CHANGELOG.md CLAUDE.md FIXES.md README.md chapters/personalization/19g-field-effects.md install.sh skills/core/op-onboard/profile-template.md skills/core/op-welcome/SKILL.md
