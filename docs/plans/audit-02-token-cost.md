# Section: audit-02-token-cost

> Section 2 of the audit pass. See `docs/PROJECT_PLAN.md` for the full master plan.
> **Audit phase: WRITE FINDINGS ONLY.** Do not edit `chapters/`, `skills/core/`, code, or templates in this section. Blocking findings flow to `FIXES.md` for apply sessions later.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints — interleaving audit + apply breaks coherence across sections.
> **🛫 Before starting Session 1:** read `docs/PROJECT_PLAN.md` § Audit-phase pre-flight protocol — the four conditions every audit session must satisfy (this section's `/prep` pass, completed 2026-05-28, satisfies condition 1).

## Section goal

Audit the project's first load-bearing claim — **token efficiency is the central design constraint** (`CLAUDE.md` L34–L51) — by measuring the actual cost-shape of the spine: per-router, per-chapter, per-adjacent-file size; redundancy across files; heaviest worst-case session loads. Produce findings that say where the spine pays its keep on cost vs where it leaks. **Path A** includes the real LC1 spine-on vs spine-off benchmark numbers if the user authorizes the ~$9–$15 spend at Session 1 step 1. **Path B** produces static-analysis-only evidence and leaves LC1 unfinished in `FIXES.md`.

## Done criteria

- [x] Size distributions captured for routers (23 files), chapters (84 files), adjacent files (10 files) — counts, line totals, p50/p90/max + outlier names. Inventory derived from disk via `wc -l`, not from prose claims (see Cross-section notes § PF1 below). _See Findings preamble inventory table._
- [x] Size outliers triaged — for routers >65 lines, chapters >120 lines, adjacent files >200 lines: each named with rationale (justified by content / multi-concept / extractable payload). _5 routers >65, 7 chapters >120, 2 adjacent files >200; triage in Findings preamble + F4 (audit-01 F1 cost confirmation)._
- [x] Redundancy scan: top-5 heaviest stacks examined for cross-file content overlap. Any pair with >30% line overlap OR same procedure described in both files flagged. _F2 captures `op-onboard/SKILL.md ↔ questions-deep.md` overlap (L308-317 restates SKILL.md L94 + L96); no >30% line-overlap pairs found in op-prepare, op-onboard essentials, op-add-skill, op-curate stacks._
- [x] Top-5 heaviest worst-case session loads named (router + chapters routed + adjacent files combined) with combined line count + token-proxy estimate. _F3 — all five in green zone._
- [x] Token-per-line conversion methodology recorded — proxy ratio used (Path B), or measured ratio if LC1 ran (Path A). _Proxy: 7 tokens/line (markdown convention). **Measured cache_read delta (spine-on minus spine-off): ~42k tokens against ~8.4k lines of spine content (chapters + routers + adjacent files) ≈ ~5 tokens/line attributable to spine.** Proxy was slightly over (7 vs ~5); F3's token estimates are accordingly ~30% high (a 1172-line stack at ~5 t/l is ~5.9k tokens vs the cited 8.2k). All F3 conclusions hold — even ~5.9k is well within green zone. Exact attribution is uncertain because cache_read content includes Claude Code's own system prompt + tool descriptions, not just spine repo files._
- [x] Heavy outliers cross-checked against audit-01's F1/F2/F3 recommendations — does the F1 extraction (op-onboard inline previews → `preview.md`) materially shift the cost-shape ranking? _F4 — yes, F1 saves ~350 tokens per onboarding load; deep stack ranking unchanged but absolute cost shifts -4%._
- [x] **[Path A only]** LC1 partial-run residue audited (`.err` vs `__on__`/`__off__` pair counts per eval-set prompt); gap quantified; missing items completed; headline reduction % computed (mean ± std-dev, sample size, model, date) and cited in Findings. Does **NOT** write `benchmarks/tokens/REPORT.md` — that's A1's apply work. _F0 + F5 — partial-run residue cataloged (2.6% pair coverage at LC1 launch → full re-run triggered); LC1 ran in two passes after mid-run CLI upgrade; headline = +75.9% input tokens (n=11 paired prompts, ±110.8% per-prompt stdev, Sonnet 4.6, 2026-05-28); REPORT.md NOT written (out of scope)._
- [x] All findings logged in the Findings table below with severity (`blocking` / `drift` / `polish`). _F0 drift (reframing-required), F1 drift, F2 drift, F3 info, F4 polish, F5 drift; 0 blocking._
- [x] Blocking findings appended to `FIXES.md` under a new `A##` cluster, or A1 extended/closed if Path A's numbers satisfy A1's gate condition. _Zero blocking; A1 extended with LC1 results + reframing implications + harness preflight task; A13 extended with F2 (5th drift-class item). A1 remains "Blocking — before LC5" until reframe + REPORT.md publish lands._
- [ ] PROGRESS.md advanced to `audit-03-personalization` at `/done`. _Deferred to `/done`._

## Out of scope (do not drift here)

- **No edits to `chapters/`, `skills/core/`, code, or templates.** Audit phase = write findings only.
- **No architecture/router-shape audit.** Section 1 (`audit-01-architecture`) owns layered separation, router-shape, INDEX accuracy — done 2026-05-28. If a cost measurement reveals a shape issue audit-01 missed, capture in Cross-section notes for audit-05's self-discipline sweep; do not retro-add a finding to audit-01's table.
- **No profile-field auditing.** Section 3 (`audit-03-personalization`) owns the field → consumer map.
- **No SKILL.md description rewrites.** Section 4 (`audit-04-skill-triggers`) owns triggering accuracy. Description size is an audit-04 concern (description bytes hit every session-start classifier pass), but only as a *triggering* lens, not a cost lens.
- **No anti-pattern audit beyond token efficiency.** Section 5 (`audit-05-self-discipline`) owns the broader self-discipline sweep, including the heartbeat-hook caveat + read-deny-overreach (PF5).
- **No test-coverage or cross-reference audit.** Section 6 (`audit-06-tests-docs`).
- **No `benchmarks/tokens/REPORT.md` write.** Even Path A only CITES the headline number in Findings. The apply work to publish into REPORT.md + README + landing is A1.

If a finding touches another section's surface, capture it in "Cross-section notes" below and move on. Do not bundle.

## Files to read for project understanding (cold-start orientation)

Read in this order at session start. Stop after this list — do not pull additional files until the procedure step calls for them.

1. `CLAUDE.md` — load-bearing claim #1 (L34–L51). The bullets here ("Skills are routers, not content," "Chapters are atomic," "INDEX.md is the lightweight fallback," "bucket default-off," "heavy plugins flipped default-off," "hooks split," "subscription tune") name the discipline this audit measures.
2. `RECONSTRUCTION.md` L41–L42 — sizing stance ("sized to the concept, not a number; lean but complete"). The current authoritative phrasing post-cleanup. **Do NOT use L11 as authority** — it carries a stale "~80 atomic files (<150 lines each)" claim that audit-01 F7 logged as polish (a frozen-history forward-pointer is recommended; not yet applied).
3. `INDEX.md` — what routes where; the actual chapter list against which heavy-load shapes are computed.
4. `FIXES.md` § LC1 + A1 — LC1 (the ~$9–$15 spend gate; "Output: token-efficiency number for LC4's demo") and A1's path notes (partial-run residue cleanup, REPORT.md target, README/landing thread-through). LC1 authorization at session start gates Path A.
5. `docs/PROJECT_PLAN.md` — § Constraints (audit-phase boundary) + § Audit-phase pre-flight protocol (heartbeat caveat: `touched:` lines reflect dirty working tree, not deltas).
6. `docs/plans/audit-01-architecture.md` § Findings — F1 (op-onboard inline previews → `preview.md`, ~50 lines extractable; would drop SKILL.md from 108 → ~60) is cost-relevant. F2/F3 (TL;DR drops in op-approach/op-prepare) are smaller but worth checking against the size-distribution outputs.
7. This file.

## Cross-section notes carried forward from audit-01

Per the audit-phase pre-flight protocol rule 4 (cross-section notes propagate manually), the following items from `docs/plans/audit-01-architecture.md` § Cross-section notes apply here:

- **PF1 partial-overstatement context.** Audit-01's PF1 declared the Section-0 count-claim sweep "complete and consistent." Audit-01 found three residuals (README L14, README L135–143, RECONSTRUCTION L11). **Implication for audit-02:** any size/count statistic this audit cites must be derived from disk via direct `wc -l` / `find`, not from prose claims in README / RECONSTRUCTION / INDEX. Treat all prose counts as suspect until re-verified.
- **F1 cost data.** Audit-01 quantified `op-onboard/SKILL.md` at 108 lines with two inline preview blocks totaling ~50 lines that should extract to `preview.md`. If audit-02's heavy-load shape ranking has `op-onboard` in the top-3 (it almost certainly does — see Section-level open questions), the F1 recommendation materially shifts the post-apply cost-shape. Cite the projected post-F1 cost in Findings alongside the current cost.

## Cross-section notes (this section's own — populated as Session 1 runs)

- **For audit-06 (tests + docs) cross-reference sweep.** The broken-cross-ref pattern flagged by audit-01 F8 (chapter `14b-hook-recipes.md` L55 cites a non-existent `## Hook tuning (deep mode only)` heading in `op-onboard/SKILL.md`) recurs verbatim in `skills/core/op-onboard/questions-deep.md` L308-317 (this audit's F2). Same heading citation, same orphaned post-refactor state. Audit-06's broken-anchor sweep should scan BOTH `chapters/<topic>/**.md` AND `skills/core/op-*/*.md` (adjacent files, not only `SKILL.md`). At minimum: grep for ``[`#] [^`]*\` (heading-link citations) and verify the cited heading exists in the cited file.
- **For audit-05 (self-discipline) PF5 (read-deny overreach).** At this session's start the `**/*token*` Read AND Bash deny rule was no longer active — `docs/plans/audit-02-token-cost.md` was Read-able and `benchmarks/tokens/` was Bash-listable. The in-band write-deadlock case PF5 captured during the `/prep` pass (2026-05-28 earlier) was real at that point in time, but the deny was lifted between `/prep` and Session 1 execution. Capture both states in PF5's audit-05 framing: the rule was overreaching when active, and its lift was the right resolution; preserve the historical record so the framing isn't "PF5 was never real."
- **For audit-05 PF2 (heartbeat caveat).** Verified at this session's `/done`: actual file mutations were limited to `docs/plans/audit-02-token-cost.md` + `FIXES.md` + `docs/PROGRESS.md` (audit's scope). The Session log heartbeats reflected the whole-working-tree dirty list including pre-existing modified files from prior sessions (`docs/PROGRESS.md`, `docs/PROJECT_PLAN.md`, `docs/plans/audit-01-architecture.md`); they are NOT a per-session delta. Pre-flight rule 3 worked as designed.
- **For A1 apply (publish LC1 numbers).** When the apply pass writes `benchmarks/tokens/REPORT.md`: (1) cite the spine state at run time — "22 of 23 op-* installed at run time; op-approach (Section 0, 80 lines) was repo-only, not in benchmark spine-on state" (see F1 below); (2) cite the measured tokens-per-line ratio from this LC1 run as the calibrated value for any subsequent proxy estimation; (3) per the section file Done-criteria L20, REPORT.md is NOT in this audit's write scope — only the headline is cited in F0 below.

## Section-level open questions

- **LC1 authorization decision.** ✓ Resolved 2026-05-28 — user authorized Path A; LC1 ran in two passes (initial + ON-only re-run after mid-run CLI upgrade); ~$6.48 total spend.
- **Token-per-line proxy ratio.** ✓ Resolved 2026-05-28 — measured cache_read delta attributable to spine: ~42k tokens against ~8.4k lines of spine repo content (chapters + routers + adjacent files) ≈ ~5 tokens/line. Proxy of 7 was high by ~40%; F3's token estimates were ~30% over. All F3 conclusions hold (even ~30% lower, the heaviest stack is well within green zone). Exact attribution uncertain because cache_read includes Claude Code's own system prompt + tool descriptions in addition to spine repo files.

---

## Session 1 — Token-cost measurement (sizes, redundancy, heavy-load shapes, LC1 if authorized)

**Status**: `done` (2026-05-28) — Path A executed in two passes (initial + ON-only re-run after mid-run claude CLI upgrade); 6 findings (0 blocking, 5 drift, 1 polish); F0 headline `+75.9%` input tokens on paired n=11 contradicts naive "spine saves tokens" framing — reframe is A1 apply work. Total LC1 spend ~$6.48. PROGRESS pointer advance deferred to `/done`.

**Goal**: Produce a triaged findings table naming every cost-shape outlier, redundancy hotspot, and heavy-load stack — with numeric evidence (line counts always; token counts under Path A if LC1 runs). No code or content edits.

**Files to read** (orient list — exact cold-start budget):

- `CLAUDE.md`
- `RECONSTRUCTION.md` (L41–L42 authoritative sizing stance; L11 known-stale per audit-01 F7)
- `INDEX.md`
- `FIXES.md` (LC1 + A1)
- `docs/PROJECT_PLAN.md`
- `docs/plans/audit-01-architecture.md` § Findings (F1/F2/F3 cost-relevant)
- This section file.

Additional files opened during the procedure (steps 1–8 below) are read on-demand, not as part of the orientation budget. Specifically: per-router `SKILL.md` opens during redundancy scan (step 4); per-chapter `*.md` opens during heavy-load shape analysis (step 5); `benchmarks/tokens/` paths if Path A runs (step 6) — but Read on `**/*token*` is currently denied at the harness level (audit-05 PF5; this `/prep` confirmed the deny applies to Read AND Bash, not just Read-glob as PF5 originally framed), so Path A may also need a permission lift for `benchmarks/tokens/` — decide at step 6.

**Files to write/edit** (scope — anything else is out of bounds without explicit pause):

- This section file's "Findings" table + Session log heartbeats + Cross-section notes block above.
- `FIXES.md` — append a new `A##` cluster entry per blocking finding, or extend/close A1 if Path A's numbers satisfy A1's gate condition.
- `docs/PROGRESS.md` — advance pointer at `/done`.

**Strictly out of scope:** `benchmarks/tokens/REPORT.md`, `README.md`, `landing/index.html`, any chapter or skill file, any code or template file. The apply work to publish LC1 numbers (A1) is a separate session.

**Build steps**:

1. **LC1 authorization gate.** Ask the user: *"Authorize the LC1 spine-on vs spine-off benchmark run (~$9–$15 of Sonnet 4.6, plus ~30–60 min runtime)? Path A includes the measured numbers; Path B produces static-analysis-only findings and leaves LC1 unfinished in FIXES."* Capture the decision before continuing. Steps 2–5 are common to both paths; step 6 is Path A only; step 7 is Path B fallback only.

2. **Inventory (static).** Capture actual sizes:
   ```bash
   wc -l skills/core/op-*/SKILL.md | sort -n
   find chapters -name "*.md" -type f | xargs wc -l | sort -n
   find skills/core -type f -name '*.md' -not -name 'SKILL.md' | xargs wc -l | sort -n
   ls global/commands/ ; ls global/hooks/
   ```
   Record per category: count, total lines, p50, p90, max, top-5 outlier names. Note the p90→max gap — large gap signals one heavy file dragging the tail (cost-asymmetric); small gap signals tail is broadly heavy (cost-symmetric). Audit-01 inventory snapshot (commit `f08b258`, 2026-05-28): 23 routers (range 32–108, total 1242), 84 chapters (range 33–155, total 5735), 10 adjacent files (range 49–317, total 1386). Re-verify against disk; do not trust this prose.

3. **Size-distribution audit.** For each category, triage outliers under the cost-lens (not the shape-lens — audit-01 already cleared shape):
   - **Routers >65 lines** (audit-01 inventory: op-bucket-router 70, op-suggest 71, op-approach 80, op-spine-active 92, op-onboard 108). For each: is the size a workflow-encoder carve-out (legitimate per `RECONSTRUCTION` L41), an inline payload that should extract (e.g., audit-01 F1 op-onboard previews), or genuinely necessary routing logic?
   - **Chapters >120 lines** (audit-01 inventory top-8: 12b/155, 06/134, 10/131, 17b/124, 05k/123, 19f/122, 11-overview/121, 05j/119). Audit-01 spot-checked these and confirmed one-concept-shaped — re-confirm under the cost-lens: does the size pay its keep on the concept being taught, or is the chapter heavy because it's *thoroughly* teaching one concept (acceptable) vs *expansively* teaching one (trim candidate)?
   - **Adjacent files >200 lines** (today: `op-prepare/procedure.md` at 203, `op-onboard/questions-deep.md` at 317). Same question: size paying its keep, or two carve-outs in one file?

4. **Redundancy scan.** For the top-5 heaviest stacks (combined router + adjacent total — derive ranking from step 2's data), spot-check content overlap:
   - Open the router + each adjacent file. Look for: same procedure described twice; same rule restated; same anti-pattern named in both router and adjacent file.
   - Cross-check router → chapter: does the router cite the chapter and let the chapter teach? Or does the router teach AND cite (duplication)?
   - **Sample pairs to inspect** (high overlap risk based on adjacent-file counts): `op-onboard/SKILL.md` ↔ `questions-essential.md` ↔ `questions-deep.md`; `op-prepare/SKILL.md` ↔ `procedure.md`; `op-onboard/SKILL.md` ↔ `hook-tune.md` (audit-01 F8 hinted at cross-ref drift here — confirm under cost-lens).
   - Flag any pair with >30% line overlap OR any pattern duplicated in both files.

5. **Heavy-load shape analysis.** For each major routing path, compute the worst-case session load (router + chapter(s) it routes to + adjacent files it loads). Indicative numbers from step 2's data:
   - `op-onboard` essentials: SKILL (108) + questions-essential (186) + profile-template (113) + subscription-tune (60) + handoff (109) = **576 lines**.
   - `op-onboard --deep`: essentials + questions-deep (317) + hook-tune (149) + extras-merge (130) = **1172 lines**.
   - `op-prepare`: SKILL (54) + procedure (203) + chapters 05h+05i+05j (89+105+119=313) + SECTION_PLAN template (100) = **~670 lines**.
   - `op-spine-active`: SKILL (92) + chapter 05j (119) + project plan + section file + PROGRESS (project-dependent; capture spine-side bound only).
   - `op-anti-patterns`: SKILL (44) + chapter 18-meta-patterns (54) + topic chapter (~50–75) = **~150–175 lines**.
   Rank top-5. For each: what fraction of Sonnet 4.6's 200k context does it consume at proxy ratio? At Pro-class p90 input usage (typical session ~50–80k base), does the load push into yellow-zone per chapter `02-context-budget.md`?

6. **[Path A only] LC1 partial-run residue audit + completion.**
   - Inspect `benchmarks/tokens/results/`: count `__on__` / `__off__` pair successes vs `.err` failures per eval-set prompt. (Note: Read on `**/*token*` is denied at the harness level — see audit-05 PF5; expect to need a permission lift for `benchmarks/tokens/**` at this step. Surface to user; do not work around silently.)
   - If pairs exist for ≥80% of eval-set items: skip new runs; aggregate from existing data.
   - Else: complete missing eval-set items via the harness (`benchmarks/tokens/` — verify runner script name with `ls benchmarks/tokens/` after permission lift). Spend: ~$9–$15 of Sonnet 4.6. Time: ~30–60 min.
   - Aggregate: compute mean input-token reduction (spine-on vs spine-off) across the eval set, with std-dev + sample size.
   - Record measured tokens-per-line ratio so Path B's proxy estimates (in any future audit-02 re-runs) can be retroactively calibrated.

7. **[Path B fallback only — skip if Path A ran] Proxy estimation.** Apply ~7 tokens/line to step 2's line counts. Compute approximate token cost per category + per heaviest stack. **Explicitly label as proxy estimate** in Findings. Note the calibration uncertainty: Path B cannot answer "does the spine actually save tokens vs spine-off?" — only "how much would loading X cost in tokens, given a proxy ratio." A1 stays open in FIXES.

8. **Log findings + triage.** Append to the Findings table below using the `F# / Severity / File-or-Loc / Finding / Recommendation` format (mirror audit-01's table shape). Severities:
   - `blocking` — measurement reveals a token-cost claim that's materially false (e.g., a "lean" file is actually 3× median, or redundancy across files inflates worst-case load by >2×).
   - `drift` — cost-shape outlier that's not strictly wrong but should be fixed in apply (extraction recommendation, redundancy cleanup, payload carve-out).
   - `polish` — small win (drop a redundant paragraph, tighten a phrase).

   For every `blocking` finding: append a new `A##` cluster entry in `FIXES.md` (or extend A1 if Path A ran and the numbers satisfy A1's gate condition). Keep FIXES entries action-shaped — narrative belongs in this section file's Findings.

**Verify**:

- Every router and every chapter is covered in the size inventory output (step 2). Verify by checking inventory output sums to 23 routers + 84 chapters + 10 adjacent files. Re-derive counts from disk; do not trust the count claim in this file.
- Outlier triage (step 3) names every router >65 / chapter >120 / adjacent file >200 with explicit rationale. Verify by listing all flagged files in Findings.
- Redundancy scan covered at least the top-5 heaviest stacks (step 4). Verify by listing the stacks examined in Findings + flagged pairs (if any).
- Heavy-load shape analysis names top-5 with combined line-count + token-proxy estimate (step 5). Verify by checking each stack has both numbers + a yellow-zone judgment.
- **[Path A only]** Headline reduction % is cited with sample size + std-dev + model + date in Findings. Verify by reading the Findings table after step 6.
- **[Path B only]** Findings explicitly state "static-proxy estimate, real numbers blocked on LC1 spend authorization" and A1 stays open in FIXES. Verify by checking the Findings table's methodology note + grep `FIXES.md` for "A1".
- `FIXES.md` after the session is queue-shaped: every entry a discrete, triageable action item; no narrative essays. If the audit's cluster has drifted into narrative, compact back into action items + link to this section file's Findings table for detail.
- Audit-phase rule 3 (heartbeat caveat): verify actual mutations via `git diff` against session-start commit at `/done`, not by reading Session log `touched:` lines.

**Output**:

- Commit message hint: `docs(audit): section 2 — token-cost measurement findings`
- Update at `/done`: this section file (Findings filled, status `done`), `docs/PROGRESS.md` (pointer → `audit-03-personalization`, refresh next session reading list), `FIXES.md` (new `A##` cluster entries if any; A1 extended/closed if Path A produced satisfying numbers).

---

## Findings

Session 1 inventory (2026-05-28, session-start commit `8ad2c91`):

| Category | n | Total lines | min | p50 | p90 | max | p90→max gap |
|---|---|---|---|---|---|---|---|
| Routers (`skills/core/op-*/SKILL.md`) | 23 | 1242 | 32 | 48 | 80 | 108 (op-onboard) | 28 (cost-asymmetric — one heavy file dragging the tail) |
| Chapters (`chapters/**/*.md`) | 84 | 5735 | 33 | 62 | 118 | 155 (12b-claudemd) | 37 (moderate) |
| Adjacent files (`skills/core/op-*/*.md` non-SKILL) | 10 | 1386 | 49 | 121 | 203 | 317 (questions-deep) | 114 (sharp asymmetry — questions-deep alone dominates) |

All counts derived from disk via `wc -l` + `find`, not from prose claims (per Cross-section notes § PF1 carried forward from audit-01). Match the audit-01 baseline declared in `CLAUDE.md` L217 (23 op-* / 84 chapters / 10 adjacent / 9 commands / 6 hooks).

**Routers >65 (5 files):** op-bucket-router (70), op-suggest (71), op-approach (80), op-spine-active (92), op-onboard (108).  
**Chapters >120 (7 files):** 11-overview (121), 19f (122), 05k (123), 17b (124), 10-visuals (131), 06 (134), 12b (155). Audit-01 spot-checked these as one-concept-shaped; this audit re-confirms under the cost-lens — each is thoroughly teaching one concept (catalog / matrix / overview shape that pays its keep per row), not expansively teaching one. No trim candidates.  
**Adjacent files >200 (2 files):** op-prepare/procedure.md (203), op-onboard/questions-deep.md (317).

**Token-per-line proxy:** 7 tokens/line (markdown convention). Path A LC1 measurement underway at write-time; the measured ratio will retroactively calibrate F3's heavy-load token figures + future Path B estimates. **±20% calibration uncertainty** on proxy-derived numbers below until LC1 aggregate completes.

| F# | Severity | File / Loc | Finding | Recommendation |
|---|---|---|---|---|
| F0 | **drift (REFRAMING REQUIRED for apply)** | `benchmarks/tokens/results/results.jsonl` (Sonnet 4.6, 2026-05-28, n=11 paired prompts of 19) | **LC1 Path A headline: spine-on uses +75.9% MORE total input tokens than spine-off** (mean of per-prompt means across 11 paired prompts; per-prompt delta = +125.9% mean ± 110.8% stdev). Off baseline mean: 59,209 input tokens/call. On mean: 104,148 input tokens/call. Delta: +44,938 tokens/call. **Cost delta: +28.6% per call** (off $0.068 → on $0.0875). Cache picture: off cc=9.6k / cr=49k; on cc=12.6k / cr=91k — the spine's contribution mostly shows up in cache-read (~42k more cached prefix at 10% of fresh-input price), softening the dollar delta. **Per-prompt variance is enormous**: 9 of 11 paired prompts showed +60% to +282% spine overhead; 1 (`bf-inherited-project`, n=2 off) showed −21.7%; 1 (`pe-supabase-client`) was near-zero (+2.5%). **Coverage caveat**: only 11 of 19 prompts paired — 8 negative controls (`ctrl-*`) + `hk-typecheck-after-edit`, `pr-bad-output`, `sa-parallel-subagents`, `sg-scope-check` have ON-only data (their OFF runs were the late-eval prompts wiped by the mid-run CLI upgrade documented in F1/F5). The controls were specifically designed to test for spine-overhead-on-irrelevant-prompts — that signal is **unmeasurable in this LC1 run**. Total LC1 spend: ~$6.48 (87 successful calls across both phases combined). | **The headline contradicts naive "spine saves tokens" framing.** A1 apply work must reframe `README.md` + `landing/index.html` + any `benchmarks/tokens/REPORT.md` headline: the spine's design constraint (per `CLAUDE.md` L34) is "minimize loaded bytes per session" — not "use fewer tokens than not having the spine." The measurement confirms that per-load shape is green-zone (F3) but shows the spine's **comparative** per-call cost is +29% in dollars and +76% in raw input tokens. Honest framing options for REPORT.md: (a) cite the per-call delta + note that cache amortization across multi-turn sessions shrinks it; (b) cite the per-load worst-case from F3 as the "we keep it tight" evidence; (c) acknowledge the spine's primary value-add (correct skill routing) is measured by `tests/skill-triggers/`, NOT this benchmark. **Recommended:** rewrite the README's "What you get" / token-saving claim to "bounded per-load cost + routing accuracy" rather than "fewer tokens than vanilla Claude Code." Adds to A1's path notes; the rewrite is the apply work. Audit-02 does NOT write `REPORT.md` / `README.md` / `landing/index.html` (out of scope per Done criteria L33). |
| F1 | drift | `~/.claude/skills/` (installed spine) vs `/Users/macbook/claude-spine/skills/core/` (repo) at LC1 launch (2026-05-28 16:30) | Installed spine carried **22 of 23 op-* skills**; `op-approach` (Section 0 build, 2026-05-28, 80 lines, frontmatter description ~750 chars) was repo-only. `run.sh` L284-291 surfaced this as a warning + proceeded. Spine-on measurement therefore reflects the **pre-Section-0 spine state**, not today's repo. Quantitatively: ~560 tokens at the 7-tokens/line proxy ≈ ~0.5% of the measured ON per-call input (104k); negligible vs F0's +45k headline delta but worth recording. | Two-part: (a) For this LC1 result publication (A1 apply): cite the spine state at run time and the date — "22 of 23 op-* installed; op-approach not in benchmark spine-on" — in REPORT.md's methodology note. (b) For future LC1 re-runs: tighten `benchmarks/tokens/run.sh` L289-291 to a hard fail by default, with `--allow-stale-spine` opt-in. Apply work; out of audit-02 write scope. Adds to A1's path notes. |
| F2 | drift | `skills/core/op-onboard/questions-deep.md` L308-317 (10-line "## Then — Hook tuning" block) | The block carries TWO broken cross-refs into `SKILL.md` — `## Hook tuning (deep mode only)` (non-existent, same string as audit-01 F8) and `## After writing the profile — the handoff` (also non-existent). The actual post-deep flow is defined at `op-onboard/SKILL.md` L94 (Step 7 → `hook-tune.md`) + L96 (Step 9 → `handoff.md`); both moved to adjacent files during the L10 ambient-workflow refactor. Beyond the broken anchors, the block restates content already named in SKILL.md, so it's dead weight in addition to wrong-target — ~10 lines (~70 tokens) of router-load that pays no keep on the most-frequently-loaded heavy stack (op-onboard --deep, 1172 lines). | Drop L308-317 entirely. SKILL.md L94 + L96 already define the post-deep flow; questions-deep.md doesn't need to mirror it. Add to the A13 cluster (this is the same drift class as F4/F5/F6/F8 — one-line+one-block fixes for an apply session). |
| F3 | info | cross-router heavy-load shape survey (derived from inventory above) | Top-5 worst-case session loads (combined router + chapters routed + adjacent files + relevant templates, line counts then proxy tokens @ 7 t/l): **(1)** `op-onboard --deep` = SKILL 108 + questions-essential 186 + questions-deep 317 + profile-template 113 + subscription-tune 60 + hook-tune 149 + extras-merge 130 + handoff 109 = **1172 lines ≈ 8.2k tokens (4.1% of Sonnet 4.6's 200k context)**. **(2)** `op-prepare` = SKILL 54 + procedure 203 + chapters 05h/05i/05j (89+105+119=313) + 5 templates (PROJECT_BRIEF 62 + ARCHITECTURE 135 + PROJECT_PLAN 61 + SECTION_PLAN 99 + PROGRESS 59 = 416) = **986 lines ≈ 6.9k tokens (3.5%)**. **(3)** `op-onboard` essentials = SKILL 108 + questions-essential 186 + profile-template 113 + subscription-tune 60 + handoff 109 = **576 lines ≈ 4.0k tokens (2.0%)**. **(4)** `op-foundations` + 3 default chapters (01a 40 + 01b 55 + 01c 48) + topic chapter (~50) = **235 lines ≈ 1.6k tokens (0.8%)**. **(5)** `op-anti-patterns` + 18-meta (54) + topic chapter (33-74) = **131-172 lines ≈ 1.0-1.2k tokens (0.5-0.6%)**. **All five within `02-context-budget.md`'s green zone (0-40%)**. Even the heaviest single router worst-case (op-onboard --deep) is under 5% of a Sonnet 4.6 session. | None — confirms the token-efficiency claim at the static, per-router load level. F0's headline number (relative reduction vs spine-off) is the comparative measurement; F3 is the absolute-per-load picture. Both should appear in `benchmarks/tokens/REPORT.md` per A1 apply work — the absolute picture is what answers "what does loading the spine COST in a single session?" while LC1's headline answers "what does the spine SAVE vs not having it?" |
| F4 | polish | `skills/core/op-onboard/SKILL.md` L31-50 + L52-85 (audit-01 F1 carry-forward, cost-quantified) | Audit-01 F1 flagged ~50 inline preview lines for extraction to `preview.md` as polish. Under the cost-lens: this is the **largest single per-load reduction available among polish items**. op-onboard SKILL.md is loaded in every session-start classifier pass (via its frontmatter description — 750 chars / ~190 tokens, separately) AND in every interview load (108 lines, 756 tokens at proxy). Projected post-F1: SKILL.md 108 → ~58 lines (-46%); essentials stack 576 → ~526 (-9%); deep stack 1172 → ~1122 (-4%). Per-onboarding saving: ~350 tokens (~$0.001 / call cache-read; ~$0.005 / call cold). | Confirms + cost-quantifies audit-01 F1. No new FIXES entry needed — F1 stays in audit-01's section file as polish, but the projected post-apply line should be cited if A1's REPORT.md publishes a comparative "before/after" table. |
| F5 | drift | `benchmarks/tokens/results/raw/` + `benchmarks/tokens/results/results.jsonl` (pre-LC1-launch state, 2026-05-28 16:25; LC1 first-run failure mode, 2026-05-28 ~21:13) | Two related sources of run-state non-determinism: **(a) pre-LC1 residue:** 33 valid raw `.json` files (32 `off`, 1 `on` — `ctrl-yaml-indent__on__r1`) + 81 empty + 114 `.err` files. Earliest `.err` set (01:19) carried `line 167: timeout: command not found` (macOS lacks GNU `timeout`; run.sh's fallback at L87-95 handles it now). Pair coverage 1/38 = 2.6%, below 80% — triggered full re-run. **(b) LC1 first-pass failure (root cause confirmed by user):** mid-run `claude` CLI auto-upgrade (2.1.153 → 2.1.154 at 21:13) replaced `/opt/homebrew/bin/claude.exe` mid-execution. The OFF batch had run 30 of 57 successful invocations against the 2.1.153 binary; the remaining 27 OFF + all 57 ON invocations hit `/opt/homebrew/bin/claude: No such file or directory` (exit 127). Path A required a follow-up `--only-cond on` re-run (cost ~$3-4, additional spend within the originally-authorized $9–15 budget). Total LC1 spend after both passes: ~$6.48 / 87 successful calls. **Not a harness bug** — the harness's stash-restore logic worked correctly; failure was an external mid-run binary upgrade. | For A1 apply cleanup: (a) archive `*.err` files from both run phases to `benchmarks/tokens/results/archived-pre-publish/`; (b) REPORT.md methodology note should call out both the macOS `timeout` portability fix AND the mid-run CLI upgrade as historical-state caveats. **Harness improvement** (apply-side, separate from REPORT.md): add a preflight check to `run.sh` that captures `claude --version` + binary mtime at start and re-checks before each call; abort with a clear error if either changes mid-run. ~30 min apply work; could be added to A1's path or split into a new entry. **Out of audit-02 write scope.** |

---

## Session log

_(per-turn heartbeats appended automatically by `spine-writeback.sh` Stop hook during the active session)_
- session 1 @ 2026-05-28 16:27 — touched: FIXES.md docs/PROJECT_PLAN.md
- Session 1 done 2026-05-28. Path A executed. 6 findings (0 blocking, 5 drift, 1 polish); A1 extended in FIXES with LC1 results + reframing notes + harness-preflight task; A13 extended with F2 (5th same-class drift item). Writes confined to this section file + `FIXES.md` (A1, A13 extensions); no `chapters/`/`skills/core/`/code/templates edits this session. Pre-flight rule 3 caveat verified: actual mutations confirmed by `git diff` against session-start commit `8ad2c91` — only `docs/plans/audit-02-token-cost.md` + `FIXES.md` modified by audit-02. (Stop-hook heartbeats during the session reflected the whole-working-tree dirty list per the caveat.) **LC1 spend ~$6.48 / 87 successful calls.** Headline F0 `+75.9% input` (n=11 paired) is the gating data for A1's apply work — the rewrite from "spine saves tokens" to "bounded per-load cost + routing accuracy" is now the load-bearing apply task. Audit-03-personalization is next (stub — `/prep` required first).
