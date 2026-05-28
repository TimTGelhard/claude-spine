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

- **A2 — Wire the four decorative personalization fields end-to-end.** `19g` claims named consumers; the consumers don't read the fields. The right move is to make `19g` *true*, not to strike rows from it. A2.1 + A2.2 shipped 2026-05-28 — see CHANGELOG `[Unreleased]`. Two sub-projects remain, sequenced cheapest-to-hardest so each builds on the last:
  - **A2.3 — Active signals (D1) into `op-signaling`** *(~2h, requires design)*. The field captures which proactive signals the user actually wants to hear ("context filling," "scope creeping," "verify before move-on," etc.). Design: D1 is a checklist of signal categories; `op-signaling` reads the list and gates which trigger phrases fire. Add a `Signal categories` table in `chapters/signaling/11f-active-signals.md` (or similar) with canonical category names + 1-line definitions; D1 in `questions-essential.md` / `questions-deep.md` becomes a multi-select against this canonical list. `op-signaling/SKILL.md` Step 1 reads D1 and skips categories the user has unchecked.
  - **A2.4 — Session shape (G1) into `op-collaboration-modes` + `op-workflow`** *(~3h, the most complex)*. `06-feature-sizing.md:9-17` names six session shapes (Build / Debug / Refactor / Explore / Review / Explain); the scaffolding is one-shape (Build). Design: G1 sets a default shape; `op-collaboration-modes` + `op-workflow` route to shape-specific guidance. For non-Build shapes, document what the equivalent of `/prep → ambient → /done` looks like (or honestly: "the plan-driven scaffolding doesn't apply — here's the discipline that does"). At minimum, make `op-workflow` SKILL.md branch on G1 so the user gets shape-relevant chapter routing. **Re-anchor target (A14 resolved 2026-05-28 as option b — dual taxonomy):** G1 enumerates `05k`'s **seven planning-shapes** (Build / Audit-or-review / Refactor / Migration / Investigation-or-debug / Research-or-spike / Cleanup-or-janitor). `op-workflow` looks up per-shape sizing via the A14 mapping table (which points into `06-feature-sizing.md`'s sizing rows; gaps are noted inline in 05k). Sequence A14 first — A2.4's G1 routing depends on the mapping table existing.

### Serious — universality

- **A4 — Ship at least one non-web worked example under `templates/examples/`.** Escalates BA3 (above) from pull-driven to launch-blocking. **Path:** ship `templates/examples/cli-tool/` first (cheapest). Contents: `README.md` describing the example stack (suggest: a small Go or Rust CLI with a `<verb> <flags>` surface), `CLAUDE.md` (project-level, ~30 lines), `docs/PROJECT_BRIEF.md`, `docs/PROJECT_PLAN.md`, `docs/PROGRESS.md`, one section file under `docs/plans/`, and `docs/DEPLOY.md` (binary release via GitHub Releases — different from the web example's continuous-deploy). After CLI: `templates/examples/library-publish/` (npm or PyPI, one variant) is the next-cheapest second variant. Each variant should be a real-shape example — not a stub. Audit's "loudest 'this is for web devs' signal" — fix it.

### Long-term — parity + verification

- **A12 — Ship `/profile verify` command.** **Path:** new `global/commands/profile-verify.md` (read-only command). Walks `~/.claude/claude-spine-profile.md` field by field; for each row in `chapters/personalization/19g-field-effects.md`'s tables, greps the named consumers (file paths + skill names) for the field key. Reports per-field: `✓ consumer present at <path:line>` or `✗ consumer missing — see FIXES Aₓ`. Optional `--fix` flag could open the matching FIXES section. Closes the "I changed X and nothing happened" trap that `19g` exists to prevent. ~1.5–2h. Dependency: nice-to-have *after* A2.1–A2.4 land, since most decorative rows will resolve to ✓ once those ship.

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
