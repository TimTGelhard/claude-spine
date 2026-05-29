# FIXES — open queue

Single source of truth for what's still open in claude-spine. Per-round shipping narrative lives in [`CHANGELOG.md`](CHANGELOG.md); the full pre-cleanup audit history (Pass 1–5 + every shipped annotation) is archived at [`docs/archive/FIXES-rounds-1-5-2026-05.md`](docs/archive/FIXES-rounds-1-5-2026-05.md).

**Status as of 2026-05-28:** v2 architecture + all six pillars + bias-audit rounds 1–7 + the doc cleanup + the post-launch trim + the P4 stack-flavor split have shipped. A stress-test audit on 2026-05-28 ([`docs/evaluation/REPORT-2026-05-28.md`](docs/evaluation/REPORT-2026-05-28.md)) raised three blocking gaps before LC5 and a cluster of drift + parity items. **Same-day intake:** drift items (A5 partial / A7 / A8 / A9 / A10) shipped — see `CHANGELOG.md [Unreleased]`. **Second-pass intake (2026-05-28):** A2.1, A3, A5 full sweep, A6 shipped — see `CHANGELOG.md [Unreleased]`. **Third-pass intake (2026-05-28):** A2.2 (Push-back Q4 end-to-end) + A11 (python-django flavor-skill parity) shipped — see `CHANGELOG.md [Unreleased]`. The remaining structural residue (A1, A2.3/A2.4, A4, A12) lives in the `A##` section below with explicit best-path notes — each item is the long-term wiring, not a strike-shortcut, and most are multi-session. **Audit phase (audit-01..06) is staged and pending** in `docs/PROJECT_PLAN.md`; findings land here only after each audit `/done`'s.

---

## Pre-launch checklist (LC1–LC6)

Manual user-actions left before v1.0. Originated in the archived `LAUNCH.md`; owner: maintainer.

- **LC1 — Token-efficiency benchmark baseline run.** Harness + eval-set shipped 2026-05-28. The actual spine-on vs spine-off run is gated on authorization (~$9–$15 of Sonnet 4.6 per the original notes; check current Anthropic pricing). **Output:** token-efficiency number for LC4's demo. **Audit A1 escalates:** partial-run residue lives in `benchmarks/tokens/results/` (incl. `.err` failures) — clean up or publish before LC4.
- **LC2 — Domain registration.** Pick + register the canonical domain. Update `landing/index.html` canonical URL + GitHub social-preview URL once known.
- **LC3 — Waitlist / signal-of-interest path.** Where launch traffic lands. Light (mailto + star prompt) or heavy (real waitlist form) — decision required before LC5.
- **LC4 — Demo.** 60–90s screencast: `/onboard` walkthrough → `/prep` a sample project → `/done` close. **Blocked by:** LC1 (numbers) + LC2 (URL in screencast).
- **LC5 — Public launch.** Generate the `og:image` (TODO marker already in `landing/index.html` `<head>`), then publish. **Needs:** LC2–LC4.
- **LC6 — Personal-migration verification.** Restart Claude Code, run `/onboard`, fresh-session "are my defaults still right?" — ~15 min. No dependencies.

**Order:** LC1 → LC2 → LC3 → LC4 → LC5; LC6 anytime.

---

## Bias-audit residue (BA3)

Items from the archived [`BIAS-AUDIT`](docs/archive/BIAS-AUDIT-2026-05.md) not yet fully shipped after rounds 1–7. BA1 + BA5 closed in round 7 (2026-05-28 — see CHANGELOG).

- **BA3 — Per-platform DEPLOY.md variants.** Round 2 made `templates/DEPLOY.md` stack-agnostic and shipped the worked Next/Vercel/Supabase example under `templates/examples/web-saas-next-supabase/`. Other variants (Docker registry, k8s/Helm, AWS Lambda/SAM, GCP Cloud Run, library publish for npm/PyPI/cargo, GitHub Releases binary, mobile app stores) not yet shipped. **Pull-driven:** add as inbound users request them; ~30 min per variant. Routing now has signal: as of round 7, `/onboard --deep` Section W captures `Deploy target` for UI apps — those answers tell future-you which BA3 variants the audience actually wants first. **Audit A4 escalates:** ship at least one non-web variant (CLI cheapest) before LC5; one worked web example is the loudest "this is for web devs" signal in the repo.

---

## Stress-test audit follow-ups (A1–A12, 2026-05-28)

