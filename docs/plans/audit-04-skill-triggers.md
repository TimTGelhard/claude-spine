# Section: audit-04-skill-triggers

> Section 4 of the audit pass. See `docs/PROJECT_PLAN.md` for the full master plan.
> **Audit phase: WRITE FINDINGS ONLY** (proposed description revisions are *text in the Findings table* — no SKILL.md edits). Do not edit `chapters/`, `skills/core/`, `tests/skill-triggers/`, code, or templates in this section. Blocking findings flow to `FIXES.md` for apply sessions later.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints — interleaving audit + apply breaks coherence across sections.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — the four conditions every audit session must satisfy (this section's `/prep` pass, completed 2026-05-29, satisfies condition 1).
> Depends on Section 1 (`audit-01-architecture`, done) for the INDEX/router-shape accuracy baseline.

## Section goal

Audit the **op-\* skill triggering surface** — the `description:` frontmatter field, which is the only thing Claude matches against to decide whether to load a skill ([`13b`](../../chapters/persistence/13b-trigger-descriptions.md)). For every op-\* skill, answer: does the description fire when it should, stay silent when it shouldn't, and still match the skill's current body? Surface three failure classes — **vague/rubric-incomplete descriptions**, **harmful overlap between siblings** (two skills competing on one phrase with no disambiguation), and **description↔body drift** (description promises trigger Y; body addresses Z). Output is proposed revisions in the Findings table + a cost-gated benchmark re-run recommendation. **No SKILL.md edits** — those are an apply session.

Why this matters now: audit-02's LC1 reframe (`FIXES.md` A1) concluded the spine's headline value-add is not token savings but **routing accuracy** — i.e. correct skill triggering. That is exactly this surface. Audit-04 audits the load-bearing claim the token-cost reframe leans on.

## Done criteria

- [x] **All 23 op-\* `description:` fields extracted** from the repo's `skills/core/op-*/SKILL.md` (count re-derived from disk = 23 — the stub's "22" confirmed stale; Section 0's `op-approach` is the 23rd). Recorded in Table A with rubric verdict + ambient + eval-set columns. _(Verbatim text not recopied — points to each `SKILL.md:3` per token-discipline; rationale in Findings preamble.)_
- [x] **Each description scored against the 13b rubric** (a what-it-does / b triggers / c NOT-for-disambiguation). The 3 ambient skills (op-spine-active, op-welcome, op-curate-nudge) scored on *condition accuracy*. _See Table A._
- [x] **Overlap matrix built** — Table B: 7 harmful + 6 benign across all 5 seeded clusters + 2 found beyond, each with colliding phrase + boundary.
- [x] **Drift pairs identified** — body-confirmed (all 23 bodies opened, PF1). F4 (curate-nudge condition gap) material; F10 (spine-active path-undercount) minor; F7 (curate over-covers) inverse.
- [x] **Benchmark history consulted** — 18-skill coverage (5 uncovered named), `claude -p` confound, last run 2026-05-27; material-change git-verified (only 3/18 changed since) → re-run recommendation = NO-SPEND with confound caveat.
- [x] **Proposed description revisions written into the Findings table** (clause-level; no SKILL.md edits).
- [x] **Findings logged; blocking entries to `FIXES.md`** — new cluster **A15** (F1 blocking + F2–F9 drift cluster). A13 not extended (trigger-description accuracy is a different class than A13's doc-anchor/count drift).
- [ ] PROGRESS.md advanced to `audit-05-self-discipline` at `/done`.

## Out of scope (do not drift here)

- **SKILL.md edits.** Proposed revisions are *text in the Findings table*. Editing the frontmatter is the apply session — sequenced after the full audit phase.
- **Running or editing the trigger benchmark.** Cost-authorized separately (see § open questions — default this session is no-spend). Harness *methodology* fixes (the confound) → audit-06.
- **Architecture / router-shape audit** (Section 1, done). But if the description↔body check reveals a router that's drifted into carrying content (anti-drift rule 6), capture the *finding* here and flag the *rule-violation framing* for audit-05 in Cross-section notes — don't re-audit router shape.
- **Token-cost audit** (Section 2, done). "Trigger overlap = context bloat" ([`13d`](../../chapters/persistence/13d-skill-anti-patterns.md) L13) is the *why overlap matters*, noted — not re-measured.
- **Personalization field→consumer** (Section 3, done). Audit-03 confirmed no profile field's sole consumer is a SKILL.md description — nothing to preserve here.
- **Self-discipline sweep** (Section 5) and **test/docs audit** (Section 6) — log findings that touch them in Cross-section notes; don't bundle.

If a finding touches another section's surface, capture it in "Cross-section notes" below and move on. Do not bundle.

## Files to read for project understanding (cold-start orientation)

Read in this order at session start. Stop after this list — pull additional files (individual SKILL.md bodies, eval-set JSON) on-demand during the build steps, not as part of the orientation budget.

1. `docs/PROJECT_PLAN.md` — § Constraints (audit-phase boundary) + § Audit-phase pre-flight protocol (the four conditions; heartbeat caveat: `touched:` reflects the dirty working tree, not per-turn deltas).
2. `CLAUDE.md` — skill discipline: anti-drift **rule 6** ("routing skills stay router-shaped"), the **23 op-\* skills** count claim, and load-bearing claim #1 (trigger overlap is the token cost 13d warns about).
3. [`chapters/persistence/13b-trigger-descriptions.md`](../../chapters/persistence/13b-trigger-descriptions.md) — **the audit's measuring stick.** The rubric: what-it-does + explicit trigger keywords + what-it's-NOT-for. "Test it in isolation: would *you* know when to fire it?"
4. [`chapters/persistence/13d-skill-anti-patterns.md`](../../chapters/persistence/13d-skill-anti-patterns.md) — trigger anti-patterns. **L13 is load-bearing:** "Trigger overlap is what causes bloat — five skills firing on every prompt costs more than fifty firing on the right one." Also: vague descriptions, skill-vs-CLAUDE.md-vs-hook boundaries, graveyard audit.
5. [`chapters/persistence/13a-skill-anatomy.md`](../../chapters/persistence/13a-skill-anatomy.md) + [`13c-skill-design-patterns.md`](../../chapters/persistence/13c-skill-design-patterns.md) — for the description↔body drift check (does the body match the pattern the description implies?).
6. `tests/skill-triggers/README.md` — what the benchmark measures. **Read § "Caveats and known biases" closely** — the `claude -p` routing-skill confound (0–20% TP is an artifact; **FP is the only reliable signal**), the 18-skill scope, re-run triggers, cost table.
7. `tests/skill-triggers/results/REPORT.md` + `tests/skill-triggers/results/needs-tightening.md` — prior run output (2026-05-27, 18 skills, 0–20% TP / ~0% FP). The prior logged tightening targets — confirm/update against *current* descriptions (PF1: don't trust the 2026-05-27 flags as current-state).
8. `skills/core/op-*/SKILL.md` — the 23 repo `description:` fields (source of truth) + bodies for the drift check. Opened on-demand during extraction. **Note:** `op-approach` is in the repo but NOT installed in this session (absent from `available_skills`) — a live instance of audit-02 F1 staleness; audit the repo's 23, not the installed 22 or benchmarked 18.
9. `FIXES.md` — § A13 (drift cluster, possible home for pure-drift trigger findings) + the A-cluster numbering (open a new A## for blocking trigger work) + A12 (`/profile verify` — adjacent "mechanize-the-audit" idea; trigger-coverage has an analogous unautomated gap).
10. `docs/plans/audit-01-architecture.md` § Findings + § Cross-section notes — INDEX/router-shape baseline (Section 4 depends on it) + the PF1 partial-overstatement methodology.
11. `docs/plans/audit-02-token-cost.md` § Findings + § Cross-section notes — F1 spine staleness (benchmark ran against the installed set) + the A1 reframe (routing accuracy = the spine's headline value-add = what this section audits).
12. This file.

## Cross-section notes carried forward from audit-01 + audit-02 + audit-03

Per the pre-flight protocol rule 4 (cross-section notes propagate manually), the following apply here:

- **[LOAD-BEARING] PF1 partial-overstatement methodology (audit-01).** Treat every description's self-claim AND every `needs-tightening.md` annotation as suspect until checked against disk. A description claiming trigger Y is not proof the body addresses Y — open the body. The benchmark's "tighten" flags are 2026-05-27 artifacts; re-derive against current descriptions.
- **[LOAD-BEARING] Spine staleness (audit-02 F1).** The 2026-05-27 benchmark ran against the *installed* skill set; `op-approach` is repo-only (and still absent from this session's `available_skills`). Audit-04 audits the **repo's 23 SKILL.md descriptions** — the source of truth. The installed set (22) and the benchmarked set (18) are both stale subsets; do not treat REPORT.md rows as current-state evidence.
- **[LOAD-BEARING] Routing accuracy IS the spine's headline value-add (audit-02 A1 reframe).** LC1 showed the spine costs +75.9% input tokens; the reframe is "value = bounded per-load cost + *routing accuracy*." Routing accuracy = correct skill triggering = this section. Weight findings accordingly — a misrouting description undercuts the spine's central post-LC1 claim.
- **Nothing carried from audit-03 (field→description).** Audit-03 confirmed no profile field's sole consumer is a SKILL.md description. The only item it handed audit-04 is the general "do description bytes earn their keep?" question — which is this whole section.
- **Heartbeat caveat (pre-flight rule 3 / audit-05 PF2).** Verify mutations via `git diff` against the session-start commit at `/done`, NOT Session log `touched:` lines.
- **Coherence caveat — concurrent `/explain` work.** The working tree has uncommitted concurrent edits to `skills/core/op-welcome/SKILL.md` and `skills/core/op-onboard/*` (+ untracked `global/commands/explain.md`). They will appear in every heartbeat but are NOT audit-04 mutations. **More importantly:** if `op-welcome`'s or `op-onboard`'s `description:` frontmatter changed in that work, audit-04's finding for those two skills is point-in-time — re-confirm once `/explain` settles. Same class as audit-03's 42nd-field caveat.

## Cross-section notes (this section's own — populated as Session 1 runs)

- **For audit-05 (self-discipline).** Anti-drift rule 6 ("routing skills stay router-shaped") is a `CLAUDE.md` rule framed for SKILL.md *bodies*. **Confirmed instance — F7:** `op-curate`'s *description* (not body) carries the apply/reject procedure; since the description field is the every-session-classifier surface, audit-05 should consider whether "router shape" extends to description length. **Methodology gap — F2/F3:** `op-persistence` + `op-signaling` were already trigger-tightened once (commit 5b0c1ed) yet their *inter-skill* overlaps survived — single-skill tightening doesn't catch cross-skill collisions; the spine lacks an overlap-regression check.
- **For audit-06 (tests + docs).** (a) The 5-skill eval-set gap (`op-approach`, `op-curate-nudge`, `op-prepare`, `op-spine-active`, `op-welcome` — confirmed from disk: `eval-sets/` holds 18 JSON) — author eval-sets before any meaningful re-run. (b) The `claude -p` router-firing confound makes TP unmeasurable for routers as built; needs a multi-turn / interactive-simulation methodology fix. (c) **Material-change finding (git-verified):** only 3 of 18 benchmarked descriptions changed since 2026-05-27 (op-onboard, op-persistence, op-signaling) → a naive 23-skill re-run mostly reproduces known nulls; scope any re-run to FP-regression on those 3 + the changed-since-run 5. (d) A `/trigger verify`-style static check (analog to A12's `/profile verify`) could mechanize "every description scores ≥X on 13b + no two share a trigger phrase without a documented boundary" — would auto-catch the F1/F2/F3 overlap class between audits.
- **For A1 (token-cost reframe).** This section *confirms* routing accuracy is the load-bearing post-LC1 value-add — and found it currently has measurable defects (1 blocking + 8 drift, A15). The A1 README/landing reframe should be honest that routing accuracy is the *goal*; A15 is the gap-closing work that makes the claim true.
- **Coherence (count-claim ripple).** `/explain` (75f32e3) added the 10th slash command; `op-welcome`'s body block now reads "10 slash commands." Whether every count-claim surface got the 9→10 sweep (anti-drift rule 11) is an audit-01/06 docs concern, not an audit-04 trigger finding — flagged here so audit-06's count sweep doesn't miss the `/explain` ripple.

## Section-level open questions

- **Coverage scope.** ✓ Resolved at `/prep` (2026-05-29): **all 23**, not just the 18 with eval-sets. The audit is description-quality, not benchmark-bound; the 5 eval-set-less skills are the highest-risk-of-being-unaudited. The 5-skill eval gap is itself a finding (→ audit-06).
- **Benchmark re-run (cost gate).** ✓ Default resolved at `/prep`: **static-only, no spend this session.** The stub's Out-of-scope + the benchmark README both class running it as separately-authorized; and the `claude -p` confound means a naive re-run reproduces the 0–20% artifact. Documented as a branch at Session 1 step 5 (mirrors audit-02's Path A/B) — if the user authorizes a re-run at execution time (~$5–10 Sonnet / $20–40 Opus for 23 skills), it runs; otherwise audit-04 produces a re-run *recommendation* only.
- **Harmful-overlap test (proposed — refine before the session runs if wrong).** The audit-04 analog of audit-03's consumer test. Two skills **harmfully overlap** if a single realistic user phrase matches both descriptions AND neither disambiguates which should fire (so Claude fires both — wasted load — or picks wrong). Overlap is **benign** if (a) the descriptions explicitly carve the boundary (e.g. `op-prepare` "routes to planning chapters 05h/05i/05j" vs `op-workflow` "routes to the 7-stage workflow 05/06"), or (b) one party is an ambient auto-fire skill (`op-spine-active` / `op-welcome` / `op-curate-nudge`) whose session-start condition can't collide with a phrase. Recorded per finding so the table shows harmful vs benign.
- **Session shape.** ✓ Resolved at `/prep`: **one session**, with a documented clean split — extraction + rubric + overlap matrix + drift = a natural Session-1 close; if drafting proposed revisions for every flagged skill pushes the entry past the 100-line rule, the per-skill revision drafting carves to Session 2. Matches audit-01/02/03 (all single-session).

---

## Session 1 — Trigger-accuracy review

**Status**: `done` (2026-05-29) — 23 descriptions scored (Table A), overlap matrix built (Table B: 7 harmful / 6 benign, all 5 seeded clusters + 2 found beyond), drift body-confirmed, re-run recommendation = no-spend. **11 findings: 1 blocking (F1 op-workflow↔op-prepare planning misroute), 8 drift, 2 polish → `FIXES.md` A15.** No SKILL.md/chapter/benchmark/code edits (verify via `git diff 75f32e3` at `/done`). PROGRESS pointer advance → audit-05 deferred to `/done`.

**Goal**: Produce a triaged Findings table that, for all 23 op-\* skills, records a 13b-rubric verdict per description, a harmful/benign overlap classification per colliding sibling pair, and any description↔body drift — each with `file:line` or colliding-phrase evidence. Plus a cost-gated benchmark re-run recommendation. Proposed revisions are text only; no code or content edits.

**Files to read** (orient list — exact cold-start budget): the 12-item list under "Files to read for project understanding" above. Individual SKILL.md bodies + `eval-sets/*.json` are opened on-demand during steps 1–5.

**Files to write/edit** (scope — anything else is out of bounds without explicit pause):

- This section file's "Findings" table + Session log + the "Cross-section notes (this section's own)" block above. (Correcting the stub's stale "22" → 23 within this file is in-scope — it's the audit's own surface, not a chapters/skills edit.)
- `FIXES.md` — open a new `A##` cluster for blocking trigger-description findings (action-shaped; proposed-revision narrative stays in this file's Findings), or extend A13 if a finding is pure one-line drift of that class.
- `docs/PROGRESS.md` — advance pointer to `audit-05-self-discipline` at `/done`.

**Strictly out of scope:** any `skills/core/op-*/SKILL.md` edit (proposed revisions are Findings-table text), any chapter, `tests/skill-triggers/` (do not run or edit the benchmark), code, templates.

**Build steps**:

1. **Extract the 23 descriptions.** From each repo `skills/core/op-*/SKILL.md` frontmatter, pull `description:` verbatim into a comparison table: `skill | trigger keywords | what-it-does | what-it's-NOT-for | ambient? | has-eval-set?`. Re-derive the count from disk (`ls -d skills/core/op-*/ | wc -l` = 23); flag the stub's "22" as stale. Mark the 3 ambient auto-fire skills (`op-spine-active`, `op-welcome`, `op-curate-nudge`) and the 5 without eval-sets (`op-approach`, `op-curate-nudge`, `op-prepare`, `op-spine-active`, `op-welcome`).
2. **Score each against the 13b rubric.** Per description: does it state (a) what it does, (b) explicit trigger keywords/situations, (c) what it's NOT for / disambiguation? Record pass/gap per dimension. Score the 3 ambient skills on *condition accuracy* (does the stated firing condition match the real mechanism?), not phrase-match.
3. **Build the overlap matrix.** Walk the plausible-collision clusters (head-start groupings — verify, don't assume): **(a) planning/workflow** — `op-workflow` ↔ `op-prepare` ↔ `op-approach` ↔ `op-spine-active` (all fire on "new project"/"plan"/"scope"); **(b) bucket/curation** — `op-suggest` ↔ `op-curate` ↔ `op-curate-nudge` ↔ `op-add-skill` ↔ `op-bucket-router` (benchmark already caught the one live FP here: `op-bucket-router` fired on "/curate"); **(c) persistence/setup** — `op-persistence` ↔ `op-hooks` ↔ `op-add-skill` ("where should this rule live / from now on when X"); **(d) signaling/recovery/anti-patterns** — `op-signaling` ↔ `op-recovery` ↔ `op-anti-patterns`; **(e) meta-scope 3-way** — `op-signaling` + `op-anti-patterns` + `op-persistence` all claim the "user proposes extending the spine itself (new skill/hook/chapter)" trigger (a concrete harmful-overlap candidate). Apply the § open-questions harmful-overlap test to each pair; record the colliding phrase + verdict.
4. **Drift check (description ↔ body).** For each skill confirm the body/procedure still addresses what the description promises. Spot-check by opening the body; full-open any the rubric or overlap pass flagged. Apply PF1 — open the file, don't trust the description's self-claim. A description promising trigger Y whose body addresses Z = drift.
5. **Consult benchmark history + re-run recommendation.** Read REPORT.md + needs-tightening.md + README § Caveats. Record: 18-skill coverage (name the 5 uncovered), the `claude -p` routing-skill confound (0–20% TP is an artifact; FP is the reliable signal), last run 2026-05-27. Determine whether descriptions changed materially since (disk/git compare). Produce a re-run recommendation **with the confound caveat** — a naive re-run reproduces the artifact; a meaningful TP measurement needs a harness methodology fix (→ audit-06). **Default: do NOT run the benchmark** (no-spend). *Branch:* if the user authorizes a re-run at execution time, run `tests/skill-triggers/run.sh --model <pinned>` and fold the numbers in; otherwise recommendation-only.
6. **Propose revisions + triage.** For each flagged description, write a proposed revision IN the Findings table (text only). Severities: `blocking` — a description so vague/overlapping it misroutes a core discipline, or a drift that routes the user to the wrong chapter (a direct hit on the post-LC1 "routing accuracy" claim); `drift` — minor vagueness, missing counter-example, stale body reference, benign-but-undocumented overlap; `polish` — wording. Escalate every `blocking` finding to `FIXES.md` (new `A##` cluster, or extend A13 for pure one-line drift). Keep FIXES action-shaped.
7. **Log findings + cross-section notes.** Append the Findings table; populate this section's Cross-section notes (audit-05 router-shape framing; audit-06 eval-gap + harness confound). Verify read-only compliance via `git diff` at `/done`.

**Verify**:

- Extraction (step 1) covers all 23 repo SKILL.md descriptions — count re-derived from disk (not trusted from the stub's "22" or CLAUDE.md's claim). The 5 eval-set-less skills + 3 ambient skills named explicitly.
- Every description has a recorded rubric verdict (what-it-does / triggers / not-for) — one row per skill; count matches 23.
- Overlap matrix produced; every **harmful** pair names the colliding phrase + why the descriptions don't disambiguate (not "they seem similar"). **Benign-layering** pairs note the disambiguating boundary that makes them benign.
- Drift findings spot-verified by opening the body (PF1) — Findings notes which were body-confirmed vs which trusted the description's self-claim (and flags the latter).
- Benchmark history consulted: the 18-vs-23 coverage gap, the `claude -p` confound, and the material-change-since-2026-05-27 determination all recorded; the re-run recommendation states cost AND the confound caveat (not a naive "re-run it").
- **No SKILL.md / chapter / benchmark / code / template edits** — proposed revisions are Findings-table text only. Verified via `git diff` against the session-start commit at `/done` (heartbeat caveat: `touched:` includes the dirty working tree, incl. concurrent `/explain` edits — not proof of audit mutation).
- `FIXES.md` after the session is queue-shaped: discrete action items; proposed-revision narrative stays in this file's Findings.

**Output**:

- Commit message hint: `docs(audit): section 4 — skill-trigger accuracy findings`
- Update at `/done`: this section file (Findings filled, status `done`), `docs/PROGRESS.md` (pointer → `audit-05-self-discipline`, refresh next-session reading list), `FIXES.md` (new `A##` cluster, or A13 extension if pure drift).

---

## Findings

**Session 1 — 2026-05-29. Session-start commit `75f32e3`.** All 23 repo `skills/core/op-*/SKILL.md` read in full (descriptions **and** bodies) — the drift check (step 4) is **body-confirmed per PF1**, not description-trusted. Verbatim descriptions are not recopied here (they live at each `SKILL.md:3`; duplicating 23 paragraphs would violate the spine's own token-efficiency discipline) — this records the **rubric verdict + evidence pointers**, which is the audit artifact.

**Inventory (disk-derived).** 23 op-* skills (✓ the stub's "22" is stale — Section 0's `op-approach` is the 23rd, repo-only / absent from this session's `available_skills`: a live audit-02 F1 staleness instance). **3 ambient auto-fire:** `op-spine-active`, `op-welcome`, `op-curate-nudge`. **5 without eval-sets** (`eval-sets/` holds 18 JSON): `op-approach`, `op-curate-nudge`, `op-prepare`, `op-spine-active`, `op-welcome` — exactly the plan's claim. **`/explain` coherence caveat RESOLVED:** the concurrent work committed at `75f32e3` (= session-start HEAD), touched `op-welcome/SKILL.md` + `op-onboard/profile-template.md`, working tree clean under `skills/core/` → the op-welcome/op-onboard descriptions audited here are the settled state, not point-in-time.

### Table A — 13b rubric scorecard (all 23)

Dims: **(a)** what it does · **(b)** explicit trigger keywords/situations · **(c)** what-it's-NOT-for / disambiguation. ✓ pass · ◑ partial · ✗ gap · ● ambient (scored on *condition accuracy*).

| Skill | a | b | c | Amb | Eval | Verdict / finding |
|---|---|---|---|---|---|---|
| op-add-skill | ✓ | ✓ | ◑ | | ✓ | PASS — refusal-gate + "recurring not one-off"; F6 (vs op-suggest) |
| op-anti-patterns | ✓ | ✓ | ✗ | | ✓ | gap-(c); F3 (meta-scope vs op-signaling) |
| op-approach | ✓ | ✓ | ✓ | | ✗ | PASS (model description); F9 (audit/review vs op-collab) |
| op-brownfield | ✓ | ✓ | ◑ | | ✓ | PASS — implicit boundary; benign vs op-collab |
| op-bucket-router | ✓ | ✓ | ✓ | | ✓ | PASS — "fallback / never invents"; F5 (/curate FP) |
| op-collaboration-modes | ✓ | ✓ | ✗ | | ✓ | gap-(c); F9 (vs op-approach) |
| op-curate | ✓ | ✓ | ✓ | | ✓ | PASS on content but **over-long** → F7 |
| op-curate-nudge | ✓ | ✓ | — | ● | ✗ | **F4 — desc omits the bucket-loop gate** (condition-accuracy drift) |
| op-foundations | ✓ | ✓ | ✗ | | ✓ | gap-(c); F8 (drift/halluc vs op-recovery) |
| op-hooks | ✓ | ✓ | ◑ | | ✓ | F2 — claims the "where does this live" decision (vs op-persistence) |
| op-onboard | ✓ | ✓ | ✓ | | ✓ | PASS (defers first-run to op-welcome); desc changed post-benchmark |
| op-persistence | ✓ | ✓ | ✓ | | ✓ | PASS (code-level NOT-for); F2 (vs op-hooks); changed post-benchmark |
| op-prepare | ✓ | ✓ | ◑ | | ✗ | F1 (vs op-workflow) — boundary is chapter-citation only |
| op-prompting | ✓ | ✓ | ✗ | | ✓ | gap-(c), low-collision; F11 |
| op-recovery | ✓ | ✓ | ✗ | | ✓ | gap-(c); F8 (vs op-foundations) |
| op-signaling | ✓ | ✓ | ✓ | | ✓ | PASS (code-level NOT-for); F3 (meta-scope vs op-anti-patterns); changed post-benchmark |
| op-spine-active | ✓ | ✓ | — | ● | ✗ | PASS — clean; F10 (undercounts detection paths) polish |
| op-subagents | ✓ | ✓ | ◑ | | ✓ | PASS — benign vs op-tools (decision vs mechanics) |
| op-suggest | ✓ | ✓ | ✓ | | ✓ | PASS (model "never fires on…"); F6 (vs op-add-skill) |
| op-tools | ✓ | ✓ | ◑ | | ✓ | PASS — benign vs op-subagents |
| op-visuals | ✓ | ✓ | ✗ | | ✓ | gap-(c), distinctive domain → low-risk; F11 |
| op-welcome | ✓ | ✓ | ✓ | ● | ✗ | PASS — clean condition (defers interview to op-onboard); changed post-benchmark |
| op-workflow | ✓ | ✓ | ◑ | | ✓ | **F1 (vs op-prepare) — blocking**; boundary is chapter-citation only |

**Pattern.** Every description nails **(a)** and **(b)** (23/23 each). The systematic weakness is **(c) disambiguation**: 8 ✓, 7 ◑, 6 ✗ (+ 3 ambient scored on condition accuracy: 2 clean, 1 drift). **Every harmful overlap below traces to a missing or phrase-invisible (c).** Headline: the trigger surface fires *when it should* but is uneven on *yielding to the right sibling*.

### Table B — Overlap matrix (5 seeded clusters + 2 found beyond)

Test (§ open-questions): one realistic phrase matches both AND neither disambiguates ⇒ **harmful**; explicit boundary OR an ambient party ⇒ **benign**.

| Pair (cluster) | Colliding phrase | Verdict | Why |
|---|---|---|---|
| op-workflow ↔ op-prepare (a) | "starting a new project / scope this out / plan the build sequence" | **HARMFUL** → F1 | only a chapter-citation boundary (05/06 vs 05h–j), invisible to phrase-match; planning = core discipline |
| op-persistence ↔ op-hooks (c) | "from now on when X / where should this rule live" | **HARMFUL** → F2 | both descriptions claim the decision; only the *bodies* cross-ref |
| op-signaling ↔ op-anti-patterns (e) | "I want to add a new skill/hook/chapter to my setup" | **HARMFUL / layered-by-design** → F3 | both → reviewer mode (same outcome, no misroute) but undocumented; fix = *document the layering*, not merge |
| op-suggest ↔ op-add-skill (b) | "remember this / save this for next time" | **HARMFUL (mild)** → F6 | capture-to-queue vs write-skill-now; not phrase-visible |
| op-bucket-router ↔ op-curate (b) | "/curate" | **HARMFUL (mild)** → F5 | the one benchmark-confirmed FP; fallback framing should yield but word-proximity beat it |
| op-foundations ↔ op-recovery (d, found) | "Claude is drifting / hallucinating" | **HARMFUL (mild)** → F8 | understand-failure-mode vs act-now playbook; not phrase-visible |
| op-collaboration-modes ↔ op-approach (a, found) | "audit X / review X" | **HARMFUL (mild)** → F9 | engagement-mode vs work-shape; op-approach mitigates by scale ("skip one-line") |
| op-prepare ↔ op-approach (a) | "audit/refactor/migrate this big thing" | **BENIGN** | both state it: op-approach "ALWAYS fires before op-prepare" |
| op-spine-active ↔ prepare/workflow/approach (a) | — | **BENIGN** | ambient: session-start file-detection can't collide with a phrase |
| op-curate-nudge ↔ op-curate (b) | — | **BENIGN** | ambient; nudge suggests, /curate runs |
| op-brownfield ↔ op-collaboration-modes | "explain this unfamiliar code" | **BENIGN** | both bodies cross-ref (discovery discipline vs explainer mode) |
| op-subagents ↔ op-tools | "Agent / Explore" | **BENIGN** | delegation-decision vs tool-mechanics; carved in both bodies (15e) |
| op-add-skill ↔ op-curate ↔ op-bucket-router | "the bucket" | **BENIGN** | distinct verbs: write-new / process-queue / route-to-existing |

### Step 4 — drift check (description ↔ body), body-confirmed

All 23 bodies opened (PF1). **Material drift: F4** op-curate-nudge (firing condition incomplete — omits the dominant bucket-loop gate the body enforces). **Minor: F10** op-spine-active (names 5 of 6 detection paths; omits the profile-field path); op-bucket-router's description is silent on the bucket-loop gate + the one allowed `Last fired` write (body-only, low impact — explicit invocation works regardless; folded into F4's class at lower severity). **Inverse of drift: F7** op-curate's description *over-covers* the body (recites the apply/reject procedure). All other 18: bodies deliver what the descriptions promise; Index tables route to exactly the chapter numbers the descriptions cite. No classic "promises Y, body does Z" drift found.

### Step 5 — benchmark history + re-run recommendation (NO-SPEND default; recommendation only)

- **Coverage:** last run 2026-05-27 (Opus 4.7 + Sonnet 4.6, `--runs 1`), **18 skills**; **5 uncovered** (op-approach, op-curate-nudge, op-prepare, op-spine-active, op-welcome — no eval-sets).
- **Confound (README § Caveats):** routers don't fire eagerly in one-shot `claude -p`, so **TP 0–20% is an artifact**; **FP (~0% across 18) is the only reliable signal.** The one real FP: `op-bucket-router` on "/curate" (→ F5).
- **Material change since 2026-05-27 (git-verified):** of the 18 benchmarked, **only 3 descriptions changed post-run** — `op-onboard` (807b877 "expanded onboard"), `op-persistence` + `op-signaling` (5b0c1ed "tighten … triggers"). The other 15 are byte-identical → their FP≈0 result still stands. (The 5 uncovered all changed/were created post-run: op-curate-nudge born 05-28 daf4196; op-approach/op-spine-active/op-welcome reworded 05-28.)
- **Recommendation — do NOT do a naive 23-skill re-run.** 15/18 reproduce known nulls (pure spend), the 5 uncovered can't run until eval-sets exist, and the confound makes any TP number an artifact. **If authorized:** the only signal-bearing scope is **FP-regression on the 3 changed-since descriptions** (op-onboard/op-persistence/op-signaling) — and even that is FP-only. A *meaningful* re-run needs (i) eval-sets for the 5 uncovered + (ii) a harness methodology fix for the router-firing confound (multi-turn / interactive simulation) — **both → audit-06.** Cost if a full naive 23-skill run is done anyway: ~$5–10 Sonnet / $20–40 Opus (README's 18-skill table ×~1.28).

### Triaged findings

Severities: **blocking** = misroutes a core discipline / wrong-chapter (direct hit on the post-LC1 routing-accuracy claim) · **drift** = phrase-invisible boundary, missing counter-example, condition gap, benign-but-undocumented overlap · **polish** = wording. Proposed revisions are the *specific clause* to add/change (text only — no SKILL.md edits this phase). Full verbatim rewrites, if the apply phase wants them, are an apply-time task; the plan's documented Session-2 split was **not needed** — extraction + rubric + overlap + drift closed in one session.

| F# | Sev | Skill(s) / loc | Finding | Proposed revision (clause) |
|---|---|---|---|---|
| F1 | **blocking** | op-workflow:3 ↔ op-prepare:3 | Both fire on "starting a new project from scratch / scope this out / plan the prep→architecture→build sequence." Only a chapter-citation (05/06 vs 05h–j) separates them — invisible to phrase-match. A user wanting to *plan* can land in op-workflow's concept chapters instead of op-prepare's planning **pass**. Misroutes the planning core discipline; direct hit on the routing-accuracy claim. (Caveat: benchmark FP≈0, but the confound means a should-both-maybe-fire TP-misroute is exactly what the harness *cannot* measure.) | op-workflow: add "For the planning **pass** that writes the plan files (brief → architecture → PROJECT_PLAN → first section), use **op-prepare**; this skill routes the 7-stage *concepts* + feature sizing." + add op-prepare to op-workflow's Sibling list (SKILL.md:48–50 omits it; op-prepare:43 already points back). |
| F2 | drift (borderline blocking) | op-persistence:3 ↔ op-hooks:3 | Both claim the "hook vs CLAUDE.md vs skill — where should this rule live / from now on when X" **decision**. Bodies cross-ref correctly (op-hooks:35, op-persistence:26) but descriptions don't carve it. NB: both were tightened once (5b0c1ed) and the *inter-skill* overlap survived — single-skill tightening doesn't catch cross-skill collisions. | op-hooks: narrow to "wiring an **automatic, scripted** behavior on an event" + append "for the hook-vs-CLAUDE.md-vs-skill **decision**, op-persistence 12a is the front door." (op-persistence already owns the decision — no change.) |
| F3 | drift | op-signaling:3 ↔ op-anti-patterns:3 | Both fire on "user proposes extending the setup (new skill/hook/agent/chapter)" and both prescribe "stay in reviewer mode before writing." Same outcome (no misroute) but undocumented double-load, no stated owner. Content is genuinely complementary: anti-patterns 18-meta = the *catalog*; signaling 11e = the proactive *reviewer-mode cadence*. (op-persistence is a benign third party — it fires on the downstream *how/where to write the trigger*, not the *should-we* review.) | **Document the layering, don't merge.** op-anti-patterns: append "(the meta-scope *review cadence* is op-signaling 11e; this routes the anti-pattern *catalog* — both intentionally fire)." |
| F4 | drift | op-curate-nudge:3 vs body:14 | Description states it fires "when the bucket has 5+ pending AND >30 days since /curate" but body **condition 0** gates the whole skill on "Bucket loop is **on**" — and bucket-loop is **default-off**. For the median user the stated condition is never truly met, yet the description reads as firing for everyone → body loads then exits (wasted load every conversation-start in a default install with a stale queue). Condition-accuracy drift (ambient rubric). | Prepend the gate: "Auto-fires once at conversation start **when the bucket loop is enabled in the profile** AND the bucket has N+ pending (N = profile threshold, default 5) AND >D days since the last `/curate` (D default 30)." |
| F5 | drift | op-bucket-router:3 (REPORT.md FP) | The single benchmark-confirmed FP: fired on "/curate" (expected no-fire). Its "fallback / core skills always win" framing *should* yield to op-curate, but curate/bucket word-proximity beat it in one-shot mode. | Append to the "Never invents…" clause: "— and never fires on the `/curate` or `/suggest` slash commands (those are op-curate / op-suggest)." (Partly a `claude -p` artifact, but the only real FP signal → worth the one-clause guard.) |
| F6 | drift | op-suggest:3 ↔ op-add-skill:3 | Collide on "remember this / save this for next time." Boundary (suggest = lightweight capture-to-queue; add-skill = write a full bucket skill now, 3+ paste-in gate) is each-skill-internal, not phrase-visible. | op-add-skill: qualify — "'save this as a **skill**' / 'I want a skill for X' (a full reusable procedure) — for a lightweight note to revisit, that's `/suggest`." (op-suggest already well-bounded.) |
| F7 | drift→polish | op-curate:3 | Longest description of the 23 (~190 words): recites the full apply/reject mechanics ("On apply: writes the bucket file, updates the matching table … appends to CHANGELOG … archive with Status: applied. On reject: …") — body content (already at SKILL.md:26–37). Description bytes hit every session-start classifier pass (audit-02 lens); 13b wants the trigger, not a procedure recap. | Trim to trigger + scope-refusal: keep `/curate` / `--review-stale` / "let's curate…" + "shows a diff before every write; one change per approval; hard-refuses outside bucket/." Let the body carry apply/reject (it already does). |
| F8 | drift (mild) | op-foundations:3 ↔ op-recovery:3 | Overlap on "Claude is drifting / hallucinating." Boundary = understand-the-failure-mode (foundations 01c) vs act-now playbook (recovery 17); not phrase-visible. Found beyond the seeded clusters. | op-foundations: append "(to **recover** an in-progress degrading session, op-recovery)." op-recovery is action-framed already. |
| F9 | drift (mild) | op-collaboration-modes:3 ↔ op-approach:3 | Overlap on "audit X / review X." Boundary = engagement *mode* vs work *shape* (multi-session); op-approach mitigates with "skip one-line edits." | op-collaboration-modes: append "(for whether a piece of work is **audit-shaped** across sessions, op-approach)." |
| F10 | polish | op-spine-active:3 vs body | Description names "four conventions … or whatever the project's CLAUDE.md declares" but the body has **6** detection paths (adds a profile-field path from /onboard --deep G2; the CLAUDE.md override is 1 of 2). Minor condition-accuracy undercount. | Add "or the profile's `Plans dir` field" to the override mention. |
| F11 | polish | op-visuals:3, op-prompting:3 (+ op-foundations standalone) | Pure rubric-(c) gaps with low collision risk (distinctive domains; siblings live in the body only). The (c)-gap skills that *also* sit in a harmful overlap are covered by F1/F3/F8/F9. | Add a one-clause NOT-for where cheap — e.g. op-visuals "NOT for image *generation* or design-tool operation"; op-prompting "NOT for deciding *what* to build — that's the workflow/planning skills." Low priority. |

**Severity totals: 1 blocking (F1), 8 drift (F2–F9), 2 polish (F10–F11).** Escalated to `FIXES.md` as new cluster **A15** (F1 headline + F2–F9 as one apply-section of SKILL.md-frontmatter edits; F10–F11 stay here).

## Session log

_(per-turn heartbeats appended automatically by `spine-writeback.sh` Stop hook during the active session — `touched:` reflects the whole dirty working tree, not per-session deltas; verify real mutations via `git diff` at `/done`)_

- session 1 @ 2026-05-29 14:39 — touched: CHANGELOG.md CLAUDE.md FIXES.md README.md chapters/personalization/19g-field-effects.md install.sh skills/core/op-onboard/profile-template.md skills/core/op-welcome/SKILL.md
- session 1 @ 2026-05-29 14:42 — touched: CHANGELOG.md CLAUDE.md FIXES.md README.md chapters/personalization/19g-field-effects.md docs/PROJECT_PLAN.md install.sh skills/core/op-onboard/profile-template.md
- `/prep` pass (2026-05-29): stub (56 lines) elaborated into a fully-detailed Session 1 entry. Coverage = all 23 (count corrected from the stub's stale "22"; Section 0 added op-approach, which is repo-only / not installed this session — live audit-02 F1 staleness). Benchmark re-run defaulted to no-spend (static-only) with a documented authorize-branch at step 5, given the `claude -p` routing-skill confound (README § Caveats) makes a naive re-run reproduce the 0–20% TP artifact. Harmful-overlap test proposed (single phrase matches both + no disambiguation = harmful; explicit boundary or ambient party = benign). Cross-section notes carried forward: audit-01 PF1 methodology (load-bearing), audit-02 F1 staleness + A1 routing-accuracy reframe (load-bearing), audit-03 "nothing for audit-04" re field→description, + a concurrent-`/explain` coherence caveat for op-welcome/op-onboard. Single-session shape with documented split. No `chapters/`/`skills/core/`/`tests/`/code/template edits; writes confined to this file (+ a PROGRESS pointer refresh at `/done`). Pre-flight rule 1 satisfied for audit-04.
- session 1 @ 2026-05-29 14:57 — touched: FIXES.md docs/PROJECT_PLAN.md benchmarks/sessions/
- Session 1 done 2026-05-29. 11 findings (1 blocking, 8 drift, 2 polish). Blocking F1 = op-workflow↔op-prepare collide on "new project / scope this out" with only a chapter-citation boundary (planning core-discipline misroute; direct hit on the audit-02 A1 routing-accuracy claim). **A15 cluster opened in `FIXES.md`** (F1 headline + F2–F9). Re-run recommendation = NO-SPEND: 15/18 benchmarked descriptions byte-identical since 2026-05-27 (git-verified) so a naive re-run reproduces known nulls; only op-onboard/op-persistence/op-signaling changed post-run; the 5 uncovered need eval-sets + the harness needs a confound fix first (→ audit-06). All 23 bodies read in full → drift body-confirmed (PF1); no classic "promises Y, body does Z" found. `/explain` caveat resolved (committed at `75f32e3` = session start; working tree clean under `skills/core/`). Read-only compliance: audit mutations confined to this file + `FIXES.md` (A15) by authorship — verify via `git diff 75f32e3` at `/done` (heartbeat `touched:` includes the whole dirty tree per pre-flight rule 3). Pointer advance → audit-05 at `/done`.
