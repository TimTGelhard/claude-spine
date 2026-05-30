# Changelog

All notable changes to **claude-spine** are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/spec/v2.0.0.html).

`git pull` is the update mechanism — there is no package registry. New entries land at the top.

---

## [Unreleased]

### Added

- **`/explain` slash command + `Explanation style` profile field.** A `/effort`-style dial for how plainly Claude explains its work — `/explain simple|standard|detailed` writes the new `Explanation style` field under `## Output format` in the profile and adopts the style immediately (persist + apply, like `/effort`). New `global/commands/explain.md`; field added to `op-onboard/profile-template.md` (defaults to "Standard" — no new onboarding question, set via the command); consumer documented in `chapters/personalization/19g-field-effects.md` (register/plainness axis, orthogonal to Answer length + Reasoning depth). `simple` also curates to **one clearly-recommended next action** stated as a concrete step (e.g. open a terminal and run `/prep`), alternatives demoted to a line — for non-coders who need an unambiguous "do this next." Slash-command count swept 9 → 10 across `README.md`, `install.sh`, `CLAUDE.md`, `op-welcome/SKILL.md`.
- **Work-shape-aware preparation discipline (Section 0, pre-audit feature).** New `skills/core/op-approach/SKILL.md` (~85 lines, router-shape) auto-fires on big-work phrases — "audit X", "review X", "refactor X", "migrate X", "investigate X", "clean up X", "the project has grown", "where do I start", "how should we approach", "step by step over multiple sessions" — and routes to a new catalog chapter. New `chapters/workflow/05k-work-shapes.md` (~130 lines) — the 7-shape catalog (Build / Audit / Refactor / Migration / Investigation / Research / Cleanup), each with phrasing, default phase order, hard rule, common traps, routes-to. Audit-shape's hard rule (no-apply-between-audits / cross-section coherence) now lives natively in 05k so future users running their own audits inherit the discipline rather than re-stepping on it. Closes the gap a user caught in conversation 2026-05-28: the spine had no trigger that fired the meta-question "what shape is this work, and what's the right phase structure for it?" before execution.
- `global/stacks/ts-next-supabase/flavor-skill/SKILL.md` (~240 lines) and `global/stacks/python-django/flavor-skill/SKILL.md` (~175 lines) — the heavy stack-flavor content that used to sit always-on in the per-stack `CLAUDE.md.template`. Both ship as `~/.claude/skills/op-stack-flavor/SKILL.md` when the user installs with `--stack=<name>`. Trigger descriptions fire on stack-relevant work, security questions, and "is this done?" moments. Closes the deferred Pass-4 P4.

### Changed

- **Skill-trigger descriptions disambiguated (apply-02; closes FIXES A15).** Applied audit-04's 9 disambiguation clauses to 10 op-* `description:` fields + 1 op-workflow `## Sibling skills` bullet — fixing the 7 harmful trigger overlaps (incl. the blocking op-workflow ↔ op-prepare planning misroute, where a user wanting to *plan* could land in op-workflow's concept chapters instead of op-prepare's planning pass) plus 2 description-shape drift items (op-curate-nudge now leads with the default-off bucket-loop gate; op-curate trimmed of body-procedure recap). Every overlap traced to a missing/phrase-invisible "what-it's-NOT-for"; each fix adds a phrase-visible boundary. No SKILL.md *bodies* / `chapters/` / `tests/` touched. The API routing benchmark stays deferred to audit-06's `claude -p` confound fix; polish F10/F11 remain in the audit-04 file. Exact clauses: [`docs/plans/audit-04-skill-triggers.md`](docs/plans/audit-04-skill-triggers.md) § Findings.

