# Project Plan — claude-spine

> Master plan for the ongoing audit + apply pass. Ordered sections + dependencies + status.
> Updated rarely — only when scope changes at the project level.
> See `docs/plans/<section>.md` for per-section session breakdowns.

## Project goal

Improve claude-spine systematically by auditing the project against its own three load-bearing claims (token efficiency, real personalization, opinionated-but-neutral) and applying targeted fixes one dimension at a time. v2 architecture + bias-audit rounds 1–7 have shipped; this is the post-launch consolidation pass. Each audit dimension runs as a separate section; apply sessions follow the audit per `FIXES.md` priority.

## Where to read for project understanding

Cold-start sessions should always have these loaded before doing anything in this plan:

- `CLAUDE.md` — the project soul. 5-layer architecture, 12 anti-drift rules, 3 load-bearing claims. Canonical "what should be true."
- `INDEX.md` — chapter routing fallback. Topic → file map for the 80-ish atomic chapters.
- `RECONSTRUCTION.md` — frozen v2 architectural decisions + build journal. Use for "why is X shaped this way."
- `FIXES.md` — current open queue (LC1–LC6, BA3, A1–A12, C-block, B10). Audit findings flow here.
- `CHANGELOG.md` — shipped work, Keep-a-Changelog format.
- This file (`docs/PROJECT_PLAN.md`) — the audit's master.
- `docs/PROGRESS.md` — live pointer to the active section + session.

The active section file (`docs/plans/<active-section>.md`) declares the per-section read list. Cold-start agents read that, not the whole `docs/plans/` directory.

## Constraints

- **Stack**: bash 5+, jq, git, coreutils (per `CLAUDE.md`). No new runtime deps.
- **Discipline**: every change must honor the 12 anti-drift rules in `CLAUDE.md`. Specifically: no new top-level Markdown files, `FIXES.md` stays an action queue (discrete triageable items only — narrative goes to section Findings tables or `docs/archive/`), `CHANGELOG.md` stays Keep-a-Changelog (slim Added/Changed/Fixed/Removed bullets — no per-pillar essays).
- **Audit phase = write findings only.** Audit sessions do not edit `chapters/`, `skills/core/`, code, or templates. They write only to: the active section file's Findings table, `FIXES.md` (escalate blocking findings as new `A##` clusters), and `docs/PROGRESS.md` (advance pointer at `/done`). Nothing else.
- **🔒 All six audit sections complete BEFORE any apply session runs. Hard rule.** Interleaving (audit-01 → apply-01 → audit-02 → …) breaks coherence: apply-01 mutates `chapters/`, `skills/core/`, or code that audit-02 was about to read, so audit-02's findings can land against a state that no longer exists. Worse, apply-02 might then re-break what apply-01 just fixed, because the two apply sessions were planned against different snapshots of the repo. The repo stays frozen (no edits to `chapters/`, `skills/core/`, code, or templates) for the duration of the audit phase. **Exception**: a finding so critical it cannot wait — make the call consciously, document the deviation in the Status log at the bottom of this file, and **re-run any audit section whose read was invalidated by the early apply**.
- **Open queue stays canonical**: `FIXES.md` is the single source of truth for outstanding work. Section-file Findings tables are the raw audit record; FIXES is the triaged action queue. Apply sessions consume from FIXES.

## Audit-phase pre-flight protocol

Every fresh session opening an audit section MUST satisfy four conditions before executing Session 1. The audit phase has a different shape than the build phase — these four rules keep it coherent across sessions:

1. **`/prep <section>` first.** Audit sections 02–06 ship as ~50-line stubs with sketch-only Session 1 entries (lazy-planning per `chapters/workflow/05h`). Do not execute from the sketch. Run `/prep <section>` at session start to produce the detailed entry — it benefits from prior audits' findings, and op-spine-active's scope announcement becomes accurate.

2. **READ-ONLY for `chapters/`, `skills/core/`, code, templates.** Audit sessions write only to: the active section file's Findings table, `FIXES.md` (at `/done`, escalating blocking findings into new `A##` clusters), and `docs/PROGRESS.md` (at `/done`, advancing the pointer). The Constraints section above declares this; restating because the audit phase loses coherence the moment one session mutates a chapter the next was about to read.