From the read-only audit at [`docs/evaluation/REPORT-2026-05-28.md`](docs/evaluation/REPORT-2026-05-28.md). Drift items A5 (partial), A7, A8, A9, A10 shipped 2026-05-28 — see CHANGELOG `[Unreleased]`. The remaining items below are the **structural work**: each one specifies the *best long-term path*, not the strike-or-cheap fallback. Most are multi-session.

### Blocking — before LC5

- **A1 — Publish LC1 token-efficiency numbers (`benchmarks/tokens/REPORT.md` + README).** **Path:** (1) audit the partial-run residue in `benchmarks/tokens/results/` — keep the successful `*__on__*.json` / `*__off__*.json` pairs, archive the `.err` failures with a per-prompt note in `REPORT.md` ("dropped: X failed runs out of Y"); (2) complete any missing eval-set runs cleanly (cost: ~$9–15 of Sonnet 4.6, check current pricing); (3) write `benchmarks/tokens/REPORT.md` with the headline number (input-token reduction % on the eval set, sample size, model, date), per-prompt breakdown, and methodology note; (4) thread the number into `README.md`'s "What you get" + `landing/index.html`. **Why not the alternative:** killing the run and reframing the headline as architectural-only would weaken the README's central design-constraint claim. The harness exists, the eval-set is shipped — finish it. **Owner decision:** the only thing that gates this is your authorization for the spend.

  **LC1 EXECUTED 2026-05-28 (audit-02 Path A).** Spend authorized; two-pass run (initial + `--only-cond on` re-run after mid-run `claude` CLI upgrade 2.1.153 → 2.1.154 wiped the spine-on phase; total ~$6.48 across 87 successful calls). **Headline: spine-on uses +75.9% MORE total input tokens than spine-off** on the 11 paired prompts of 19 (per-prompt delta +125.9% mean ± 110.8% stdev; +28.6% cost/call: $0.0680 OFF → $0.0875 ON; cache-read amortizes most of the dollar delta). 8 negative-control prompts (`ctrl-*` + 4 spine-relevant) have ON-only data — their OFF data was lost to the mid-run upgrade, so this LC1 cannot answer "does the spine add overhead on irrelevant prompts?" (the question the controls existed to answer). **Methodology caveats:** 22 of 23 op-* installed at run time (op-approach repo-only; ~0.5% effect); single-shot `claude -p` doesn't capture multi-turn cache amortization. **A1 path notes — UPDATED:** (1) **the headline CONTRADICTS the naive "spine saves tokens" framing.** `README.md` "What you get" + `landing/index.html` need REFRAMING from "fewer tokens than vanilla Claude Code" → "bounded per-load cost + routing accuracy." The per-load worst-case is green-zone (audit-02 F3: heaviest single-skill load `op-onboard --deep` ≈ 8.2k tokens, 4.1% of Sonnet 4.6's 200k context); the spine's PRIMARY value-add (correct skill triggering) is measured by `tests/skill-triggers/`, NOT this benchmark. (2) `REPORT.md` should publish BOTH the per-call delta (this LC1) and the per-load worst-case (F3) for the full picture. (3) Archive `*.err` residue from both run phases to `benchmarks/tokens/results/archived-pre-publish/` before publishing. (4) Add a `claude --version` + binary-mtime preflight + per-call re-check to `run.sh` so a future mid-run upgrade aborts cleanly (~30 min apply work). Full Findings detail: [`docs/plans/audit-02-token-cost.md`](docs/plans/audit-02-token-cost.md) § Findings F0–F5. **A1 remains Blocking — before LC5** until the reframe + REPORT.md publish lands.

