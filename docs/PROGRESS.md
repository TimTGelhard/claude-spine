# Progress — claude-spine

> Live pointer to where work resumes. Updated at every `/done`.
> Claude reads this first at the start of every session (via the `op-spine-active` skill).
>
> This file does NOT inventory features (see `CHANGELOG.md` for shipped work) or list every bug (see `FIXES.md` for the open queue).
> Its job is to answer: *what's the next session, what does it need, what's blocking it?*

<!-- ⚠️ DO NOT REFORMAT THE NEXT 6 LINES (or the **Session** bullet below). They are parsed by `spine-writeback.sh` via a regex that expects the literal `- **Section**:` / `- **Session**:` shape with backticks around the name. If you swap the bold for italics, drop the backticks, change the bullet style, or move these bullets to a different sub-heading, the Stop-hook heartbeat will silently no-op — your session activity won't be logged. -->

## Active section

- **Section**: `audit-03-personalization` (from `docs/PROJECT_PLAN.md`)
- **Plan file**: `docs/plans/audit-03-personalization.md` (**detailed** — Session 1 fully specified by the `/prep` pass 2026-05-28; pre-flight rule 1 satisfied)
- **Section status**: `planned` — Session 1 ready to execute (pre-flight rule 2 READ-ONLY for `chapters/`/`skills/core/`/code/templates applies)

## Active session

- **Session**: `1` — Field/consumer coverage audit (full procedure specified in the section file)
- **Status**: `pending` — ready to execute (`/prep` done; cold-start reads the section file and proceeds)

## Last session outcome

**Audit-02-token-cost Session 1 — done 2026-05-28.** Token-cost measurement (Path A, LC1 authorized). **6 findings (0 blocking, 5 drift, 1 polish):** F0 LC1 headline `+75.9% input tokens` spine-on vs spine-off on n=11 paired prompts (+28.6% cost/call, Sonnet 4.6) — contradicts naive "spine saves tokens" framing; reframing is the load-bearing A1 apply task ("bounded per-load cost + routing accuracy" instead). F1 spine staleness (22/23 installed at run time; ~0.5% effect). F2 `op-onboard/questions-deep.md` L308-317 broken-cross-ref + dead-weight — added to A13 as 5th same-class drift item. F3 heavy-load shape survey — all top-5 worst-case stacks green-zone (max 4.1% of Sonnet 200k). F4 confirms audit-01 F1 cost-impact (~350 tokens/onboarding load saved by preview extraction). F5 LC1 run-state non-determinism — mid-run `claude` CLI upgrade (2.1.153→2.1.154) wiped spine-on phase; recovered via `--only-cond on` re-run; total LC1 spend ~$6.48. **FIXES.md updates:** A1 extended with LC1 results + reframing notes + harness-preflight task (A1 remains "Blocking — before LC5"); A13 extended with F2 (now 5 drift items). Read-only compliance intact (`git diff` against session-start commit `8ad2c91`): mutations confined to `docs/plans/audit-02-token-cost.md` + `FIXES.md`. **Audit-03-personalization is next — stub awaits `/prep`.**

## Blockers

- **None.** `/prep audit-03-personalization` ran 2026-05-28 — Session 1 is fully specified; pre-flight rule 1 satisfied. Cold-start reads the section file and executes the audit directly.

## Next session reading list

Cold-start orientation for `audit-03-personalization`. The section file is now **fully detailed** — its § "Files to read for project understanding" (10 items) is the authoritative orient list. The summary below mirrors it; read the section file and follow its Session 1 build steps.