- **Token-efficiency claim reframed to bounded-per-load-cost + routing-accuracy (apply-01; closes FIXES A1).** LC1 (Sonnet 4.6, audit-02 Path A) measured the spine at **+76.6 % input tokens / +28.6 % cost-per-call** vs no spine on n=11 paired prompts — refuting the naive "spine saves tokens" framing. `CLAUDE.md:42/44` reframed from "prove the win" / "make context cheaper" to the claim that holds under measurement: bounded per-load cost (heaviest single load ≈ 8.2k tok = 4.1 % of Sonnet's 200k) + routing accuracy (measured by `tests/skill-triggers/`). Results published in `benchmarks/tokens/REPORT.md` (headline + per-load worst-case + caveats + dropped-runs + audit-02 F0 reconciliation); `.err`/unpaired run residue archived under `results/archived-pre-publish/`; `run.sh` gained a `claude` version+mtime preflight aborting on a mid-run binary swap. `README.md:92` / `landing/index.html` / `EXPLAINER.md` confirmed already in the safe lean-on-demand framing, no edit needed.

- **Audit-phase pre-flight protocol added to `docs/PROJECT_PLAN.md`.** Four conditions every fresh audit session must satisfy before executing Session 1: (1) `/prep <section>` first — audit-03..06 ship as ~50-line stubs and must not be executed from the sketch (audit-01 is already detailed and skips this); (2) READ-ONLY for `chapters/` / `skills/core/` / code / templates; (3) heartbeat caveat — Session log `touched:` lines include the entire working-tree dirty state, not per-turn delta, so audit-phase read-only compliance must be verified via `git diff` at `/done`, not by inspecting Session log; (4) cross-section notes propagate manually (next section's `/prep` must copy them forward). One-line pre-flight pointer added to `audit-03..06` so any future cold-start sees the protocol regardless of which audit is active next. `docs/plans/audit-05-self-discipline.md` PF block extended with PF2–PF5 capturing four infrastructure bugs surfaced while running `op-spine-active` on a pending audit section (heartbeat hook delta-tracking, `op-spine-active` stub handler, `/done` section-status sweep, `Read(**/*token*)` deny-rule overreach) — all destined for audit-05 escalation, not the prep pass's fix scope. `docs/plans/section-0-approach-feature.md` Session 1 status corrected (`in-progress` → `done`; closed at Section 0 wrap-up 2026-05-28). `docs/PROGRESS.md` reset to point at audit-01 Session 1 (pending) after a 2026-05-28 audit-phase restart — see `docs/PROJECT_PLAN.md` § Status log for the cleanup record.

- **Anti-drift rule #1 reframed from line-ceiling to queue-shape.** `CLAUDE.md` rule #1 previously said "`FIXES.md` is the open queue, ~70 lines" and the "Never" list said "Re-expand FIXES.md beyond ~100 lines without archive-and-rewrite." That encoded the actual discipline (action queue, not narrative dump) as a magic number — the same anti-pattern rule #10 itself flags. Rewritten to lead with the principle: every entry is a discrete, triageable action item; audit history / rationale / "what we discovered" prose belongs in section Findings tables, `docs/archive/`, or commit-and-PR text. Length is a symptom, not the rule — if 6 audits produce 80 legitimate action items, FIXES carries 80; 80 lines of narrative essays is the failure. Swept to: `CLAUDE.md` rule #1, the "Where things live" table row, and the "Never" list; `docs/PROJECT_PLAN.md` Constraints + Risks; `docs/plans/audit-01-architecture.md` Step 8 + verification check; `docs/plans/audit-05-self-discipline.md` Done criterion.
- **Work-shape cross-references wired (Section 0).** `chapters/workflow/05h-multi-session-planning.md` gained two anti-patterns entries — "Skipping the work-shape assessment" (points to op-approach + 05k) and "Interleaving 'read' and 'mutate' phases across sections (the cross-section coherence trap)" — plus a top-of-Cross-references row for the work-shape assessment. `skills/core/op-prepare/SKILL.md` gained "Work shape is not Build (audit, refactor, migration, investigation, research, cleanup) — op-approach fires before this skill" to its when-NOT-to-fire list, and "Before this fires (for non-build work): op-approach" to its sibling skills. `INDEX.md` Workflow section names op-approach in its routing annotation and gains a new table row for 05k.
- **P4 — per-stack CLAUDE.md split into `op-stack-flavor` skill.** `global/stacks/ts-next-supabase/CLAUDE.md.template` slimmed 258 → 38 lines; `global/stacks/python-django/CLAUDE.md.template` slimmed 197 → 38 lines. The thin stub keeps the eight "I most regret you forgetting" always-on rules + override hierarchy + pointer to the flavor skill. Everything else (how-to-work, decisions, first-touch, workflow, signaling, code output, verification, debugging, stop conditions, stack defaults, full security non-negotiables, project conventions) moved to the flavor skill — on-demand. Pattern: "thin CLAUDE.md, fat skills" (the spine itself teaches it in `chapters/persistence/12b-claudemd.md`).
- `install.sh` — `--stack=<name>` now validates both `CLAUDE.md.template` and `flavor-skill/SKILL.md` exist; refuses an unpaired stack. New section 2b symlinks `global/stacks/<name>/flavor-skill/` → `~/.claude/skills/op-stack-flavor/`. Neutral install branches: if a prior `--stack` left a stale `op-stack-flavor` symlink pointing into this spine clone, it's backed up and removed (so neutral CLAUDE.md doesn't run alongside a leftover flavor skill). `--skip-skills` skips both branches. Summary line and `--help` text updated.
- `uninstall.sh` — `points_into_spine` second check accepts `global/stacks` so the `op-stack-flavor` symlink is removed alongside the other `op-*` symlinks. Stack-flavor removals print `(stack-flavor)` for clarity.
- `tests/installer/test-dry-run.sh` — new assertions: stack-flavor symlink line appears for `--stack=ts-next-supabase` and `--stack=python-django`, does NOT appear for the neutral default, AND does NOT appear when `--skip-skills` is passed alongside a stack. Unpaired-stack rejection covered by the existing `does-not-exist` test (now also covers a `CLAUDE.md.template` without a `flavor-skill/SKILL.md` if one is ever introduced).
- `global/INSTALL.md` + `README.md` — line-count claims, table of installed files, customizing-further section, and the post-install verification flow all updated for the split.

- `RECONSTRUCTION.md` slimmed from 486 → 343 lines (post-launch trim L2 + L3 + L7). The Phase 2–6b decision notes moved to [`docs/archive/RECONSTRUCTION-phases-2026-05.md`](docs/archive/RECONSTRUCTION-phases-2026-05.md); live architectural decisions, progress table, atomic-file map, and install architecture stay in `RECONSTRUCTION.md`. The `#architecture-frozen-decisions` anchor (cross-referenced from `docs/archive/V1-CHAPTERS-DEPRECATED-2026-05.md`) is preserved. The one live cross-chapter link displaced into the archive (`[13d](chapters/persistence/13d-skill-anti-patterns.md)`) was repathed to `../../chapters/persistence/...` so it still resolves; backtick-wrapped descriptive examples render as code regardless of location. The `chapters/prompting/10-visuals.md` `docs/screenshots/foo.png` reference was confirmed as an instructive example showing the user's own convention for project screenshots — not a live cross-reference, no edit needed.

### Fixed

- **Self-tooling discipline — the spine's own workflow machinery brought in line (apply-03; closes FIXES A16).** Five places where the spine didn't live its own discipline, surfaced by audit-05 dogfooding the audit phase. `global/hooks/spine-writeback.sh` heartbeat now logs a **per-turn delta** (per-session `$SESSION_ID.tree` snapshot under `SIGNAL_DIR`; first turn baselines silently) instead of the whole dirty tree, and cue-capture skips its own `## Pending` lines (`tests/hooks/test-spine-writeback.sh` 5→8 assertions). `skills/core/op-spine-active/SKILL.md` Step 2 gained a 4th bullet: a `pending` + stub-marker section halts for `/prep` instead of building from the sketch. `global/settings.json` deny narrowed `Read(**/*token*)` → `Read(**/*_token*)` (underscore-anchored like the `_secret` sibling) + added `Read(**/.env.*)`. `global/commands/done.md` Step 2 no longer assumes an `in-progress`→`done` start (the plan/audit lifecycle is often `pending`→`done`) and makes the section-file-vs-PROGRESS status split explicit. `CLAUDE.md` rule 12 reworded to sanction a registry-citing convenience mirror — resolving its contradiction with `04a`'s deliberately-built table — while still forbidding un-cited duplicates; `04a` + `docs/MODELS.md` refreshed **Opus 4.7 → 4.8** (`claude-opus-4-8`); the `[0.11.0]` `04a` "replaced with pointers" line corrected to match disk (table kept + pointer added). Edits are repo sources — the installed `~/.claude` hook + settings need a re-install to take effect. Detail: [`docs/plans/audit-05-self-discipline.md`](docs/plans/audit-05-self-discipline.md) § Findings.

- **Count-claim sweep across the spine (Section 0).** `CLAUDE.md` "22 op-* routing skills" → "23"; "~80 atomic chapters" → "84" (incorporates the pre-existing tilde-claim drift the sweep uncovered: actual pre-feature count was 83 chapters, docs claimed `~80`, post-feature is exact 84). `README.md` six spots: all "22" → "23", all "~80" → "84", "19 task-routers + 3 ambient" → "20 task-routers + 3 ambient". `install.sh:475` "22 skills" → "23". `skills/core/op-welcome/SKILL.md:31` "22 skills" → "23". `landing/index.html` two spots: "22 op-* skills" → "23", "~80 atomic chapters" → "84". Count claims now read exact numbers (no tilde) for clarity.
- **Stress-test audit drift (2026-05-28) — A7/A8/A9/A10.** From [`docs/evaluation/REPORT-2026-05-28.md`](docs/evaluation/REPORT-2026-05-28.md):
  - **A7** — Hook count drift corrected. `CLAUDE.md:217` + `CHANGELOG.md:35` now read "6 hooks (4 default-on, 2 opt-in)" instead of the inaccurate "6 default hooks + 2 opt-in" (which implied 8 scripts total; actual is 6 — `block-env-staging.sh`, `block-env-commit.sh`, `notify-long-task.sh`, `spine-writeback.sh` default-on; `typecheck-after-edit.sh`, `format-on-save.sh` opt-in).
  - **A8** — Landing page (`landing/index.html:103-105`) re-phrased: chapter folder list extended from 9 → 10 (added `personalization`); the "<150 lines each" claim replaced with "sized to the concept" to match CLAUDE.md's revised stance (`12b-claudemd.md` is 155 lines and that's intentional).
  - **A9** — `RECONSTRUCTION.md:3` freeze line reconciled with the post-freeze "Pre-launch cleanup" section at line 306: now reads "Architecturally frozen 2026-05-27; pre-launch cleanup tracked below," explicitly acknowledging the housekeeping that landed after the architectural freeze.
  - **A10** — `global/INSTALL.md` got a one-line `Write(**)` security note explaining that the default allow rules permit writes anywhere outside the deny list (which catches `.env*`, `**/credentials.json`, `**/*_secret*`, `**/*token*`), so paths like `~/.zshrc` / `~/.ssh/config` are not blocked at the harness level — the harness relies on CLAUDE.md's "Executing actions with care" framing + user review.