- **A2 — Wire the decorative personalization fields end-to-end.** `19g` claims named consumers; the consumers don't read the fields. The right move is to make `19g` *true*, not to strike rows from it. A2.1 + A2.2 shipped 2026-05-28 — see CHANGELOG `[Unreleased]`. **Audit-03 reconciliation (2026-05-28, `docs/plans/audit-03-personalization.md` Session 1):** systematic 41-field sweep confirms A2.1/A2.2 real; **A2.3 is now mostly wired** (re-scoped below); **A2.4 confirmed decorative**; and the sweep surfaced **a new decorative cluster the original stress-test missed — A2.5 (3 `Prep*` fields)**. Net decorative count = 4 (G1 + 3 `Prep*`). Remaining work below:
  - **A2.3 — Active signals (D1): finish the `op-signaling` Step 0 read** *(~30 min — RE-SCOPED, was ~2h "wire from scratch")*. **Audit-03 found D1 is already instruction-honored** at `chapters/signaling/11-overview.md:34` ("Active-signal pruning (D1): …respect that — don't fire the muted category. See op-signaling Step 0"). The gap: `op-signaling/SKILL.md` Step 0 (L27) reads **only Push-back (Q4)**, not D1, so the "See op-signaling Step 0" pointer is unfulfilled. Fix: extend `op-signaling` Step 0 to also read D1 and skip muted signal categories; correct `19g:67` "Read by" to cite `11-overview:34` (not bare `op-signaling`). The original from-scratch design (canonical `Signal categories` table, D1 multi-select in `questions-*.md`) is optional polish, no longer load-bearing.
  - **A2.4 — Session shape (G1) into `op-collaboration-modes` + `op-workflow`** *(~3h, the most complex)*. `06-feature-sizing.md:9-17` names six session shapes (Build / Debug / Refactor / Explore / Review / Explain); the scaffolding is one-shape (Build). Design: G1 sets a default shape; `op-collaboration-modes` + `op-workflow` route to shape-specific guidance. For non-Build shapes, document what the equivalent of `/prep → ambient → /done` looks like (or honestly: "the plan-driven scaffolding doesn't apply — here's the discipline that does"). At minimum, make `op-workflow` SKILL.md branch on G1 so the user gets shape-relevant chapter routing. **Re-anchor target (A14 resolved 2026-05-28 as option b — dual taxonomy):** G1 enumerates `05k`'s **seven planning-shapes** (Build / Audit-or-review / Refactor / Migration / Investigation-or-debug / Research-or-spike / Cleanup-or-janitor). `op-workflow` looks up per-shape sizing via the A14 mapping table (which points into `06-feature-sizing.md`'s sizing rows; gaps are noted inline in 05k). Sequence A14 first — A2.4's G1 routing depends on the mapping table existing. **Audit-03 confirmed (2026-05-28):** G1 is decorative — its only reference outside declaration files is the `19a-overview.md:55` map entry; `op-workflow`/`06-feature-sizing.md` read no profile field. Until wired, `19g:68` should use the "captured, not yet wired" hedge rather than naming `op-collaboration-modes`/`op-workflow` as consumers.
  - **A2.5 — Three `Prep*` Planning spine-defaults are decorative** *(~30 min — NEW, from audit-03 Session 1)*. `profile-template.md` `### Planning` declares three user-overridable knobs — `Prep clarifying questions cap` (5-7), `Prep section count target range` (5-12), `Prep session entry split lines` (100) — and `19g` claims `op-prepare/procedure.md` reads them. It doesn't: `procedure.md:53` hardcodes "Cap at 5-7", `:102` hardcodes "Target: 5-12 sections", `:115/159/201` hardcode "100 lines"; `global/commands/prep.md:26` also hardcodes "Cap at 5-7". Setting any in the profile does nothing — a `CLAUDE.md` rule-10 violation in reverse (the field was surfaced but the consumer kept the constant). **Path (per A2 "make 19g true"):** wire `procedure.md` Steps 3/5/6 + `prep.md` to read each from `## Spine defaults` via the same `default N` idiom the bucket/writeback fields use (e.g. read `Prep session entry split lines`, default 100, in place of the literal `100`). Detail: [`docs/plans/audit-03-personalization.md`](docs/plans/audit-03-personalization.md) Findings F2. Weaker alternative: strike the three rows from `profile-template.md` + `19g` if the knobs aren't worth honoring — but rule 10 argues for wiring.

### Serious — universality