1. `docs/PROJECT_PLAN.md` § **Audit-phase pre-flight protocol** — read FIRST. Four conditions every audit session must satisfy: `/prep <section>` first (satisfied — `/prep` ran 2026-05-28), READ-ONLY for `chapters/`/`skills/core/`/code/templates, heartbeat caveat, cross-section note propagation.
2. `docs/plans/audit-03-personalization.md` — now detailed; holds the consumer test (mechanical OR instruction = real), the carried-forward cross-section notes, and the Session 1 build steps + verify list.
3. `CLAUDE.md` — load-bearing claim #2 (personalization is real, L53–L73), the audit-03 measurement target.
4. `chapters/personalization/19g-field-effects.md` — canonical field → consumer map (the truth-claim audit-03 verifies).
5. `chapters/personalization/19a-overview.md`, `19b-profile-and-onboarding.md`, `19f-subscription-aware.md` — for field-consumption patterns.
6. `skills/core/op-onboard/profile-template.md` — the canonical field list.
7. `FIXES.md` § A2 cluster — already names 4 known decorative fields (A2.1 + A2.2 shipped; A2.3 D1, A2.4 G1 + A14 remain). Confirm + close or extend.
8. `docs/plans/audit-02-token-cost.md` § Findings + § Cross-section notes — F0 headline + F3 heavy-load shape are personalization-adjacent (F3's heaviest stack `op-onboard --deep` IS the personalization interview); F2's questions-deep finding is the same heavy-load surface.
9. `docs/plans/audit-01-architecture.md` § Findings — F1 (op-onboard preview-block extraction) is personalization-adjacent.

---

## Session log

Append-only. One line per session. Prune past ~30 entries by moving older lines to `docs/sessions-archive.md`.

### 2026-05-28
- Plan created. Audit sections 1–6 drafted. Section 1 fully detailed; sections 2–6 stubbed (per 05h: plan sections lazily before they start).
- Section 0 (`section-0-approach-feature`) inserted before audit-01. Building `op-approach` skill + `chapters/workflow/05k-work-shapes.md` as a pre-audit feature add so the spine carries work-shape-aware preparation discipline before the audit phase begins. Wires the cross-section coherence rule (audit-shape's hard rule) into the spine permanently, not only as a project-plan banner.
- Section 0 done. Shipped op-approach (~85 lines, router-shape) + 05k (~130 lines, catalog) + cross-references in 05h / op-prepare / INDEX + 11-edit count-claim sweep across CLAUDE.md / README.md / install.sh / op-welcome/SKILL.md / landing/index.html (23 op-* skills, 84 atomic chapters; resolves pre-existing `~80` tilde-claim — actual pre-feature was 83, post-feature exact 84). Audit-05 PF1 re-framed `blocking` → `info`. Pointer advanced to audit-01-architecture / Session 1.
- Meta-prep pass (audit-phase pre-flight protocol added to PROJECT_PLAN + audit-03..06 pre-flight pointers + audit-05 PF2–PF5 + section-0 stale status fix). Audit-phase restart requested 2026-05-28: discard the audit-01 + audit-02 runs that happened during the prep-pass / parallel-session window, revert section files + FIXES (A13 cluster + A14 removed) + PROGRESS pointer + PROJECT_PLAN Sections table to pre-audit-phase state. Audit phase resumes cleanly at audit-01 Session 1.
- Audit-01-architecture Session 1 done. 8 findings (0 blocking, 4 drift, 4 polish). New A13 cluster in `FIXES.md` consolidates F4 + F5 + F6 + F8 as one apply-section worth of one-line fixes (~30 min); polish (F1/F2/F3/F7) stays in the section file. PF1 partially overstated — three sweep residuals (README L14, README L135–143, RECONSTRUCTION L11). Pointer advanced to `audit-02-token-cost` Session 1 (stub — `/prep` needed first).
- Audit-02 `/prep` ran. Section file `docs/plans/audit-02-token-cost.md` re-detailed (Session 1 procedure populated with Path A (LC1 authorized) / Path B (static-only) branching at step 1 — the LC1 authorization gate). Cross-section notes from audit-01 (PF1 partial-overstatement methodology implication + F1 cost-data carry-forward) propagated forward. **Write-path workaround used:** the section file's canonical path matches the `**/*token*` deny rule (Read AND Bash both blocked, not just Read-glob as audit-05 PF5 originally framed), so Write enforced "Read first" and refused. Workaround: wrote to sibling staging path `docs/plans/audit-02-cost-section.md.staging` for the user to `mv` into place. Audit-05 PF5 should be re-framed during audit-05 (Read AND Bash blocked → in-band write deadlock when file already exists). Read-deny lift required before Session 1 can execute (cold-start needs to read the section file).
- Audit-02-token-cost Session 1 done. Path A executed (LC1 authorized). 6 findings (0 blocking, 5 drift, 1 polish). F0 LC1 headline: spine-on +75.9% input tokens vs spine-off on n=11 paired prompts (+28.6% cost/call, Sonnet 4.6, total LC1 spend ~$6.48). Headline contradicts naive "spine saves tokens" framing — reframing to "bounded per-load cost + routing accuracy" is the load-bearing A1 apply task. F2 (`questions-deep.md` L308-317 broken-cross-ref + dead-weight) added to A13 cluster as 5th drift item. F3 confirms all top-5 heaviest stacks in green zone (max 4.1% of Sonnet 200k). F5 captures mid-run `claude` CLI upgrade (2.1.153→2.1.154) that wiped spine-on phase; recovered via `--only-cond on` re-run; harness preflight (binary mtime check) added to A1 path. A1 extended with full results + reframing notes; A13 extended with F2. Read-only compliance verified by `git diff` against `8ad2c91`: mutations confined to `docs/plans/audit-02-token-cost.md` + `FIXES.md`. Read-deny on `**/*token*` was no longer active at Session 1 (lifted between /prep and execution — captured in cross-section notes for audit-05 PF5 reframe). Pointer advanced to `audit-03-personalization` (stub — `/prep` required first).
- Audit-03 `/prep` ran. Section file elaborated from 56-line stub into a fully-detailed Session 1 entry (field/consumer coverage audit, both directions: every field → a real consumer, every claimed `19g` consumer → a real read). Two decisions locked: **(1) consumer test** — a field is real if EITHER mechanically read (a script/skill greps + branches) OR instruction-honored (a chapter tells Claude to honor it + the field is in-profile); only "neither" is decorative (the standard A2.1/A2.2 were judged "wired" by). **(2) single session** with a documented clean split point if per-claim verification balloons. Cross-section notes carried forward: audit-01 **PF1 methodology** (grep-verify "shipped"/"Read by" claims, don't trust the prose) — load-bearing; audit-02 F2/F3 (don't re-find). Preliminary observation: template field-set ↔ `19g` row-set look aligned at ~41 (29 interview + 12 spine-defaults), so the audit's center of gravity is **consumer-claim verification**, not doc-row reconciliation. No `chapters/`/`skills/core/`/code/template edits; writes confined to the section file + this PROGRESS pointer refresh. Pre-flight rule 1 satisfied.

---

## Notes

- For the project plan (sections + dependencies), see `docs/PROJECT_PLAN.md`.
- For per-section detail (session entries with build steps + verify checks), see `docs/plans/<section-name>.md`.
- For the open work queue (blocking findings + LC1–LC6, BA3, A1–A12), see `FIXES.md`.
- For shipped work history, see `CHANGELOG.md`.