3. **Heartbeat caveat — `## Session log` `touched:` entries are NOT proof of mutation.** The Stop hook (`spine-writeback.sh`) builds the `touched:` list from `git status --porcelain` — the **entire dirty working tree**, not delta-per-turn. If the user has uncommitted work from a prior session/round, those files appear in every heartbeat under whatever section is active. Audit-phase read-only compliance must be verified by `git diff` against the session-start commit at `/done`, not by reading Session log. Hook bug tracked in `audit-05-self-discipline.md` PF2.

4. **Cross-section notes propagate manually.** Each section's "Cross-section notes" block names items that affect later sections. They don't auto-flow forward — the next section's `/prep` (or its session entry, if pre-detailed) must read prior sections' Cross-section notes and copy forward anything relevant into a `## Cross-section notes carried forward from <prior-section>` block in its own file. Without that step, the next session doesn't see them. See `audit-02-token-cost.md` for the live example.

## Sections (ordered)

| # | Section | Goal (one line) | Depends on | Status |
|---|---|---|---|---|
| 0 | section-0-approach-feature | Add `op-approach` skill + `chapters/workflow/05k-work-shapes.md` so the spine carries work-shape-aware preparation discipline (build/audit/refactor/migration/investigation/research/cleanup) before any audit section starts. | — | done |
| 1 | audit-01-architecture | 5-layer split honored? Routers route, chapters atomic, INDEX accurate, counts true? | 0 | done |
| 2 | audit-02-token-cost | Token-efficiency claim holds? Measure router/chapter sizes; LC1 if authorized. | 0 | done |
| 3 | audit-03-personalization | Every profile field has a consumer? Every claimed consumer reads a real field? | 0 | planned |
| 4 | audit-04-skill-triggers | SKILL.md descriptions trigger correctly without overlap or drift? | 0, 1 | planned |
| 5 | audit-05-self-discipline | Does the spine violate its own 12 anti-drift rules + anti-pattern chapters? | 0 | planned |
| 6 | audit-06-tests-docs | Test coverage gaps? Cross-references valid? Archive freshness? | 0, 1, 5 | planned |
| 7+ | apply-* | Apply `FIXES.md` entries in priority clusters; one section per cluster. | 0, 1–6 | not yet planned |

Statuses: `planned` / `in-progress` / `done` / `blocked`.

## Order rationale

**Phase 0 (feature — section 0):** A single-session pre-audit feature add. The spine has no chapter or skill that fires the meta-question "what shape is this work, and what's the right phase structure for it?" Without that discipline, the audit pass we're about to run would itself re-discover (in audit-05) a gap a user already caught in conversation — cross-section coherence. Building the discipline *before* the audit means (a) the audit pass benefits from it immediately, (b) `audit-05` confirms the integration rather than escalating the gap from scratch, (c) future users running their own audits inherit the rule rather than re-stepping on it. Hard rule: Section 0 finishes before any audit section starts. This is allowed under the audit-then-apply Constraint because the audit phase has not yet begun — the constraint is "no edits between audits," not "no edits ever."

**Phase 1 (audit — sections 1–6):** Sections 1–3 and 5 are independent — they audit different surfaces and can run in any order. Section 4 (skill triggers) benefits from Section 1's INDEX/router accuracy. Section 6 (tests + docs) benefits from Section 1 + 5. **Recommended order: 1 → 2 → 3 → 4 → 5 → 6, but each is self-contained — reorder per appetite.** All six audits read against the same frozen post-Section-0 repo snapshot; this is enforced by the "all six audits done before any apply" rule in Constraints above.

**Phase 2 (apply — sections 7+):** Drafted just-in-time after Phase 1 completes, when the full picture of findings is consolidated in `FIXES.md`. Apply sections are planned per priority cluster (one section per cluster) and are edit-allowed against `chapters/`, `skills/core/`, code, and templates as needed. The order across apply sections is set by FIXES.md severity, not by which audit produced the finding.

## Open questions

- **LC1 authorization (~$9–$15 of Sonnet 4.6).** Required before Section 2 can produce real benchmark numbers. If not authorized when Section 2 runs, Section 2 produces static-analysis-only output and LC1 stays in `FIXES.md`.

## Risks

- **Scope creep mid-section.** Mitigated by each section's strict "Files to write" list (audit output only) and explicit "Out of scope" note that names sibling sections by ID.
- **Findings overflow into `FIXES.md`.** FIXES is an action queue, not a findings archive. If a section produces many blocking findings, summarize the cluster inline (one paragraph linking back to the section file) and let the full detail stay in the section file's Findings table — that keeps FIXES action-shaped without losing the audit record. The risk to watch isn't lines, it's narrative drift.
- **Section files growing past 300 lines** during a session. If happening: split the session, mark current one `done` at a clean break, draft a new session entry for the rest (per `05j` hard rules).