- **A4 — Ship at least one non-web worked example under `templates/examples/`.** Escalates BA3 (above) from pull-driven to launch-blocking. **Path:** ship `templates/examples/cli-tool/` first (cheapest). Contents: `README.md` describing the example stack (suggest: a small Go or Rust CLI with a `<verb> <flags>` surface), `CLAUDE.md` (project-level, ~30 lines), `docs/PROJECT_BRIEF.md`, `docs/PROJECT_PLAN.md`, `docs/PROGRESS.md`, one section file under `docs/plans/`, and `docs/DEPLOY.md` (binary release via GitHub Releases — different from the web example's continuous-deploy). After CLI: `templates/examples/library-publish/` (npm or PyPI, one variant) is the next-cheapest second variant. Each variant should be a real-shape example — not a stub. Audit's "loudest 'this is for web devs' signal" — fix it.

### Long-term — parity + verification

- **A12 — Ship `/profile verify` command.** **Path:** new `global/commands/profile-verify.md` (read-only command). Walks `~/.claude/claude-spine-profile.md` field by field; for each row in `chapters/personalization/19g-field-effects.md`'s tables, greps the named consumers (file paths + skill names) for the field key. Reports per-field: `✓ consumer present at <path:line>` or `✗ consumer missing — see FIXES Aₓ`. Optional `--fix` flag could open the matching FIXES section. Closes the "I changed X and nothing happened" trap that `19g` exists to prevent. ~1.5–2h. Dependency: nice-to-have *after* A2.1–A2.4 land, since most decorative rows will resolve to ✓ once those ship. **Audit-03 escalates value (2026-05-28):** the manual field/consumer sweep took a full session and still found 4 decorative fields + attribution drift that had accumulated silently (A2.5 hardcoded-vs-profile, A2.3 stale, F4 router-named-not-chapter). `/profile verify` would auto-flag exactly these — its absence is why the drift went unnoticed between audits (also logged for audit-06 as a test-gap).

---

## Architecture- and token-cost-audit drift residuals (A13, 2026-05-28)

From `docs/plans/audit-01-architecture.md` Session 1 (0 blocking, 4 drift, 4 polish) + `docs/plans/audit-02-token-cost.md` Session 1 (F2, same drift class). Polish items stay in the respective section files' Findings tables; the drift cluster below is one apply-section's worth of work.

- **A13 — Drift residuals across architecture + token-cost audits.** The apply pass should pick up the cluster as one section (~30 min): (1) `INDEX.md` is missing a row for `chapters/signaling/11g-push-back-phrasing.md` (audit-01 F4 — file exists, two callers cite it, INDEX has 83 of 84 chapter rows); (2) `README.md` L14 chapter-folder enumeration omits `personalization` (audit-01 F5 — same drift A8 fixed in `landing/index.html`, but README equivalent was not part of the Section-0 sweep); (3) `README.md` L135–143 folder tree omits `chapters/personalization/` (audit-01 F6 — sibling surface of F5); (4) `chapters/persistence/14b-hook-recipes.md` L55 cites a non-existent section heading `## Hook tuning (deep mode only)` in `op-onboard/SKILL.md`; the actual content lives in the adjacent `op-onboard/hook-tune.md` file post-refactor (audit-01 F8); (5) `skills/core/op-onboard/questions-deep.md` L308-317 carries the same broken-cross-ref pattern (cites `## Hook tuning (deep mode only)` + `## After writing the profile — the handoff`, neither present in current SKILL.md) PLUS restates content already at SKILL.md L94 + L96 — drop the entire 10-line block (audit-02 F2 — same drift class as F4/F5/F6/F8, second instance of audit-01 F8's broken heading citation). All five are one-line / one-block fixes. Detail + exact replacement text: [`docs/plans/audit-01-architecture.md`](docs/plans/audit-01-architecture.md) Findings table (items 1–4) + [`docs/plans/audit-02-token-cost.md`](docs/plans/audit-02-token-cost.md) Findings table (item 5). Polish items (audit-01 F1–F3, F7 — op-onboard preview-block extraction, two TL;DR drops, RECONSTRUCTION L11 forward-pointer; audit-02 F3 absolute-cost picture + F4 quantification of audit-01 F1's projected savings) stay in the respective section files.

---

## Skill-trigger accuracy (A15, 2026-05-29, audit-04)

From [`docs/plans/audit-04-skill-triggers.md`](docs/plans/audit-04-skill-triggers.md) Session 1 (all 23 op-* descriptions scored against the 13b rubric; overlap matrix; body-confirmed drift). 1 blocking + 8 drift = one apply-section's worth of SKILL.md-frontmatter edits — the descriptions fire well on *what + triggers* (23/23 each) but are uneven on *disambiguation*, so every overlap traces to a missing or phrase-invisible "what-it's-NOT-for." Polish (F10 op-spine-active path-undercount; F11 op-visuals/op-prompting NOT-for clauses) stays in the section file. **No SKILL.md edits yet — apply runs after all six audits are `done`.** Exact proposed clauses: section file Findings table. (A15, not A14 — A14 was a removed audit-restart number; see PROJECT_PLAN status log.)

- **A15.1 (blocking) — `op-workflow` ↔ `op-prepare` planning misroute.** Both fire on "starting a new project / scope this out / plan the build sequence"; only a chapter-citation (05/06 vs 05h–j) separates them — invisible to phrase-match, so a user wanting to *plan* can land in op-workflow's concept chapters instead of op-prepare's planning pass. Direct hit on the audit-02 **A1 routing-accuracy** claim. Fix: add a planning-pass disambiguation clause to `op-workflow`'s description + list `op-prepare` in its Siblings (SKILL.md:48–50 omits it). [F1]
- **A15.2 (drift) — `op-hooks` over-claims the persistence decision.** `op-hooks` + `op-persistence` both claim "hook vs CLAUDE.md vs skill / from now on when X." Fix: narrow `op-hooks` to *wiring* + defer the *decision* to `op-persistence` 12a. [F2]
- **A15.3 (drift) — meta-scope layering undocumented.** `op-signaling` 11e + `op-anti-patterns` 18-meta both fire on "extending the spine" with the same reviewer-mode outcome. Fix: *document the intentional layering* (catalog vs cadence) in one cross-ref clause each — do NOT merge. [F3]
- **A15.4 (drift) — `op-curate-nudge` description omits the bucket-loop gate.** Default-off bucket loop makes the stated firing condition misleading for the median user (body loads then exits). Fix: prepend "when the bucket loop is enabled" to the description. [F4]
- **A15.5 (drift) — `op-bucket-router` FP on "/curate".** The one benchmark-confirmed FP. Fix: add a `/curate`+`/suggest` slash-command carve-out to the "never invents" clause. [F5]
- **A15.6 (drift) — `op-add-skill` ↔ `op-suggest` "remember this" collision.** Fix: qualify op-add-skill's trigger ("a full reusable *skill*" vs `/suggest` for a lightweight note). [F6]
- **A15.7 (drift→polish) — `op-curate` description over-long.** Carries the apply/reject procedure (body content) on the every-session-classifier surface. Fix: trim to trigger + scope-refusal; the body already covers the mechanics. [F7]
- **A15.8 (drift, mild) — two understand-vs-act / mode-vs-shape overlaps.** `op-foundations` ↔ `op-recovery` ("drifting/hallucinating") and `op-collaboration-modes` ↔ `op-approach` ("audit/review X"); one cross-ref clause each. [F8, F9]

---

## Pass-4 remaining

Two Pass-4 items that remain deferred pending broader sign-off or capacity. P4 closed in `[Unreleased]` (2026-05-28 — see CHANGELOG).

- **C-block — Command consolidation 9 → 6.** Subcommand consolidation (`/bucket suggest|curate|add|refresh`) + merging `/spine` and `/hooks` into one discovery surface. Cuts the slash-menu from 9 to 6. Significant UX change; needs broader sign-off. ~3h.
- **B10 — Windows-native installer.** PowerShell or Python cross-platform variant of `install.sh`. Opens a double-digit-percent addressable user base. Stretch goal; ~half-day to a day. Needs Windows test capacity.

---

## Deferred / accepted-as-is

Noted for awareness; not actively scheduled.

- **B11 — i18n hook in onboarding.** Deferred per the original BIAS-AUDIT finding; revisit when adoption signals localization is worth it.
- **U-block — `/profile explain <field>` standalone command.** Covered by [`chapters/personalization/19g-field-effects.md`](chapters/personalization/19g-field-effects.md). Standalone command is polish.
- **N2 — YAML frontmatter parser for PROGRESS.md.** The marker comment + `.spine-parse-error` surface are sufficient today; YAML migration only earns its keep if real-session data shows the marker insufficient.

---

## Reference

- Per-round shipping detail (rounds 1–7 + doc cleanup): [`CHANGELOG.md`](CHANGELOG.md) under `[0.11.0]` and `[0.10.0]`.
- Full pre-cleanup audit history: [`docs/archive/FIXES-rounds-1-5-2026-05.md`](docs/archive/FIXES-rounds-1-5-2026-05.md).
- Original full-repo bias audit: [`docs/archive/BIAS-AUDIT-2026-05.md`](docs/archive/BIAS-AUDIT-2026-05.md).
- Stress-test audit (this round's A1–A12): [`docs/evaluation/REPORT-2026-05-28.md`](docs/evaluation/REPORT-2026-05-28.md).
- Pre-launch phase tracker (archived): [`docs/archive/LAUNCH-pre-1.0.md`](docs/archive/LAUNCH-pre-1.0.md).