- **Stress-test audit A5 — partial fix.** `chapters/personalization/19g-field-effects.md:44` (VCS host row) re-phrased: dropped the false "every chapter that mentions PRs/MRs" claim; kept the real CLI-suggestion + Claude-generated-prose terminology; surfaced chapter source-prose's "PR" lean as a known caveat pointing at FIXES A5 for the full `{{PR_OR_MR}}` sweep across `chapters/workflow/05*` + `chapters/anti-patterns/18g`.
- **Stress-test audit A2.1 — Plans dir (G2) wired end-to-end.** `global/hooks/spine-writeback.sh` gained a `spine_default_str` helper (mirrors `spine_default_int`) and a three-tier plan-layout resolver: project-level `CLAUDE.md` `Plan layout: <dir> <progress-file>` line > profile `Plans dir:` field > the four built-in conventions (`docs/plans/`+`docs/PROGRESS.md`, `docs/specs/`+`docs/PROGRESS.md`, `plans/`+`PROGRESS.md`, `specs/`+`PROGRESS.md`). The hook exits silently when nothing matches. `op-spine-active/SKILL.md` Step 1 grew the same profile-read tier (now 6-layer precedence). `19g:45` documents the precedence chain. `tests/hooks/test-spine-writeback.sh` covers built-in / profile-set / project-override / malformed-profile / unfilled-marker paths (5 cases). Wired into `tests/run.sh`.
- **Stress-test audit A3 — stack-bias stripped from neutral `settings.json`.** Removed: 4 supabase Bash entries, 5 vercel Bash entries, 5 WebFetch domains (`nextjs.org`, `supabase.com`, `vercel.com`, `docs.djangoproject.com`, `fastapi.tiangolo.com`). Moved into `+supabase-stack.json` (Bash entries) / `+vercel-stack.json` (Bash entries) / new `+python-django-stack.json` fragment (the two framework docs domains, paired with the existing `python-django` stack flavor). `global/settings-extras/README.md` "neutral default already covers" list inverted to call out what's stack-specific. `op-onboard/extras-merge.md` gained `django`/`fastapi` keywords for `+python-django-stack.json` detection and bumped the "named fragments" count 8 → 9. `global/INSTALL.md` allowlist descriptions updated to call out fragment-merge as the path for stack-specific CLIs and docs.
- **Stress-test audit A5 — full `{{PR_OR_MR}}` sweep.** Replaced bare "PR" / "pull request" with the literal `{{PR_OR_MR}}` placeholder across `chapters/workflow/05-overview.md`, `chapters/workflow/06-feature-sizing.md`, `chapters/workflow/08c-teaching-unfamiliar.md`, `chapters/anti-patterns/18g-workflow.md`. Substitution rule documented in `op-onboard/handoff.md` (the canonical table — GitHub → "pull request"/"PR", GitLab → "merge request"/"MR", Bitbucket → "pull request"/"PR", local-only → reframe, Other → safe-default) and `op-spine-active/SKILL.md` (where the substitution is applied at chapter-read time). `19g:44` chapter-prose caveat dropped now that the sweep is complete; the row points at the placeholder + the two consumers instead.
- **Stress-test audit A6 — `global/settings.json` defaults lowered to Free-class.** `effortLevel: high → medium`, `autoCompactWindow: 180000 → 120000`. `op-welcome/SKILL.md` greeting block extended with a "Note on defaults" line explaining the Free-class baseline and pointing Pro+ users at `/onboard` to raise. `global/INSTALL.md` "Tuning for Max 20×" section inverted to a "Tuning per plan" table covering Free / Pro / Max 5× / Team / Enterprise / API / Max 20×. `op-onboard/subscription-tune.md` intro + Free-row footnote + explanation-block template re-worded around the Free-class baseline (Free row now matches ship defaults → "no diff, skip silently").
- **Stress-test audit A2.2 — Push-back Q4 wired end-to-end.** Canonical 4 Q4 options (`Just do it` / `Mention concerns, then continue` / `Argue your side` / `Teach me along the way`) now consumed by `op-signaling`: SKILL.md gained Step 0 (Calibrate first) that reads the profile field and loads new chapter `chapters/signaling/11g-push-back-phrasing.md` — a per-Q4 phrasing table (5 signal categories × 4 Q4 values + tone register + example phrasings). `19g:64` Push-back row rewritten to point at 11g + op-signaling Step 0 + the `{{Q4}}` placeholder in both stack templates (option count reconciled 3 → canonical 4). Hard-coded "Spar with me" bullet replaced with literal `{{Q4}}` in `global/stacks/ts-next-supabase/CLAUDE.md.template:16` and `global/stacks/python-django/CLAUDE.md.template:16`. Substitution rule documented inline in `op-onboard/handoff.md` (canonical — 4 verbatim variant strings) and mirrored in 11g + `op-spine-active/SKILL.md` (substitution applies at chapter-read time, never strip the placeholder from source). Meta-scope signals explicitly NOT suppressed by `Q4 = Just do it` — security / data-loss / hard-to-reverse concerns surface regardless of push-back intensity.
- **Stress-test audit A11 — python-django flavor-skill brought to ts-next-supabase parity.** `global/stacks/python-django/flavor-skill/SKILL.md`: Code-output Type discipline expanded (return annotations on public functions mandatory — typechecker fails when missing; no `Any` in public API signatures; no `# type: ignore` without a one-line `# why:` justification naming what's being ignored). New `## Feature-completeness checklist` section inserted between Verification and Stop-conditions: DB constraints (`NOT NULL` / `UNIQUE` / `CHECK` / FK `ON DELETE`), migration paired with rollback plan + `sqlmigrate` review, Serializer + ViewSet + URL consistency, Django admin registration, happy + edge tests, list-endpoint pagination as DoS guardrail, time zones, N+1 audit (`select_related` / `prefetch_related` / `assertNumQueries`). Forbidden list extended 11 → 13 items: per-row authorization left only at view layer without manager / queryset / `DjangoObjectPermissions` enforcement (next view forgets the check); `@csrf_exempt` on session-cookie views without provider-signature verification first.

The open queue (pre-launch checklist + bias-audit residue + remaining A2.3/A2.4, A4, A12) lives in [`FIXES.md`](FIXES.md).

---

## [0.11.0] — 2026-05-28

Pre-launch consolidation: bias-audit rounds 4–7, Pillar 1 Sessions 2 + 3, Pillar 3 (workflow auto-inference), Pillar 6 P6.4 + P6.5 (opt-in hooks), L4b/L4c benchmark harness, and a doc cleanup that archived five frozen-in-time docs and slimmed `FIXES.md` from 2300 → ~70 lines.

Counts at the cut: 22 op-* skills, 9 slash commands, 6 hooks (4 default-on, 2 opt-in), 80 chapters, 10 essentials + 18 deep + up to 2 conditional + 2 hook prompts.

### Added

- `docs/MODELS.md` — Anthropic model + plan-tier registry; single source of truth replacing duplicated names across chapters / templates / benchmarks.
- `chapters/personalization/19g-field-effects.md` — every profile field → its consumers + behavior change.
- `skills/core/op-onboard/extras-merge.md` — opt-in `permissions.allow` + `permissions.WebFetch` merge from `settings-extras/+*.json`, driven by Q3/Q8/Q9 answers.
- `skills/core/op-onboard/questions-deep.md` Section W — conditional W1 (Deploy target) + W2 (Database default), asked only when Q9 is a UI-bearing artifact.
- `chapters/workflow/06-feature-sizing.md` Session-types section — Build / Debug / Refactor / Explore / Review / Explain shapes with per-shape "done" criteria.
- `global/settings-extras/` (8 JSON fragments + README) — drop-in allowlists for GitLab / Bitbucket / Vercel / Supabase / AWS / GCP / Azure / Docker-k8s.
- `global/hooks/typecheck-after-edit.sh` + `format-on-save.sh` — opt-in PostToolUse hooks wired by `/onboard --deep` (P6.4 + P6.5).
- Workflow auto-inference (Pillar 3): turn counter + cross-session-note capture + long-session signal in `spine-writeback.sh`; `op-prepare` Step 6 split into scope inference / verify scaffolds / compose; `/done` Step 9 next-section nudge.
- `benchmarks/tokens/` — token-efficiency harness + eval-set + aggregator (L4c).
- `tests/onboard/test-extras-merge.sh` (8 cases); hook fixtures wired into fast suite (L4b followup).
- `INDEX.md` — routing-skill annotation under each section heading (M7).
- `op-hooks/SKILL.md` — preview table of the 6 spine-shipped hooks (M8).

### Changed

- **Bucket loop default flipped `on` → `off`.** Profile template, onboard H1 ordering, and field-absent fallbacks in `op-suggest` / `op-curate-nudge` / `op-bucket-router` all default off.
- **`op-onboard` split** into adjacent files (subscription-tune, hook-tune, extras-merge, handoff); SKILL.md routed from 286 → ~100 lines (M5).
- **Settings.json mutation** in `hook-tune.md` switched from Edit-slice to `jq --argjson hooks` — survives user-reformatted JSON (N5).
- **Onboard expanded:** essentials 7 → 10 (+OS, +VCS host, +Artifact); deep 13 → 18; total 20 → 28 + up to 2 conditional + 2 hook prompts.
- **Subscription tune** Q1 = `Other` now resolves to per-tier mapping (Team / Enterprise / API / Bedrock / Vertex / OpenRouter / pay-as-you-go) instead of silent-skip.
- **Anti-patterns 18a / 18c / 18e softened** — strong-defaults framing, edge cases named, per-artifact verification recipes (UI / CLI / library / backend / data-ML).
- **Chapter prose generalized** off Next/Supabase/Stripe in 12b / 05b / 05c / 06 / 15h / 02 / 03a / 03b / 03c / 13c. 03c "handles well" list broadened 6 web-leaning → 11 (CLI, library, docs, data, tests).
- **`op-prepare/procedure.md`** — Step 6.1 8-stack per-row file-shape table; Step 6.2 7 concept-first verify patterns (Auth flow / Per-row authorization / CRUD resource / Public form / Webhook ingestion / Migration-only / CLI subcommand / Library public method).
- **Templates** — main `templates/{CLAUDE,ARCHITECTURE,DEPLOY,SMOKE_TESTS,DECISIONS,PROJECT_BRIEF,FEATURES,PROJECT_PLAN}.md` made stack-agnostic; worked Next/Supabase examples moved to `templates/examples/web-saas-next-supabase/`.
- **`global/opinionated/` → `global/stacks/ts-next-supabase/`** + sibling `global/stacks/python-django/`; `install.sh` gained `--stack=<name>` flag (with `--opinionated` backward-compat alias).
- **`spine-writeback.sh`** writes `docs/.spine-parse-error` when PROGRESS.md format drifts; `/done` Step 0 and `/spine` section 8 surface the marker; auto-cleared on next successful parse (N2).
- **`global/settings.json`** broadened: Bash allowlist 60 → 78 entries (added cargo / go / mvn / gradle / bundle / composer / mix / swift / deno / bun / make); WebFetch 12 → 32 domains across major language ecosystems; Vercel + Playwright + frontend-design plugins flipped to default-off.
- **`op-onboard/handoff.md`** — reports actual per-fragment merge state and Section W answers verbatim.
- **`op-spine-active`** accepts four plan-layout conventions plus a project-level `Plan layout:` CLAUDE.md override (N6).
- **Q3 restructured** to product-shape families (Web apps / Mobile + desktop / Backend services + CLIs / Data + ML); B2 "stacks to avoid" reduced to free-text only.

### Removed

- Static `CHEATSHEET.md` (archived) — `/spine` command does the job dynamically.
- `BIAS-AUDIT.md`, `LAUNCH.md`, `V1-CHAPTERS-DEPRECATED.md`, `docs/SUBSCRIPTION-AWARENESS.md`, `docs/clean-room-install-report.md` — all archived to `docs/archive/` (frozen point-in-time docs).
- `FIXES.md` 2300-line audit history archived to `docs/archive/FIXES-rounds-1-5-2026-05.md`; new repo-root `FIXES.md` is ~70 lines of open queue only.
- Pillar 5 (`op-persistence`, `op-signaling`) trigger descriptions tightened with literal phrase examples + NOT-for clauses.

### Fixed

- `uninstall.sh` only removed 1 of 6 installed hooks — swept to the same loop `install.sh` uses (H5).
- Stale skill / hook / question / chapter count claims swept across README, EXPLAINER, install.sh, INSTALL.md, 19b, /onboard command description.
- `bucket/README.md:35` reversed-meaning rule rewritten (M9).
- `op-curate-nudge` dual-schema fallback dropped — fail-loud on unrecognized format (N3).
- `op-suggest` missing-marker failure path specified — append to `## Pending`, restore marker (N4).
- `chapters/foundations/04a-model-tiers.md` — registry pointer to `docs/MODELS.md` added (the ID table is kept as a sanctioned convenience mirror; the registry wins on conflict); `global/stacks/*/CLAUDE.md.template` — model IDs replaced with a pointer to `docs/MODELS.md`. Both prevent date-rot.

### Verification

- Fast suite: 6 sub-suites, 65 cases (12 block-env-staging + 12 block-env-commit + 14 typecheck-after-edit + 12 format-on-save + 8 extras-merge + 7 installer-dry-run).

---

## [0.10.0] — 2026-05-28

Closes the six pre-launch pillars plus the L10 ambient workflow refactor + onboarding subscription awareness. Personalization is wired; first-run discovery exists; capture/curate has closure; two default-on safety hooks ship plus a `/hooks` command; the workflow runs through ambient cold-start instead of explicit session-boundary commands.

Counts from 0.9.0 → 0.10.0: 19 → 22 op-* skills, 8 → 9 slash commands.

### Added

- `skills/core/op-spine-active/` — ambient cold-start skill, auto-fires when `docs/plans/` + `docs/PROGRESS.md` exist (L10).
- `skills/core/op-welcome/` — first-run greeting that points new users at `/onboard` (Pillar 4).
- `skills/core/op-curate-nudge/` — single-fire reminder when 5+ pending and last curate >30 days ago (Pillar 2).
- `chapters/personalization/19f-subscription-aware.md` — 8 levers × 4 plan tiers + cost-sensitivity modifier (Pillar 1 Session 1).
- `global/commands/done.md` — session-end with verify checklist + commit suggestion (L10).
- `global/commands/spine.md` — one-shot discovery: live skills, commands, profile path, chapter root (Pillar 4 P4.2).
- `global/commands/hooks.md` — list every hook configured for the session (Pillar 6 P6.3).
- `global/hooks/spine-writeback.sh` — Stop-hook that rolls turn heartbeats into the active section plan (L10).
- `global/hooks/block-env-commit.sh` — `git commit` guard against staged `.env*` (Pillar 6 P6.1).
- `global/hooks/notify-long-task.sh` — cross-platform notification on long Notification events (Pillar 6 P6.2).
- `chapters/workflow/05j-cold-start-protocol.md` — ambient cold-start contract (L10).
- `bucket/INDEX.md` `Last fired:` column + stamping in `op-bucket-router` (Pillar 2 P2.2).
- Onboarding subscription awareness — Q1 plan / 0A daily usage / 0B cost sensitivity captured in profile.

### Changed

- `op-foundations` / `op-tools` / `op-subagents` / `op-signaling` — all read `19f-subscription-aware.md` and branch on `Plan:` + `Cost sensitivity:` (Pillar 1).
- `op-persistence` + `op-signaling` trigger descriptions tightened with literal user-phrase examples + NOT-for clauses (Pillar 5).
- `op-onboard/handoff.md` — terse three-bullet farewell replaced with structured "what happened / what's available / what to do next" block (Pillar 4 P4.3).
- `op-onboard` post-essentials proposes `autoCompactWindow` + `effortLevel` tune sized to Q1 plan.
- Q5 split into Q5a (Answer length) + Q5b (Reasoning depth); essentials 5 → 7.
- 18 v1 root stubs deleted (`01-first-principles.md` … `18-anti-patterns.md`); bodies preserved in `docs/v1-archive/`. Pre-launch cleanup.
- `docs/JANITOR.md`, `docs/archive/PLAN-AMBIENT-WORKFLOW-2026-05.md`, `docs/archive/PERSONALIZATION-plan-2026-05.md` — older planning + audit docs moved to `docs/archive/`.
- `CHANGELOG.md` cut from a single `[Unreleased]` block into the `[0.10.0]` release.

### Removed

- `/session-start` + `/session-end` slash commands (L10.1) — superseded by `op-spine-active` ambient cold-start + `/done`.

### Fixed

- `op-spine-active` ambient flag — Stop-hook ordering bug where the heartbeat wrote to the wrong section when `/done` had just fired and the user immediately started new work (L10.1 followup).

---

## [0.9.0] — 2026-05-27

First tagged release. Architecture frozen, personalization loop shipped, plan-driven workflow shipped, clean-room install verified, self-tests passing. Awaiting public launch (L7a / L7c / L7d / L7e).

### Added

#### v2 architecture

- **80 atomic chapter files** under `chapters/<topic>/`, one concept per file (~150-line ceiling, real-seam decomposition). Index at [`INDEX.md`](INDEX.md); inverse map at [`V1-CHAPTERS-DEPRECATED.md`](V1-CHAPTERS-DEPRECATED.md).
- **19 core skills** in `skills/core/op-*/` — pure routers from task intent to the right atomic file(s). None hold chapter content; SKILL.md bodies stay 34–65 lines. `op-prepare` and `op-curate` are folder skills (router `SKILL.md` + adjacent procedure file) when the procedure runs long.
- **5 personalization chapters** (`chapters/personalization/19a`–`19e`) — net-new in v2.
- **Plan-driven workflow.** Adds `skills/core/op-prepare/SKILL.md` + three new workflow chapters (`05h-multi-session-planning.md`, `05i-execution-plan-anatomy.md`, `05j-cold-start-protocol.md`) + three new templates (`PROJECT_PLAN.md`, `SECTION_PLAN.md`, `PROGRESS.md`) + three slash commands (`/prep`, `/session-start`, `/session-end`) + `init.sh` to scaffold project docs from templates.

#### Personalization loop

- `op-onboard` — first-run interview, writes `~/.claude/claude-spine-profile.md` (5 essentials + opt-in `/onboard --deep` for the full set). Re-runnable via `/onboard` or `/onboard --deep`.
- `op-suggest` + `/suggest` — capture friction during normal sessions to `bucket/SUGGESTIONS.md`. Locked four-condition trigger (explicit user signal, 2+ repeat friction, end-of-session reflection, explicit command).
- `op-curate` + `/curate` + `/curate --review-stale` — review pending suggestions, apply or reject, with hard refusals on `chapters/`, `skills/core/`, profile, and global stub.

#### Personal skill library ("the bucket")

- `bucket/` ships empty by design. Each user builds their own library.
- `op-add-skill` + `/add-skill` — gated skill-creation (3+-paste-in rule from [`13d-skill-anti-patterns.md`](chapters/persistence/13d-skill-anti-patterns.md)).
- `op-bucket-router` — fallback router. Reads `bucket/INDEX.md` (auto-maintained) only when no core skill matched.
- `/refresh-bucket` — rebuilds `bucket/INDEX.md` from disk; preserves `Added` dates.

#### Installer + global

- `install.sh` — self-locating, idempotent, backs up overwritten files to `~/.claude-backup-<ts>/`. Symlinks `~/.claude/skills/op-*` → `<spine>/skills/core/op-*` so `git pull` propagates instantly. Flags: `--dry-run`, `--opinionated`, `--keep-legacy`, `--skip-{global,skills,commands,settings,hook}`. macOS + Linux; Windows redirected to WSL.
- `uninstall.sh` — removes spine-owned symlinks only. Leaves `CLAUDE.md`, `claude-spine-profile.md`, `bucket/`, and `settings.json` in place.
- `global/neutral/CLAUDE.md.template` — thin stub (default install).
- `global/opinionated/CLAUDE.md.template` — founder-flavored example (`./install.sh --opinionated`).
- `global/settings.json` — `effortLevel: "high"`, `autoCompactWindow: 180000`, opinionated `permissions.allow` (TS / Next.js / Supabase / Vercel — trim to fit your stack).
- `global/hooks/block-env-staging.sh` — denies `git add .env*` patterns via the PreToolUse hook protocol.

#### Tests + CI

- `tests/hooks/test-block-env-staging.sh` — 12-case fixture (6 should-block, 6 should-allow).
- `tests/installer/test-dry-run.sh` — 48-assertion sweep across 7 install scenarios (default, `--opinionated`, legacy cleanup, `--keep-legacy`, every `--skip-*`, `--help`, unknown-flag rejection). Isolates `HOME` to a temp dir.
- `tests/skill-triggers/` — skill-description benchmark harness using the `skill-creator` plugin. Documented bias toward under-counting routing-skill TP; reliable for FP regression detection.
- `.github/workflows/test.yml` — runs the fast suites (hook + installer) on push to `main` and on pull requests.

#### Documentation

- `README.md` — public-facing entry point (install → first session → architecture).
- `INDEX.md` — atomic-file router map (topic → file).
- `V1-CHAPTERS-DEPRECATED.md` — inverse map (v1 chapter → v2 atomic files).
- `CONTRIBUTING.md` — single-maintainer policy, what's welcome / unlikely, commit style.
- `EXPLAINER.md` — long-form architecture for skeptics.
- `RECONSTRUCTION.md` — v2 build history (Phases 0–8e), frozen architectural decisions.
- `docs/archive/PERSONALIZATION-plan-2026-05.md` — personalization loop design (Phase 8 planning doc, archived 2026-05-27 once the loop shipped).
- `LAUNCH.md` — gap-fixing roadmap from v2 to public launch.
- 9 project-doc templates under `templates/` (project CLAUDE.md, PROGRESS.md, DECISIONS.md, FEATURES.md, ARCHITECTURE.md, PROJECT_BRIEF.md, SMOKE_TESTS.md, DEPLOY.md, SESSION_STARTER.md).

### Changed

- 18 root-level v1 chapter files (`01-first-principles.md` through `18-anti-patterns.md`) are now one-line redirect stubs pointing at the v2 atomic location and at the archived body in [`docs/v1-archive/`](docs/v1-archive/). Bodies preserved for external-link compatibility but moved one folder deeper so the repo root no longer carries 18 deprecation-header files. New work should read the v2 atomic files in `chapters/`.
- The four legacy `op-manual-*` skills (`op-manual-workflow`, `op-manual-tactics`, `op-manual-templates`, `op-manual-recovery`) are superseded by the 18 `op-*` skills. `install.sh` removes the legacy directories from `~/.claude/skills/` and backs them up; `--keep-legacy` opts out.
- `global/settings.json` defaults — `effortLevel` `"xhigh"` → `"high"` and `autoCompactWindow` `800000` → `180000`. The Pro-burning defaults were never the right floor; Max-plan users opt up via the new "Tuning for Max 20x / 1M context" section in `global/INSTALL.md`.
- 14 skill descriptions previously referenced "Claude Code Operator's Manual" (the pre-v2 project name) → swept to `claude-spine`. Cross-references in `op-anti-patterns`, `op-subagents`, `op-persistence`, `op-signaling` to the old `op-manual-*` skill names → swept to current names (or to direct template-folder pointers in the `op-persistence` case).
- `chapters/anti-patterns/18f-security.md` rewritten to be self-contained — no longer references "your global CLAUDE.md" for the forbidden list. `chapters/foundations/04c-budget-and-cost.md` now points at 18f directly. A neutral-stub installer no longer hits a dead reference.

### Fixed

- `global/hooks/block-env-staging.sh` — regex boundary for the leading path prefix was `(\./)?` but the hook's documented patterns included `git add foo/.env.local`. Widened to `(.*/)?` so any leading path is matched. Surfaced by the new hook fixture; covered by 6 should-block + 6 should-allow assertions.

### Decided (no code change)

- **No skill-sharing platform.** The bucket is each user's personal toolbox. There is no curated examples folder, no GitHub topic convention, no Discussions. Rationale in [`README.md`](README.md) and [`bucket/README.md`](bucket/README.md); the speculative-library trap argument lives in [`13d-skill-anti-patterns.md`](chapters/persistence/13d-skill-anti-patterns.md). Revisitable if real user volume produces sustained pressure.