---

## Status log (append-only)

Plan-level changes only. Per-session changes live in section files and `PROGRESS.md`.

### 2026-05-28
- Plan created. Audit sections 1–6 outlined. Section 1 (`audit-01-architecture`) fully detailed; sections 2–6 stubbed for just-in-time detailing before each starts. Apply sections deferred until audit findings land in `FIXES.md`.
- Constraints strengthened: audit-then-apply phase boundary made load-bearing after user caught a cross-section coherence risk that the planner missed. Pre-flagged finding added to `audit-05-self-discipline.md` (PF1) so the gap doesn't get lost — Session 5 will confirm + escalate the fix locus (`chapters/workflow/05h-multi-session-planning.md` anti-patterns list + `op-prepare`'s procedure).
- **Section 0 inserted before audit-01.** User reframed the cross-section coherence catch as a symptom of a deeper missing capability — the spine has no "preparation-first" trigger that fires when a problem needs strategic preparation before execution. Building `op-approach` skill + `chapters/workflow/05k-work-shapes.md` (7-shape catalog) as a single pre-audit session so the audit pass runs against a spine that carries the discipline. This widens the original PF1 fix (chapter-edit + op-prepare procedure step) into a full feature add. Audit-05 will now confirm the *integration* rather than escalate the *gap*. Allowed before audit phase starts; not an audit-then-apply violation (no audit section has run yet).
- **Section 0 marked `done`.** Shipped: `skills/core/op-approach/SKILL.md`, `chapters/workflow/05k-work-shapes.md`, anti-patterns + cross-reference rows in `chapters/workflow/05h-multi-session-planning.md`, when-NOT-to-fire + sibling rows in `skills/core/op-prepare/SKILL.md`, new INDEX row, and an 11-edit count-claim sweep across `CLAUDE.md`, `README.md`, `install.sh`, `skills/core/op-welcome/SKILL.md`, `landing/index.html` (23 op-* skills + 84 atomic chapters; the latter also resolves the pre-existing `~80` tilde-claim — actual pre-feature count was 83, post-feature exact 84). PF1 in `audit-05-self-discipline.md` re-framed from "escalate the gap" to "verify the integration" + severity dropped from `blocking` to `info`. Audit-01's count-claim Done criterion is now satisfied pre-audit; audit-01 Session 1 will confirm rather than rediscover. **Audit phase may now begin (audit-01-architecture).**
- **Audit-phase pre-flight protocol added (meta-prep pass).** New "Audit-phase pre-flight protocol" section in this file codifies four conditions: `/prep <section>` first (skip when the section is already detailed, as audit-01 is), READ-ONLY surface for `chapters/`/`skills/core/`/code/templates, heartbeat caveat (Session log `touched:` includes working-tree dirty files — verify mutations via `git diff` at `/done`), and cross-section note propagation discipline. Each stubbed audit section (03–06) gained a top-of-file pre-flight pointer. `docs/plans/audit-05-self-discipline.md` PF block extended with PF2–PF5 capturing four infrastructure bugs surfaced while running `op-spine-active` on a pending audit section (heartbeat hook delta-tracking via `git status --porcelain`, `op-spine-active`'s missing stub-handler path, `/done`'s section-file status sweep gap, `Read(**/*token*)` deny-rule overreach against `docs/plans/audit-02-token-cost.md`) — destined for audit-05 escalation, not this pass's fix scope. Section-0 Session 1 status corrected (`in-progress` → `done`; closed at Section 0 wrap-up). **No FIXES.md entries added by this prep pass** — PF2–PF5 stay in audit-05 until that section runs. **No chapter / skill / code / template edits** — meta-prep stays inside `docs/` + `CHANGELOG.md`.
- **Audit-phase restart (2026-05-28).** During the prep pass + a parallel Claude session, audit-01 + audit-02 substantively ran (audit-01 surfaced F1–F5 → A13 cluster; audit-02 surfaced F1–F7 → A14). User chose full restart of the audit phase (re-do audit-01 + audit-02 from scratch), one-audit-per-session pace. Cleanup: `docs/plans/audit-01-architecture.md` reverted to pre-Session-1 state (Done criteria unchecked, Findings cleared, Cross-section notes cleared, Session 1 Status → pending, Session log heartbeat + done-summary lines removed); `docs/plans/audit-02-token-cost.md` reverted to its original 56-line stub; `FIXES.md` A13 cluster + A14 entry + the top-of-file "Audit-01" framing line removed; `docs/PROGRESS.md` pointer reset to audit-01 / Session 1 pending; this file's Sections table audit-01 + audit-02 status `done` → `planned`; the prior "Section 1 done" and "Section 2 /done finalized" Status log entries replaced by this restart entry. Audit-05 PF1–PF5 + Section 0 status + Audit-phase pre-flight protocol all retained — they are infrastructure that the restart benefits from, not part of the discarded audit-01/02 work. CHANGELOG `[Unreleased]` Changed bullets revised to drop the audit-02-closed entry.
- **Audit-01-architecture closed (2026-05-28, re-run).** Session 1 produced 8 findings: 0 blocking, 4 drift (F4 INDEX missing 11g row, F5 README L14 folder enum, F6 README folder tree, F8 chapter 14b broken cross-ref), 4 polish (F1 op-onboard inline previews, F2/F3 redundant TL;DRs in op-approach + op-prepare, F7 RECONSTRUCTION L11 forward-pointer). A13 cluster added to `FIXES.md` consolidating the 4 drift items as one apply-section worth of one-line fixes; polish stays in the section file. PF1 (Section-0 sweep "complete and consistent") found partially overstated — three residuals captured (README L14, README L135–143, RECONSTRUCTION L11). Writes confined to the section file + `FIXES.md`; no `chapters/`/`skills/core/`/code/templates edits. Pointer advanced to `audit-02-token-cost` (stub — `/prep` required before Session 1).
- **Audit-02 `/prep` ran (2026-05-28, post-audit-01-close).** Section file re-detailed with Path A (LC1 authorized — runs the spine-on vs spine-off benchmark for real numbers; ~$9–$15 spend) / Path B (static-only, no spend; A1 stays open) branching at Session 1 step 1. Cross-section notes from audit-01 (PF1 methodology implication, F1 cost-data carry-forward) propagated forward into the new file. Write deadlock discovered + worked around: the canonical path `docs/plans/audit-02-token-cost.md` matches the `**/*token*` deny rule (Read AND Bash both blocked, not just Read-glob as audit-05 PF5 originally framed), so Write enforced "Read first" and refused; the workaround was to write to a sibling staging path for user `mv`. Audit-05 PF5 should be re-framed during audit-05 to reflect this (in-band write deadlock when file exists + path matches deny). Pre-flight rule 1 (`/prep <section>` first) now satisfied for audit-02; Session 1 unblocks once the read-deny is lifted.
- **Audit-02-token-cost closed (2026-05-28).** Session 1 executed Path A (LC1 authorized, ~$6.48 total spend). 6 findings (0 blocking, 5 drift, 1 polish). **Headline (F0):** spine-on uses **+75.9% more total input tokens than spine-off** on n=11 paired prompts (+28.6% cost/call; Sonnet 4.6; per-prompt stdev ±110.8%). The headline contradicts the naive "spine saves tokens" framing that load-bearing claim #1 (`CLAUDE.md` L34) ostensibly carries — reframing to "bounded per-load cost + routing accuracy" is the load-bearing apply task at A1 (the per-load shape IS green-zone per F3 — heaviest stack `op-onboard --deep` ≈ 8.2k tokens = 4.1% of Sonnet 200k — so the design constraint is met; the comparative reduction story isn't). Coverage caveat: 8 of 19 prompts are ON-only due to mid-run `claude` CLI upgrade (2.1.153 → 2.1.154 at 21:13) wiping the spine-on phase; recovered via `--only-cond on` re-run. Other findings: F1 spine staleness (22/23 op-* installed at run time; op-approach repo-only; ~0.5% effect on F0), F2 broken-cross-ref in `questions-deep.md` L308-317 (5th item added to A13), F3 heavy-load shape survey (all top-5 stacks green-zone), F4 quantifies audit-01 F1's ~350 tokens/onboarding-load saving, F5 LC1 run-state residue + mid-run upgrade. A1 extended with full results + reframing notes + harness-preflight task (A1 remains "Blocking — before LC5"). A13 extended with F2. Read-only compliance verified by `git diff` against `8ad2c91`: mutations confined to `docs/plans/audit-02-token-cost.md` + `FIXES.md`. Read-deny on `**/*token*` was no longer active at Session 1 execution (lifted between `/prep` and run) — captured in section file Cross-section notes for audit-05 PF5 reframe. Pointer advanced to `audit-03-personalization` (stub — `/prep` required first).
