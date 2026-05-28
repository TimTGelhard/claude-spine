# Changelog

All notable changes to **claude-spine** are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/spec/v2.0.0.html).

`git pull` is the update mechanism — there is no package registry. New entries land at the top.

---

## [Unreleased]

### Bias-audit + FIXES sweep — round 6 (2026-05-28)

Pre-launch cleanup of the BIAS-AUDIT Priority-2/3 residuals that weren't already shipped or deferred to a separate session. Five items land together: a single source of truth for Anthropic models + plan tiers, sensible defaults for `Other` (Team / Enterprise / API / Bedrock / Vertex / OpenRouter / self-hosted) instead of silent-skip, anti-pattern softening across the remaining catalog entries that read as universal laws, session-type framing for `06-feature-sizing.md`, and the bucket-loop default flip from `on` to `off`.

#### Added

- `docs/MODELS.md` (new) — single source of truth for Anthropic model IDs (Opus 4.7 / Sonnet 4.6 / Haiku 4.5 lineup, current 1M-context variant, older-release rows kept for cross-reference) and Claude plan tiers (Free / Pro / Max 5× / Max 20× / Team / Enterprise / API / Bedrock / Vertex / OpenRouter / self-hosted-gateway). Chapters and templates link here instead of duplicating names; a "Runtime constants (intentionally pinned, may lag this file)" section lists the four places where runtime defaults live in source (`tools/token-check.py`, `benchmarks/tokens/run.sh` + README, `tests/skill-triggers/README.md`) so a maintainer doing a model-rename sweep has the punch list in one place. Closes BIAS-AUDIT P3 #15.

#### Changed

- `chapters/foundations/04a-model-tiers.md` — table caption now points at `docs/MODELS.md` as the canonical registry; "Related" section adds a row pointing there. Mirrors the registry; if the two disagree, the registry wins.
- `global/stacks/ts-next-supabase/CLAUDE.md.template` + `global/stacks/python-django/CLAUDE.md.template` (the two shipped stack stubs) — the "Anthropic API" line no longer hard-codes the model IDs in marketing prose. Now reads "Default model: the current Sonnet ID per `docs/MODELS.md` (today `claude-sonnet-4-6`); escalate to the current Opus ID (today `claude-opus-4-7`) only for hard multi-file reasoning." Same advice, single source of truth, no date-rot when Anthropic ships Sonnet 4.7.
- `chapters/personalization/19f-subscription-aware.md` — `Other`-plan handling rewritten. The single-line "treat like Max 20× unless cost-aware" rule expanded into a canonical mapping (Team → Pro; Enterprise → Max 5×; API / pay-as-you-go / Bedrock / Vertex / OpenRouter / self-hosted → cost-sensitivity-dependent: Pro if Very careful, Max 20× if Don't worry, Max 5× if Balanced). Mirrors `docs/MODELS.md`'s plan-tier registry. Closes BIAS-AUDIT P3 #16 (the audit's "subscription Other branch defaults" item).
- `skills/core/op-onboard/subscription-tune.md` — mapping table extended with four new rows (Team / Enterprise / API+cloud-passthrough / Other-anything-else) plus a case-insensitive substring-match flow for the free-text Q1 answer. Team → Pro-class settings (180000 / high); Enterprise → mid-class (400000 / high); API / Bedrock / Vertex / OpenRouter / pay-as-you-go → mid-class (same). Anything that doesn't match a trigger silent-skips with a hand-tune pointer at `docs/MODELS.md` + INSTALL. The Edit-based flow itself is unchanged (the N5 round-5 jq-merge applies to hook tuning, not subscription tuning).
- `skills/core/op-onboard/questions-essential.md` — Q1 free-text hint expanded with the recognized triggers so a user re-running `/onboard` sees what answers the spine will branch on.
- `chapters/anti-patterns/18a-prompting.md` — opening framing softened from `"never do this" reference` to `"a catalog of prompting patterns that fail in the contexts this spine targets ... strong defaults, not universal laws — most have an edge case where they're the right move."` Same entries, conditioned framing. Closes BIAS-AUDIT P3 #13 for 18a.
- `chapters/anti-patterns/18c-context.md` — `cat` entry gets an edge-case note: `cat` is fine in shell pipelines (heredoc input, etc.); the anti-pattern is using it to *look at* a file. Closes P3 #13 for 18c.
- `chapters/anti-patterns/18e-verification.md` — "Declaring a UI feature done without running it in a browser" generalized to "Declaring a feature done without seeing it work" with per-artifact verification recipes (UI / CLI / library / backend service / data-or-ML). The browser-only framing was a leak. Closes P3 #13 for 18e. (The two-session auth/RLS check stays a hard no-exceptions rule — security-class absolute, intentional.)
- `chapters/anti-patterns/18d-tools.md`, `18f-security.md`, `18h-long-term.md`, `18-meta-patterns.md` — audited; entries already either explicitly conditioned or security-class absolutes. No edits.
- `chapters/workflow/06-feature-sizing.md` — new "Session types — sizing isn't one shape" section near the top with a six-row table (Build / Debug / Refactor / Explore / Review / Explain) covering what "done" looks like, what to count for sizing, and whether the existing capacity table applies. Existing capacity table re-labeled as "Concrete capacity for a build session." "What you should NOT try to do in one session" → "Combinations that almost always degrade" with explicit "valid edge case" framing and three new non-web rows (public API + migration; CLI subcommand + rename; ML experiment + pipeline refactor). Closes BIAS-AUDIT P2 #9. Universal "one cohesive goal" principle was already softened in round 3; this completes the framing.
- **Bucket-loop default flipped `on` → `off`.** `skills/core/op-onboard/profile-template.md` `## Spine defaults` line, `skills/core/op-onboard/questions-deep.md` H1 option order, `skills/core/op-suggest/SKILL.md` + `skills/core/op-curate-nudge/SKILL.md` + `skills/core/op-bucket-router/SKILL.md` field-absent fallback all now default to `off`. README's two bucket-loop mentions reframed: opt-in flywheel, "default off after the round-6 flip." Existing users with `Bucket loop: on` in their profile keep the loop running; new users get spine + profile only unless they opt in via `/onboard --deep` H1 or hand-edit. Closes BIAS-AUDIT P2 #11.

#### Verification

- Fast suite (`tests/run.sh`) — re-run after the round-6 edits; expected 57/57 (no test fixtures touched; documentation + skill bodies + one template field flip + one registry doc only).
- Manual smoke: `op-onboard` re-run mentally walked end-to-end — Q1 with free-text `Team` resolves to Pro-class settings tune; Q1 with `API` resolves to mid-class; `Anonymous-corp custom plan` silent-skips with hand-tune pointer. `19f`'s lever-1 table no longer goes blank on `Other`. `06-feature-sizing.md` build-session table still anchors correctly; debug / refactor / explore / review / explain rows give the reader a recognizable shape without misapplying the capacity numbers.

#### What's deliberately deferred

- **N2 (YAML frontmatter parser for PROGRESS.md)** — the marker comment + `.spine-parse-error` surface are sufficient for now; YAML migration only earns its keep if real-session data shows the marker insufficient.
- **C-block (command consolidation 9 → 6)** — significant UX change; needs broader sign-off before shipping.
- **B10 (Windows-native installer)** — stretch goal; opens a meaningful percentage of the addressable user base but is a half-day-to-a-day of work and needs Windows test capacity the maintainer doesn't have today.
- **B11 (i18n hook in onboarding)** — deferred per finding; revisit when adoption signals localization is worth it.
- **P4 (per-stack CLAUDE.md split into `op-stack-flavor`)** — the two stack variants under `global/stacks/` work as is; further splitting into thin-CLAUDE.md + on-demand flavor skill is a larger architectural pass.
- **`/profile explain <field>` standalone command** — the round-4 19g chapter covers the same need via documentation; the command is polish.

### Doc cleanup — 2026-05-28

Followed the existing `docs/archive/` pattern (JANITOR / PLAN-AMBIENT-WORKFLOW / PERSONALIZATION) for three frozen-in-time documents that were still living at the repo root or under `docs/`. Goal: one source of truth for the open fix queue (`FIXES.md`), no point-in-time audits cluttering the live surface.

#### Changed

- **`BIAS-AUDIT.md` archived** → `docs/archive/BIAS-AUDIT-2026-05.md`. The original full-repo bias audit. The bulk of its findings shipped across rounds 1–5 of `FIXES.md`. The residue is folded into `FIXES.md` as a new "Pass 5 — folded from the archived BIAS-AUDIT" section with five labeled items (`BA1`–`BA5`); a parallel sweep on 2026-05-28 shipped `BA2` (Anthropic model registry — new `docs/MODELS.md`), `BA4` (subscription Other branch in `op-onboard/subscription-tune.md` + Q1 free-text mapping), and most of `BA5` (anti-pattern softening across 18a / 18c / 18e + a new Session-types section in `chapters/workflow/06-feature-sizing.md`). `BA1` (conditional deep questions for web/mobile) and `BA3` (per-platform DEPLOY variants) remain open. Cross-references in CHANGELOG / global/settings-extras/README / round narratives unchanged — they cite `BIAS-AUDIT P0 #3`, `P3 #14` etc. as stable section IDs that still resolve inside the archived file.
- **`docs/SUBSCRIPTION-AWARENESS.md` archived** → `docs/archive/SUBSCRIPTION-AWARENESS-2026-05.md`. The Pillar 1 planning doc; all three sessions shipped (the live mechanic is `chapters/personalization/19f-subscription-aware.md` + the four routing skills wired to it). Path references in CHANGELOG + FIXES updated to the archive path so links still resolve.
- **`docs/clean-room-install-report.md` archived** → `docs/archive/clean-room-install-report-2026-05.md`. The frozen `LAUNCH.md` phase-L5 verification report. Verdict at the time ("installer is launch-ready"); kept as evidence, not a live spec. LAUNCH.md path references updated.

#### Net effect

- Repo root markdown files: 11 → 10 (BIAS-AUDIT moved out). FIXES.md grew by one Pass-5 section folding in the five still-open items.
- `docs/` live files: 2 → 0. `docs/` now contains only `docs/archive/` and `docs/v1-archive/`.
- Single source of truth for the open fix queue: `FIXES.md`. Anything that was actionable in `BIAS-AUDIT.md` is now either landed in a round or named in Pass 5 as a `BA*` item.

### Bias-audit + FIXES sweep — round 5 (2026-05-28)

The programmatic settings-extras inject layer that round 4 left as future work. Three connected items shipped together: **N5** (jq-based `settings.json` mutation in `op-onboard`), **VCS-host auto-merge** (`+vcs-gitlab.json` / `+vcs-bitbucket.json` proposed in `/onboard --deep` when Q8 matches), and **per-stack auto-merge** (the six `+<platform>-stack.json` fragments proposed when Q3 / B1 / Q9 free-text mentions the platform). All three feed through a new `extras-merge.md` adjacent file with explicit Apply/Skip per fragment — never silent, always per-fragment.

#### Added

- `skills/core/op-onboard/extras-merge.md` (new on-demand file) — owns the detection + per-fragment merge flow. Detects fragments from Q8 (VCS host = GitLab → `+vcs-gitlab.json`; Bitbucket → `+vcs-bitbucket.json`) and from case-insensitive substring scans of Q3 / B1 / Q9 free-text (`vercel`, `supabase`, `aws`, `gcp`/`google cloud`/`firebase`, `azure`, `docker`/`kubernetes`/`k8s`). Per-fragment plain-English explanation block + `AskUserQuestion` Apply/Skip. On Apply runs the same `jq` merge as the manual command in `settings-extras/README.md` (atomic `.tmp` + `mv`, `jq empty` gates input and output). Hand-edit fallback when `jq` fails or the merge produces invalid JSON. Already-merged fragments (full set-difference empty) silent-skip so re-runs are idempotent.
- `tests/onboard/test-extras-merge.sh` (new fixture, wired into `tests/run.sh`) — 8 cases: happy-path merge / idempotency / missing-key resilience (`// []` fallback) / all 8 shipped fragments valid JSON / two-fragment sequential merge / malformed settings.json fails fast. Mirrors the shape of the existing hook fixtures.

#### Changed

- `skills/core/op-onboard/hook-tune.md` (**N5**) — replaced the Edit-based PostToolUse insertion with a `jq --argjson hooks` set. Pre-flight inspects the live `PostToolUse` shape: absent OR matcher `Edit|Write|MultiEdit` with only spine-named scripts ⇒ safe to merge; anything else ⇒ Hand-edit fallback. The new path survives user-reformatted JSON (the Case A/B/C slice-match fragility is gone). Same Apply/Skip discipline, same fail-fast behavior. The G1/G2 question text was lightly broadened to reflect the round-2 hook-detection expansion (TypeScript / Python with mypy → pyright → ruff → py_compile / Go / Rust / Ruby / PHP / C# for typecheck; ~14 language detection paths for format).
- `skills/core/op-onboard/SKILL.md` — adjacent-files table gains a row for `extras-merge.md` (step 8). Existing handoff step renumbered 8 → 9. "Write surface is allow-listed" rule extended to a third permitted surface: append-only additions to `permissions.allow` and `permissions.WebFetch`, sourced exclusively from the eight files under `global/settings-extras/+*.json`, deduplicated via `jq unique`. The `/onboard --deep` preview block in step 1 now mentions the Apply/Skip prompts the user will see for any matching fragment.
- `skills/core/op-onboard/handoff.md` — VCS-host line and a new Stack-extras line both report **actual per-fragment state** (`merged` / `declined` / `not suggested`) rather than the round-4 "we suggested this — go merge it yourself" framing. Updated hard-rule #6 explains that the lines must reflect the Apply/Skip answers captured during the extras-merge pass.
- `global/settings-extras/README.md` — "How fragments relate to `op-onboard`" rewritten: the "Future work — opt-in `--apply-extras` flag" paragraph removed, replaced with the now-shipped flow (detection from Q3/Q8/Q9, per-fragment Apply/Skip, idempotent re-runs). The "Never auto-merge" rule softened to "Never silent-merge — explicit Apply/Skip required either inside `/onboard --deep`'s extras-merge pass or via a hand-run `jq` command outside it." Append-only / no-new-top-level-keys / one-fragment-per-layer rules unchanged.
- `tests/run.sh` — header comment updated to list the new `onboard/test-extras-merge.sh` suite. Suites array gains the new entry. The fast suite is now 6 sub-suites instead of 5.
- `FIXES.md` — Pass-4 status preamble updated to reflect N5 + VCS-auto-merge + per-stack-auto-merge as shipped in round 5. The "What remains" list trims accordingly; "Shipped vs remaining" table moves the three items from `Remaining` to `Shipped`.

#### Verification

- `tests/onboard/test-extras-merge.sh` — 8/8 pass standalone (happy-path / idempotency / missing-key resilience / fragment validity / two-fragment sequential / malformed-input fail-fast).
- Full fast suite (`tests/run.sh`) — see end-of-session log; no regressions expected from the changes (the only modified hook fixture is the new one).

#### What's deliberately deferred

These remained un-shipped this round per the FIXES.md audit's own recommendation:

- **C-block** (command consolidation 9 → 6) — needs broader sign-off; the existing 9 commands aren't a launch blocker.
- **B10** (Windows-native installer) — half-day to full-day effort; stretch goal.
- **B11** (i18n hook in onboarding) — deferred per the original finding.
- **P4** (per-stack CLAUDE.md split into `op-stack-flavor` skill) — two stack variants already exist under `global/stacks/`; the further "thin CLAUDE.md, fat skills" refactor is a larger architectural pass.
- **U-block** `/profile explain <field>` standalone slash command — the `19g-field-effects.md` chapter (round 4) covers the same need via documentation; the standalone command is polish.

### Bias-audit + FIXES sweep — round 4 (2026-05-28)

A focused follow-through pass against the remaining Pass-3 / Pass-4 items in `FIXES.md`. The earlier rounds shipped most of the BIAS-AUDIT and FIXES backlog (op-onboard split, profile-settable thresholds, neutral templates, broadened settings.json, the 8-question onboard expansion, etc.); this round closes the smaller-but-visible gaps left over.

#### Added

- `chapters/personalization/19g-field-effects.md` (new chapter — **U5**) — reference table mapping every profile field to the chapters / skills / hooks that consume it AND the user-visible behavior change to expect. Closes the "I changed X and nothing seems different" complaint pattern. INDEX.md gets a new row under Personalization; `op-onboard/handoff.md` cross-references it as the answer to "what does each field actually change?". No new command.
- `global/settings-extras/` (new directory — **B6 follow-up / VCS-host wiring**) — opt-in drop-in JSON fragments for stack-specific or VCS-host-specific Bash + WebFetch allowlist entries. Ships with `README.md` (manual + `jq` merge command, validated end-to-end) plus 8 fragments: `+vcs-gitlab.json`, `+vcs-bitbucket.json`, `+vercel-stack.json`, `+supabase-stack.json`, `+aws-stack.json`, `+gcp-stack.json`, `+azure-stack.json`, `+docker-k8s-stack.json`. Never auto-merged — explicit user action only. Closes the BIAS-AUDIT B6 follow-up "per-stack inject path" item at the floor level (fragments shipped as files; programmatic inject from `/onboard` remains future work).

#### Changed

- `INDEX.md` (**M7**) — each `## <Section>` heading now carries a one-line italic annotation naming the routing skill(s). Foundations → `op-foundations`; Workflow → `op-workflow` + `op-prepare` + `op-brownfield` + `op-collaboration-modes` + ambient `op-spine-active`; Prompting → `op-prompting` + `op-visuals`; Signaling → `op-signaling`; Persistence → `op-persistence` + `op-hooks`; Tools → `op-tools`; Subagents → `op-subagents`; Recovery → `op-recovery`; Anti-patterns → `op-anti-patterns`; Personalization → `op-onboard` + bucket-loop trio + bucket-router. Closes the M7 gap (Claude falling through to INDEX manually couldn't tell where the routing skill lived).
- `skills/core/op-hooks/SKILL.md` (**M8**) — Index table gains a third row pointing at `~/.claude/settings.json` / `/hooks` for "what hooks does claude-spine ship?". New "Spine-shipped hooks (default install)" subsection lists all six scripts with event + behavior, marking the two opt-in PostToolUse hooks (typecheck / format) as wired by `/onboard --deep` only.
- `global/hooks/spine-writeback.sh` (**N2**) — parse-error surface added. When PROGRESS.md exists but the Section / Session bullets can't be extracted AND no `<section-name>` / `<N>` template placeholders remain, the hook now writes `$CWD/docs/.spine-parse-error` describing the missing bullet shape, the consequences (heartbeats / cue capture / long-session signal silently no-op until fixed), and a pointer to `templates/PROGRESS.md`. On the next successful parse, the marker is removed automatically. Template-state (`<section-name>` still present) continues to exit silently — only real format drift writes the marker. Smoke-tested across drift / fix / template-state cases.
- `global/commands/done.md` (**N2 — surface**) — new Step 0 "Parse-error preflight" reads `docs/.spine-parse-error` if present, surfaces its contents verbatim, and notes that heartbeats this session were not logged (the hook silently no-opped) so Step 3's rollup will be lean. Offers to fix the bullets immediately so the next assistant turn clears the marker.
- `global/commands/spine.md` (**N2 — surface**) — new section 8 "Parse-error surface" reads `docs/.spine-parse-error` and prints a one-line warning with the marker contents indented. The only line `/spine` is allowed to emit that isn't pure inventory — it surfaces a silent failure mode the user otherwise has no way to notice.
- `skills/core/op-onboard/SKILL.md` (**U4**) — Step 1 "Print the preview block" expanded from a one-line text to a structured preview in a fenced block. Lists the question themes by group (subscription + experience / what you build / how I should talk / environment for essentials; plus daily usage / coding background / secondary stack + avoid / team + scale / signals / output + risk / session + plans / org + currency for deep) and explicitly says Cmd+C is safe — essentials save after Q9 so nothing is lost if the user stops in the deep block. Same shape for both `/onboard` and `/onboard --deep`.
- `skills/core/op-onboard/handoff.md` — VCS-host line now points at `global/settings-extras/+vcs-gitlab.json` / `+vcs-bitbucket.json` as the concrete merge artifact, not just "add `Bash(glab:*)` to settings". Adds a final paragraph cross-referencing `19g-field-effects.md` for "what each profile field actually changes".
- `global/INSTALL.md` — `~/.claude/settings.json` review section gains a sixth bullet covering the optional `settings-extras/` fragments (when to merge, how to merge, the never-auto-merged stance).
- **B9 — foundations + persistence chapter audit** (the un-audited tail of the BIAS-AUDIT chapter-prose pass):
  - `chapters/foundations/03c-project-fit.md` — "Project types Claude handles well" list broadened from 6 web-leaning entries to 11, explicitly naming **CLI tools with a bounded command surface**, **Library / framework design**, **Documentation, content, and config projects**, **Data scripts and notebook → script consolidation**, and **Test suites and fixtures** as strong fits. "Greenfield MVPs" gains a parenthetical noting the discipline applies across web SaaS, backend services, CLIs, and libraries — not only the canonical web shape.
  - `chapters/foundations/03a-hard-limits.md` — version-specifics example generalized from "Next.js 16 specifics, library APIs that changed last month" to "a framework's latest major-version specifics, library APIs that changed in the last few months, breaking changes in a runtime release."
  - `chapters/foundations/03b-soft-limits.md` — debugging-hop example generalized from "Webhook from Stripe → ngrok → Next.js → Supabase" to "Webhook from a payment provider → tunnel (ngrok / Cloudflare Tunnel / smee) → your web framework → your datastore."
  - `chapters/foundations/02-context-budget.md` — survives-compaction example generalized from "(we chose Supabase over Firebase)" to "(we chose Postgres + RLS over Firestore + rules", "we picked a managed BaaS over rolling our own auth)."
  - `chapters/persistence/13c-skill-design-patterns.md` — pre-deploy-audit worked skill description now reads "this project's stack (substitute your real stack here — e.g. 'Next.js + Supabase project' or 'Django + Postgres service')" instead of hard-coding the Next + Supabase example.
- `FIXES.md` — status header at the top of Pass 4 updates the "Remaining" table: M7, M8, N2 (visible failure mode), U4, U5, B9 (rest), VCS-host wiring, and per-stack settings extras all annotated `[shipped 2026-05-28]`. Pass-4 totals and Pass-3 PR-7 footnote updated.

#### Verification

- `tests/run.sh` — fast suite: **57/57 pass** across 5 sub-suites (no regressions from the hook or INDEX changes).
- `global/hooks/spine-writeback.sh` — manual smoke test of N2 across three cases:
  1. **Format drift** (bold → italic on Section / Session bullets) → `.spine-parse-error` written, content names the missing bullet shape and the silenced subsystems.
  2. **Fix applied** (bullets restored) → marker auto-removed on the next successful Stop event.
  3. **Template state** (`<section-name>` placeholder still present) → no marker written; silent exit as before.
- `global/settings-extras/+vcs-gitlab.json` — merge command from `README.md` executed against a synthetic settings.json — output preserves non-merge keys (e.g. `effortLevel`) and uniques both `permissions.allow` and `permissions.WebFetch`. All 8 JSON fragments validated with `jq empty`.

#### What's deliberately deferred

These remained un-shipped this round per the FIXES.md audit's own recommendation:

- **C-block** (command consolidation 9 → 6) — needs broader sign-off; the existing 9 commands aren't a launch blocker.
- **B10** (Windows-native installer) — half-day to full-day effort; stretch goal, not in this round's scope.
- **B11** (i18n hook in onboarding) — deferred per the original finding (not urgent until adoption signals localization is worth shipping for).
- **N5** (jq-based `settings.json` mutation in `op-onboard`) — current Edit-based path works under the now-split `op-onboard/hook-tune.md`; a `jq` rewrite is a minor robustness gain, not visible to users.
- **P4** (per-stack CLAUDE.md split into `op-stack-flavor` skill) — two stack variants already exist under `global/stacks/`; the further "thin CLAUDE.md, fat skills" refactor is a larger architectural pass.
- **Onboard-driven auto-merge of settings-extras** — current floor is the fragments exist as files; programmatic merge from `/onboard --deep`'s Q3/Q8/Q9 answers is the next layer up.

### Pillar 1 — Personalization payload (Sessions 2 + 3 of 3)

Session 1 (in `[0.10.0]`) shipped `chapters/personalization/19f-subscription-aware.md` and wired four routing skills to it. The chapters those routers point *into*, though, still read generically — a Free user reading `04a-model-tiers.md` got the same "default to Sonnet" framing as a Max 20× user with cheap Opus access. Session 2 closes that gap by adding bidirectional cross-references from five high-leverage chapters back into 19f, so the per-plan branch surfaces wherever a generic recommendation sits.

Session 3 closes the personalization payload — a read-through verification across all four plan tiers (Free / Pro / Max 5× / Max 20×) and a docs sweep that surfaces the subscription line in the prompting examples chapter. No new shipping artifacts; this is the wrap-up pass. The verification was done by reading 19f + the four routers + the five cross-referenced chapters with each plan tier in mind — no cross-reference drift found, one wording fix in 19f (the `code-review` / `loop` / `schedule` slash commands are external plugin skills, not routing skills, so the previous phrasing was inaccurate).

#### Changed

- `chapters/foundations/04a-model-tiers.md` — new "Plan-aware default" subsection between the mental rule of thumb and Related. Two paragraphs + a link into 19f (lever 1). Related section grows one bullet.
- `chapters/foundations/04b-plan-and-fast-mode.md` — fast-mode section gains one paragraph framing the per-plan stance (occasional treat for Free / Pro, default for Max). Related section grows one bullet.
- `chapters/foundations/04c-budget-and-cost.md` — "Plan budgets" section adds one paragraph pointing at 19f as the authoritative per-plan recommendation source, since 04c already enumerates plan tiers but doesn't surface the per-plan defaults table.
- `chapters/subagents/16c-parallel-and-background.md` — new "Plan-aware fan-out budget" subsection after Anti-patterns, with the four-row fan-out table (Free / Pro / Max 5× / Max 20×) and the `Cost sensitivity` modifier rule. TL;DR gains one bullet.
- `chapters/signaling/11-overview.md` — "five signal categories" framing preserved, with a clarifying line that cost/quota is cross-cutting, not a sixth category. New "Cost / quota signals" subsection between Anti-patterns and TL;DR — four-row decision table (Max 20× + Don't worry / Pro/Max 5× + Balanced / Free or Very careful / profile missing) for whether to flag, with 19f as the alternative-suggestion table.
- `chapters/prompting/09c-examples-and-anti-examples.md` — new "The subscription line — read from your profile, not your prompt" section between the high-leverage patterns and the visuals section. Shows the same `/code-review ultra` question producing different answers for a Free vs Max 20× profile, names the eight per-plan levers, and gives two practical consequences (keep `/onboard` fresh; override per-prompt when needed). TL;DR gains one bullet. *(Session 3 — the `09-prompting` examples update from the planning doc.)*
- `chapters/personalization/19f-subscription-aware.md` — fixed a stale lever-3 link (`16d-parallel-and-background.md` → `16c-`) and clarified the "How to consult this chapter" wording: the `code-review` / `loop` / `schedule` slash commands are external plugin skills, not editable from the spine, so the per-plan branch reaches them indirectly through `op-tools` and `op-signaling` (both wired in Session 1). The link fix shipped in Session 1; the wording clarification is the Session 3 sweep.
- `docs/archive/SUBSCRIPTION-AWARENESS-2026-05.md` — status header marks all three sessions done.
- `FIXES.md` — status header drops Pillar 1 Session 3 from the open queue. P1.1 entry annotation updated to credit Sessions 2 + 3.

No new files. No skill changes (the four routers were already wired in Session 1). No INDEX update needed (19f row was already present from Session 1).

### Pillar 3 — Workflow auto-inference

Five attention points the ambient workflow used to leak into the user's head — scope, verify, next-section prep, cross-session notes, session size. Each was inferable from existing signal (build steps, recognized patterns, PROGRESS.md state, turn text, turn count). Pillar 3 closes them with zero new user-facing commands: it extends `op-prepare`, `/done`, and the existing Stop hook. The cold-start protocol now goes beyond "load orientation + announce scope" — it also proposes scope from build steps, scaffolds verify from a pattern catalog, offers next-section prep at completion, captures cue-phrase candidates per turn, and flags long sessions mid-flow.

FIXES.md originally tagged Pillar 3 as post-launch ("needs real-user signal on which inferences are right"). The ~half-day estimate held; the cue-phrase set and long-session thresholds remain straightforward to tune once real-session data accumulates.

#### Changed

- `skills/core/op-prepare/procedure.md` — Step 6 restructured into three sub-steps:
  - **Step 6.1** (P3.1) — after drafting build steps, propose the **Files to write/edit** list from a heuristics table (schema → migration with RLS inline; "Add API route" → `app/api/<x>/route.ts`; "Add server action" → `app/<route>/actions.ts`; UI step → `page.tsx` + component; "Add zod schema" → `schema.ts`; webhook → `app/api/webhooks/<service>/route.ts`; public flow → `app/(public)/<route>/page.tsx`; "Send email" → `lib/email/templates/` + `lib/server/email.ts`). The proposal is editable, not auto-applied.
  - **Step 6.2** (P3.2) — when build steps + scope match a recognized pattern, scaffold the **Verify** block from a seven-row catalog: **Auth flow**, **CRUD resource**, **API + UI**, **RLS section**, **Public form**, **Webhook ingestion**, **Migration-only session**. Each scaffold lists 3-5 concrete checks the user refines. Prevents the generic "test it works" verify failure mode.
  - **Step 6.3** — compose the entry. Past 100 lines, split.
- `templates/SECTION_PLAN.md` — Verify-section instruction points at `op-prepare` procedure §6.2 for pattern scaffolds, so a fresh user doesn't default to "test it works".
- `global/commands/done.md`:
  - **Step 2** (P3.4) — reviews the `## Pending cross-session notes` block written by the hook. For each entry: promote (move to **Cross-session notes** above, edit if needed), dismiss, or edit-then-promote. Default to dismiss for noise. Deletes the Pending block after review.
  - **Step 4 + Step 9** (P3.3) — when the next section has no plan file, `/done` now offers *"Section `<next-section>` has no plan file. Run `/prep <next-section>` now? (Y/n)"* rather than silently noting it in PROGRESS.md. On `Y`, hands off to `op-prepare`. On `N` or no answer, leaves the PROGRESS.md breadcrumb so the next ambient `op-spine-active` halts cleanly with the same suggestion.
- `global/hooks/spine-writeback.sh` — three-block restructure (heartbeat / cue-capture / long-session), all running on the same Stop event:
  - **Heartbeat** — behavior unchanged. Appends one line per file-changing turn to `## Session log` in the active section file, with idempotency guard.
  - **Cue-capture** (P3.4) — reads `transcript_path` from the hook input JSON, locates the most recent `"type":"assistant"` JSONL entry via awk, extracts text content via `jq`, and greps for a tight cue set (`cross.?session note`, `follow.?up:`, `for (the |a )?(next|later|future) session`, `FYI for next session`, `note for next session`, `need to … in/before (next|later|future) session`, `schema (will need|needs to)`, `carry.?over:`). Up to 5 matches per turn, deduped against the section file, appended to `## Pending cross-session notes`. Set is intentionally tight — bias against noise.
  - **Long-session signal** (P3.5) — increments a per-session-id counter under `$TMPDIR/spine-signals/<session_id>.turns` on every Stop event. Records first-turn epoch under `<session_id>.start`. When count ≥ 30 OR elapsed ≥ 2h, emits once per session: *"spine: past typical session size (N turns, Mm elapsed). split now or push? — see chapter 06 (feature sizing)."* Single-fire guarded by `<session_id>.long-session` marker. Ephemeral state — no repo pollution, no gitignore needed.
- `FIXES.md` — status header drops Pillar 3 from the open queue; each P3.X entry annotated with `[shipped 2026-05-28 — landed in [Unreleased]]`; Suggested apply order item #10 annotated done.

#### Implementation notes

- No new skill, slash command, or settings.json hook entry. Pillar 3 is strictly additive behavior inside files that already shipped.
- The heartbeat block no longer early-exits on "no files changed" — cue-capture and long-session need to run regardless. Heartbeat append is now gated by a local conditional; behavior at the file level is unchanged.
- Long-session counter increments on every Stop event, not only file-changing turns, so a 30-turn conversational session still trips it.
- macOS `awk`, `sed`, and `grep` compatibility verified (`bash -n` clean). The hook uses bash-specific features (here-strings, `${var:0:N}` substring); shebang is `#!/usr/bin/env bash`.

### Pillar 6 — Opt-in onboard-deep hooks (P6.4 + P6.5)

Pillar 6 in `[0.10.0]` shipped three default-on items (block-env-commit, notify-long-task, `/hooks`) and left P6.4/P6.5 deferred behind a "needs deeper onboard-deep extension" caveat. This entry closes that gap. The extension is: deep mode now ends with a two-prompt **Hook tuning** pass that can write PostToolUse hooks (typecheck-after-edit, format-on-save) into `~/.claude/settings.json` with the same Apply/Skip discipline as the existing subscription-based settings tune. Both hooks ship pre-built under `global/hooks/` and are symlinked by `install.sh`; the settings.json entry is the on/off gate. Default-off; opt-in only via `/onboard --deep`.

The hooks are deliberately advisory (never block edits), narrowly scoped (only fire on `Edit|Write|MultiEdit`), and silent when their preconditions aren't met (no tsconfig in the tree → no typecheck; no `[tool.black]` → no Black). The goal is "match the project's existing discipline on each edit", not "impose a style on every project".

#### Added

- `global/hooks/typecheck-after-edit.sh` — PostToolUse hook (default-off). Reads `tool_input.file_path` from stdin; for `.ts`/`.tsx` walks up to the nearest `tsconfig.json` and runs `tsc --noEmit --incremental -p <tsconfig>` (prefers project-local `node_modules/.bin/tsc`, falls back to PATH); surfaces only errors mentioning the edited file (project-wide noise predates the edit and is suppressed). For `.py` runs `python -m py_compile` (syntax-only — fast). Failures go to stderr; the hook exits 0 always (advisory, never blocks).
- `global/hooks/format-on-save.sh` — PostToolUse hook (default-off). Detects the formatter from the project's config files walking up from the edited file: Prettier (`package.json` with `node_modules/.bin/prettier` or PATH `prettier`), Black (`pyproject.toml` with `[tool.black]` + PATH `black`), gofmt (`go.mod` + PATH `gofmt`), rustfmt (`Cargo.toml` + PATH `rustfmt`). Silent skip when the project doesn't have a formatter configured. Exit 0 always.
- `tests/hooks/test-typecheck-after-edit.sh` — 11-case fixture. PATH-shims `tsc` so the test doesn't require a real TypeScript install; covers TS-error-mentioning-edited-file (surfaces), TS-error-elsewhere (suppressed), TS-clean (silent), TS-no-tsc-on-PATH (silent), TS-no-tsconfig-in-tree (silent), Python syntax error (surfaces), Python clean (silent), `.md` ignored (silent), and three input edge cases (empty stdin, missing `file_path`, file_path pointing at non-existent file).
- `tests/hooks/test-format-on-save.sh` — 12-case fixture. PATH-shims each formatter via marker-touching scripts so we can assert which one ran without depending on real installs. Covers local prettier wins over global, global prettier fallback, `.ts` without `package.json` (silent), `.py` with `[tool.black]` (formats), `.py` without `[tool.black]` (silent even with shim), `.py` with `[tool.black]` but no black binary (silent), `.go` + `go.mod` (gofmt runs), `.rs` + `Cargo.toml` (rustfmt runs), `.xyz` (silent), and three input edge cases.

#### Changed

- `skills/core/op-onboard/SKILL.md`:
  - **`## Hook tuning (deep mode only)`** — new ~140-line section parallel to "Subscription-based settings tuning". Defines the per-hook pre-flight (read settings.json → skip if missing → skip if hook already wired → check `PostToolUse` shape), the two questions G1 + G2 with their plain-English explanation blocks, the writing logic (Case A: full insert when no `PostToolUse` exists; Cases B/C: hand-edit fallback when the existing block isn't a shape this skill owns), and the hand-edit fallback message verbatim.
  - **Mode selection bullet 3** — adds "+ 2 opt-in hook prompts" to the `/onboard --deep` description.
  - **Adjacent files table** — `questions-deep.md` row notes the 2 hook prompts live in SKILL.md.
  - **"How to run the interview" step list** — new step 6 ("If deep ran: run the Hook tuning pass"). Old step 6 becomes 7.
  - **"Write surface is allow-listed" rule** — expanded from "two keys" to "two write surfaces": (1) the two settings keys, (2) the `hooks.PostToolUse` block under matcher `Edit|Write|MultiEdit` containing only the two spine-named scripts. Explicit per-run approval required for both surfaces.
  - **Handoff template** — new `Opt-in hooks:` line in the "Here's what just happened" block with five state variants (both on / typecheck on / format on / declined both / already configured); deep-profile skipped-branch text mentions the 2 hook prompts.
- `skills/core/op-onboard/questions-deep.md` — new `## Then — Hook tuning (writes to settings.json, not the profile)` cross-reference section after the optional Notes follow-up, pointing at SKILL.md `## Hook tuning (deep mode only)`. Explains *why* those two questions live in SKILL.md and not here (they affect settings.json, not the personal profile).
- `skills/core/op-onboard/questions-essential.md` — the deep-interview offer text now mentions the 2 opt-in hook prompts ("Want to answer 13 more questions … Plus two optional opt-ins at the end for auto-typecheck and auto-format hooks").
- `chapters/personalization/19b-profile-and-onboarding.md` — new "Hook tuning (2 opt-in prompts at the end of deep, writes to settings.json — not the profile)" section under "What it captures"; "How to run it" table row for `/onboard --deep` mentions the 2 prompts; TL;DR bullet acknowledges them.
- `FIXES.md` — status header drops P6.4 + P6.5 from the open queue (open queue now: P4.4 + L2–L8 only); P6.4 and P6.5 entries annotated `[shipped 2026-05-28 — landed in [Unreleased]]`; Live counts on disk updated (hooks 4 → 6); Suggested apply order item 11 annotated done.

#### Implementation notes

- **Default-off is the contract.** Both hooks ship as files in `global/hooks/` and get symlinked into `~/.claude/hooks/` by `install.sh`, but the `settings.json` entry is the on/off gate. A fresh install has the scripts on disk and inert; only `/onboard --deep` (or hand-editing settings.json) wires them.
- **Advisory, never blocking.** Both hooks `exit 0` unconditionally — failures go to stderr but the edit always stands. `set -uo pipefail` (NOT `set -e`) so a parse failure exits silently rather than blocking Claude.
- **Fail-fast on settings.json format drift.** The skill's allow-listed Edit targets the canonical pre-PostToolUse block shape; if a user reformatted settings.json the Edit doesn't match and the skill falls to the hand-edit fallback rather than retrying with looser matching. Matches the discipline of the subscription-tune writer.
- **Pillar 6 P6.4/P6.5 closes the FIXES.md open queue except P4.4 (post-launch content) and L2–L8 (post-launch trim pass).**

### L4b followup — wire missing hook tests into the fast suite

Three hook fixtures had landed without ever being added to `tests/run.sh`'s `suites` array — `tests/hooks/test-block-env-commit.sh` (P6.1, shipped 2026-05-27), `tests/hooks/test-typecheck-after-edit.sh` (P6.4, shipped 2026-05-28), and `tests/hooks/test-format-on-save.sh` (P6.5, shipped 2026-05-28). Neither the local `./tests/run.sh` nor CI exercised any of them. Wiring all three raises the fast suite to **5 suites / 100 assertions** (12 env-staging + 12 env-commit + 11 typecheck-after-edit + 12 format-on-save + 53 installer); the change is hook-runner glue only — no change to any hook or fixture. CI picks it up on the next push to `main`.

#### Changed

- `tests/run.sh` — `suites` array gains the three missing entries; header comment updated to enumerate all five suites.
- `LAUNCH.md` — new `### L4b followup (2026-05-28) — wire missing hook tests into the fast suite` subsection under L4 notes.

### L4c — Token-efficiency benchmark harness

Spine-on vs spine-off token-cost measurement. The eval-set + harness ship in this update; a baseline run against Sonnet 4.6 (~$9–$15) and the resulting `REPORT.md` numbers ship in a separate session whenever Tim authorizes the spend. Today's commit is the scaffold + the operating contract — so a future run is one `./run.sh` away from a populated REPORT.

The harness pattern mirrors `tests/skill-triggers/run.sh`: stash `~/.claude/CLAUDE.md` + every `~/.claude/skills/op-*` directory to a `mktemp -d` root, replace `~/.claude/CLAUDE.md` with a one-line stub, run the eval-set in batch, restore the spine on `EXIT` / `INT` / `TERM` / `HUP`, then run the spine-on batch. Cache behavior is the explicit design choice: batching means the prompt cache amortizes the spine-on prefix after the first call — that mirrors real steady-state usage; alternating conditions would cold-cache every call and over-report spine cost. `REPORT.md` calls this out per-prompt in a "Cache creation vs read" table.

#### Added

- `benchmarks/tokens/eval-set.json` — 19 prompts (15 spine-relevant + 4 negative controls). Categories: workflow_scoping (2), recovery (2), persistence (2), tool_choice (2), anti_patterns (2), brownfield (1), signaling (1), subagents (1), prompting (1), hooks (1), control (4). Each entry carries `id`, `category`, `prompt`, `expected_spine_skill`, and `rationale`. Approved by Tim before harness code shipped, per the L4c spec's gate.
- `benchmarks/tokens/run.sh` — preflight reports installed vs. repo skill counts and warns if they diverge (a stale install measures yesterday's spine, not today's). Flags: `--runs N` (default 3), `--model NAME` (default `claude-sonnet-4-6`), `--timeout N` (default 90s), `--only-prompt ID`, `--only-cond on|off`, `--dry-run`. Per-call raw output lands in `results/raw/<id>__<cond>__r<N>.json`; a rolling summary lands in `results/results.jsonl` (one JSON object per call with the seven token / cost / timing fields aggregate.py needs).
- `benchmarks/tokens/aggregate.py` — reads `results/results.jsonl`, writes `REPORT.md`. Sections: per-prompt comparison table (Δ tokens, Δ %, Δ cost USD); totals; per-condition variance (σ of input tokens across runs); cache_creation vs cache_read per prompt; the spec-mandated "What this doesn't measure" caveats section. Idempotent — re-run anytime; partial JSONL produces a partial report.
- `benchmarks/tokens/README.md` — usage, prerequisites, cost estimate ($9–$15 default; ~10× on Opus), when to re-run, link to the report. Cross-links to `tests/skill-triggers/README.md` so the two harnesses' purposes don't blur.
- `benchmarks/tokens/REPORT.md` — placeholder; aggregate.py rewrites this on every run.
- `benchmarks/tokens/.gitignore` — excludes `results/` (per-call raw output + rolling jsonl summary). Each `./run.sh` regenerates; only the harness scaffold + the published `REPORT.md` are tracked.

#### Changed

- `README.md` — "Running the tests" section gains a third subsection (**Token-efficiency benchmark**) sibling to the fast suite and the skill-trigger benchmarks. Same "paid, manual, not in CI" framing; cost estimate inline.

#### Implementation notes

- **`claude -p --output-format json` schema verified before drafting the harness.** Top-level keys include `total_cost_usd`, `usage`, `modelUsage`, `num_turns`, `duration_ms`, `ttft_ms`. Inside `usage`: `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens` — the four fields the report compares. No invented field names.
- **Cost-default tightened to Sonnet 4.6.** Tim's machine defaults to Opus 4.7 at $0.12 per "hi" call; the full 114-call sweep on Opus would be ~$15 *per condition* and blow the spec's $15 cap. `--model claude-sonnet-4-6` is the explicit default; `--model opus` is an opt-in.
- **Batch order is spine-off → spine-on.** The spine-off batch leaves no cache prefix to invalidate; the subsequent spine-on batch creates its own cold cache on call 1 and amortizes on calls 2..N. Alternating would re-pay the cold-cache cost every prompt.
- **No CI integration.** Same rationale as skill-triggers: real API spend, minutes of wall time, no `ANTHROPIC_API_KEY` in CI. The fast suite stays the only suite CI runs.

### Still pending pre-launch

- **L4c baseline run** — the harness shipped today; the actual `./run.sh` against Sonnet 4.6 (~$9–$15) is gated on Tim's authorization. Once it runs, `benchmarks/tokens/REPORT.md` carries the numbers and L4c closes.
- **L7a / L7c / L7d / L7e** — landing-page hardening (built CSS, OG image, waitlist wiring), demo recording, public launch.

See [`LAUNCH.md`](LAUNCH.md) for launch gates and [`FIXES.md`](FIXES.md) for the active drift backlog.

---

## [0.10.0] — 2026-05-28

Closes the six pre-launch pillars from [`FIXES.md`](FIXES.md). Personalization is now wired (Pillar 1: 19f subscription-aware chapter + four routers branch on it). First-run discovery exists (Pillar 4: auto-welcome, `/spine` command, richer onboard handoff). The capture/curate flywheel has closure (Pillar 2: `op-curate-nudge` + `Last fired` field). Two skill triggers are tightened (Pillar 5). Two default-on safety hooks plus a `/hooks` command ship (Pillar 6). Pillar 3 (workflow auto-inference) is deferred to post-launch per FIXES.md ordering.

Counts from 0.9.0 → 0.10.0:

- **Skill set: 19 → 22.** Added three ambient skills: `op-spine-active` (L10), `op-welcome` (Pillar 4), `op-curate-nudge` (Pillar 2).
- **Slash commands: 8 → 9.** Added `/done` (L10), `/spine` (Pillar 4), `/hooks` (Pillar 6); removed `/session-start` + `/session-end` (L10.1, superseded by the ambient flow plus built-in plan mode).

### Pillar 2 — Self-improvement loop closure

The capture/curate flywheel had no closing nudge: `op-suggest` quietly appended to `bucket/SUGGESTIONS.md` but nothing ever surfaced a reminder to actually run `/curate`. Past the ~10-pending threshold the queue became a graveyard. This pillar closes the loop with a single conversation-start nudge plus a `Last fired` field that makes stale-review concrete.

#### Added

- `skills/core/op-curate-nudge/SKILL.md` — auto-firing skill. Fires once at conversation start when `bucket/SUGGESTIONS.md` has 5+ pending entries AND the latest `bucket/CHANGELOG.md` date is >30 days ago (or no `/curate` has ever run). Emits one quiet line suggesting `/curate`, then continues with the user's request. Co-fires cleanly with `op-welcome` and `op-spine-active`. Third ambient skill alongside those two.
- `bucket/INDEX.md` — new fourth column **`Last fired`** on both Skills and Chapters tables. Defaults to `—` on row creation; updated to today's date by `op-bucket-router` whenever the row routes to a file that exists.

#### Changed

- `skills/core/op-bucket-router/SKILL.md` — new "Stamping Last fired" section + rule update. The previously-blanket "Don't modify the bucket" rule now has one carve-out: stamp the matched row's `Last fired` cell to today's date. One row per turn, single-column edit, no stamp on missing-file rows.
- `skills/core/op-add-skill/SKILL.md` — row-append format extended to four columns; new rows initialize `Last fired` as `—`.
- `skills/core/op-curate/SKILL.md` — same row-append change on approve (new skill or new chapter).
- `skills/core/op-curate/stale-review.md` — rewrites the "what stale means" definition to use the new `Last fired` field. Two-tier candidate pool now: (a) **never-fired** rows where `Last fired` is `—` AND `Added` is >90 days (strongest signal — added but the trigger never matched real work); (b) **fired-but-stale** rows where `Last fired` is >6 months ago. Walks never-fired first, then fired-long-ago. Archive log entries record both dates.
- `global/commands/refresh-bucket.md` — rebuild logic preserves `Last fired` alongside `Added` when a row's file still exists; new hand-dropped rows initialize `Last fired` to `—`.
- `chapters/personalization/19c-suggestion-loop.md` — the v1 "deliberately do not auto-propose curation" paragraph is replaced with the new threshold rule (5 pending + 30-day cooldown + once-per-conversation). The per-capture-fire variant remains rejected; the conversation-start variant ships. Rationale: bounded fire rate doesn't violate [13d](../persistence/13d-skill-anti-patterns.md) — at most monthly even at full velocity.
- Skill count swept 21 → 22 in `README.md` (4 sites), `landing/index.html`, `install.sh`'s summary, `skills/core/op-welcome/SKILL.md`, and `tests/installer/test-dry-run.sh` (new `op-curate-nudge` assertion).

### Pillar 6 — Default-on hooks + `/hooks` listing command

`chapters/persistence/14b-hook-recipes.md` taught six hooks; only two shipped. Closes the gap with two high-value low-risk additions plus a discovery surface for what's actually wired.

#### Added

- `global/hooks/block-env-commit.sh` — PreToolUse hook. Closes the `git commit` gap left by `block-env-staging.sh` (which only catches `git add` arguments). A `.env` file tracked from before `.gitignore`, or force-staged via `git add -f`, would still reach `git commit`. The new hook reads `git diff --cached --name-only` for any `.env*` final-segment match and denies with a remediation hint. Same risk profile as the staging hook; same defense-in-depth posture.
- `global/hooks/notify-long-task.sh` — Notification hook. Surfaces Claude Code's notification events (waiting on input, idle, long-task completion) as macOS / Linux desktop alerts. macOS uses `osascript`; Linux uses `notify-send`; cross-platform fallback is the terminal bell. Graceful-fail throughout — never blocks Claude.
- `global/commands/hooks.md` — `/hooks` command. Reads `~/.claude/settings.json` plus any project-level `.claude/settings.json`; prints one row per configured hook (event, matcher/if filter, script path). Read-only single-shot discovery surface, paired with the `/spine` command.
- `tests/hooks/test-block-env-commit.sh` — 12-case fixture (6 should-block, 6 should-allow). Sets up a throwaway git repo, force-stages various files, and feeds the hook the Claude Code PreToolUse input shape on stdin to verify deny / allow decisions.

#### Changed

- `global/settings.json` — wires both new hooks. PreToolUse Bash matcher now has two `if`-gated entries (`git add*` → staging hook; `git commit*` → commit hook). New `Notification` event hook points at `notify-long-task.sh`.
- `README.md` — slash-commands table grows from 8 → 9 rows (adds `/hooks`); count claims swept ("Eight commands" → "Nine commands"; "8 slash commands" → "9 slash commands" in two positions).
- `install.sh` — summary line "21 skills, 8 slash commands" → "22 skills, 9 slash commands" (Pillar 2 also touches this line).
- `skills/core/op-welcome/SKILL.md` — same summary tweak.
- `skills/core/op-onboard/SKILL.md` — completion-handoff command list adds `/hooks` (matches the new `/spine` sibling).

### Pillar 5 — Skill trigger tightening

Two skill trigger descriptions bundled too many semantic categories — `op-persistence` mixed five tasks (CLAUDE.md / skill / memory / library audit / hook-vs-CLAUDE.md choice); `op-signaling` blended retrospective / mid-stream / meta-scope / calibration into one paragraph. Both rewritten to lead with one primary user-facing trigger, plus literal keyword phrases the description-matching can actually pattern-match against, plus counter-examples (code-level `persistence` / `signaling` queries — the false-positive categories the eval-set already filters).

#### Changed

- `skills/core/op-persistence/SKILL.md` — description rewritten. Leads with "deciding *where* a behavior or rule should persist across sessions" + literal trigger phrases ("should this go in a skill or CLAUDE.md?", "I keep telling Claude X every session"); body still branches into sub-tasks (skill anatomy, trigger descriptions, library audit) once routed. NOT-for clause covers localStorage / Redis / DB schemas / session state.
- `skills/core/op-signaling/SKILL.md` — description rewritten. Leads with the user-facing trigger ("flag risks proactively", "are we still in scope?", "is context filling?", "you contradicted yourself", "why didn't you flag X earlier?") + the meta-scope trigger (user proposing to extend Claude's setup). NOT-for clause covers SIGTERM / loading spinners / WebSocket events / notification system design.

The eval-set test cases for both skills were left unchanged — the new descriptions still cover all 5 should-trigger queries in each set. Benchmark re-run deferred to a separate session (~$5 spend).

### Pillar 1 — Personalization payload (Sessions 1 of 3)

The profile written by `/onboard` was capturing values that no downstream chapter or skill read. Same advice for a Python Pro user and a Rust Max-20× engineer. Pillar 1 attacks the gap in three steps; P1.2 lands first because it changes the essentials surface and the count semantics every other Pillar 1 piece references.

#### Changed

- `skills/core/op-onboard/questions-essential.md` — **Q5 split.** What was one "Verbosity" question collapsed two orthogonal dimensions: how short to be (length) and how much to back-explain decisions (reasoning depth). The user who wants short answers with full reasoning had no good option. Split into:
  - **Q5a — Answer length** (Terse / Standard / Verbose)
  - **Q5b — Reasoning depth** (Just the answer / Show the path / Teach me the why)

  Essential count 6 → 7. Total interview length 17 (claimed) → 20 (actual: 7 + 13 = 20; the prior "17" was also off — deep ships 13 questions, not 11). Per FIXES P1.2.
- `skills/core/op-onboard/profile-template.md` — Working style section: `Verbosity` field → `Answer length` + `Reasoning depth` (two distinct fields).
- `skills/core/op-onboard/SKILL.md` — count refs and handoff block updated (verbosity → answer length + reasoning depth; "~11 follow-ups" → "13 follow-ups"; "~17-question interview" → "~20-question interview").
- `global/commands/onboard.md` — description: `~17-question` → `~20-question`; `6-question essentials` → `7-question essentials`.
- `README.md` — three count-claim positions: 6 → 7 essentials, ~17 → ~20 total; Personalization section "verbosity" → "answer length, reasoning depth"; adds Subscription to the captured-fields list.
- `landing/index.html` — (no question-count claim — already uses skill counts only; no change needed here.)
- `install.sh` — next-step block "6-question" → "7-question".
- `skills/core/op-welcome/SKILL.md` — welcome block "6-question" → "7-question".
- `EXPLAINER.md` — "First-time setup — 6 to 17 questions" → "First-time setup — 7 to 20 questions".
- `chapters/personalization/19b-profile-and-onboarding.md` — major refresh: 5 → 7 essentials, ~10 → 13 deep questions, "Verbosity" → "Answer length / Reasoning depth", Subscription section added to the captures table, "Profile file missing → op-onboard auto-fires" replaced with the op-welcome handoff (cross-references Pillar 4), re-run reasons cover answer length / reasoning depth / subscription change.
- `chapters/personalization/19a-overview.md` — Profile paragraph: "verbosity" → "answer length, reasoning depth"; adds Subscription to the captured-fields list.

P1.3 follow-up (small):

- `skills/core/op-onboard/questions-deep.md` — Q0A and Q0B gloss "Opus" (Claude's most capable but slowest and most expensive model) and "multi-agent review" (several Claude sessions checking the same code in parallel). Header count "~10" → "13".

P1.1 (the read path — Session 1 of the SUBSCRIPTION-AWARENESS plan):

#### Added

- `chapters/personalization/19f-subscription-aware.md` — concrete prose for the eight subscription-aware levers (default model, ultra review, parallel subagents, fast mode, long autonomous loops, fresh-terminal cadence, end-of-session multi-agent verify, long-context workflows). One table per lever, plan-by-plan rows. Plus `Cost sensitivity` modifier rules and an "Other plan" mapping. Default-to-Pro fallback when the profile is missing. 117 lines (under the 150-line atomic cap).

#### Changed

- `INDEX.md` — new Personalization row pointing to 19f.
- `skills/core/op-foundations/SKILL.md` — adds 19f to the index ("Should this recommendation shift based on the user's Claude subscription?") + common-trigger lines for "Should I use Opus" and "burning through my plan budget" + body footnote: "When the recommendation has a cost / quota / model component, read 19f and branch on `Plan:` and `Cost sensitivity:` before answering."
- `skills/core/op-tools/SKILL.md` — adds 19f for cost-sensitive tool choices (ultra review, long loop, fan-out, repeated WebFetch / MCP) + matching common-trigger lines.
- `skills/core/op-subagents/SKILL.md` — adds 19f for the per-plan fan-out budget; updates the parallel-audits trigger to point at 19f after 16c.
- `skills/core/op-signaling/SKILL.md` — adds 19f for "about to do something materially expensive" framing; new common-trigger line specifies the Max 20× + "Don't worry about it" → no flag rule and the Free / Pro or "Very careful" → one-line warning + cheaper alternative rule.
- `docs/archive/SUBSCRIPTION-AWARENESS-2026-05.md` — status updated: Session 1 done, Sessions 2 + 3 remain.

Sessions 2 + 3 (adjusting individual chapters like `04a-model-tiers`, `chapter 16`, `chapter 11`, and the `code-review` / `loop` / `schedule` skill bodies, plus re-onboard verification across plan tiers) deferred to follow-up sessions — see `docs/archive/SUBSCRIPTION-AWARENESS-2026-05.md`.

### Pillar 4 — First-run discovery surface

A fresh-install user who opened Claude Code without reading the README saw no in-session prompt — the discovery surface for `/onboard` and the 21 op-* skills was "go read the repo." Pillar 4 closes that for the three highest-impact paths: a quiet auto-welcome on first run (file-existence-gated, not message-content-gated), a `/spine` command that prints the full skill / command / chapter map on demand, and a much richer `op-onboard` completion handoff that names every available command and points at the natural next action. Per [`FIXES.md`](FIXES.md) Pillar 4 (P4.1 + P4.2 + P4.3). P4.4 (landing-page screenshot + profile example) is post-launch content work.

The in-flight `op-onboard` subscription-aware settings tune also lands in this entry — it shares the same surface (the post-essentials writeback step) and was committed together to avoid two passes over the same file region.

#### Added

- `skills/core/op-welcome/` — auto-firing skill. When `~/.claude/claude-spine-profile.md` is missing (fresh install), emits one quiet welcome block at the start of the first conversation pointing the user at `/onboard`. Silent once the profile exists. Once-per-conversation, file-existence-gated. Orthogonal to `op-spine-active`'s trigger (project state, not profile state) — both can co-fire on a fresh-install plan-driven project.
- `global/commands/spine.md` — `/spine` command. Reads the spine on-disk and prints: profile path + status, slash-commands list, op-* skills with one-line triggers, chapter root, bucket state, pending-suggestions count. Read-only, single-shot. Counts everything from disk so the output never goes stale.
- `skills/core/op-onboard/SKILL.md` — **subscription-based settings tune.** After essentials are saved, proposes raising `autoCompactWindow` and `effortLevel` in `~/.claude/settings.json` for Max 20× users (the spine ships Pro-safe defaults). Plain-English explanation block + explicit Apply/Skip approval — never silent. Write surface is allow-listed to two keys; aborts if the file format diverges from defaults.
- `skills/core/op-onboard/SKILL.md` — **rich completion handoff.** After the profile is written, emits one structured "you're set up" block summarizing what was captured, whether settings.json was tuned, and listing all eight slash commands with one-line uses. Replaces the previous terse three-bullet farewell.

#### Changed

- `README.md` — skill count 20 → 21 in all live-claim positions (5 lines). Phrasing updated to "(19 task-routers + 2 ambient: cold-start and first-run welcome)." `/spine` added to the slash-commands table; command count "Seven" → "Eight."
- `landing/index.html` — "20 op-* skills" → "21 op-* skills."
- `install.sh` — final summary replaces the terse `==> done.` + verify-hint block with a structured "what just happened" + "Next steps" panel that names `/onboard` and `/spine` directly. Idempotency line added.
- `tests/installer/test-dry-run.sh` — skill-coverage list updated to include `op-prepare`, `op-spine-active`, `op-welcome` (was missing all three); summary-line assertions updated to match the new install.sh output (`installing hooks`, `claude-spine is installed.`, `Type  /onboard` block).
- `skills/core/op-onboard/SKILL.md` — description tightened: removes the implicit "auto-fires when profile missing" trigger (`op-welcome` now owns that surface) so this skill only fires on explicit invocation. Mode-selection #1 reworded as "`/onboard` with no profile yet" — the *greeting* is `op-welcome`'s job, the *interview* still runs on first explicit `/onboard`.
- `skills/core/op-onboard/questions-essential.md` — post-Q6 flow rewritten as three numbered steps (save → propose settings tune → ask about deep) so the settings-tune step is a first-class part of the essentials flow, not buried.

### L10 — Ambient workflow refactor

Plan-driven workflow shifts from explicit ceremony (`/session-start` → `/session-end`) to an ambient default where boundary work happens automatically. Original goals (cold-start resistance, scope discipline, multi-session continuity) preserved. Initial L10 kept the legacy commands as escape hatches; L10.1 (below) removed them once the ambient flow was confirmed sufficient.

#### Added

- `skills/core/op-spine-active/` — auto-firing skill. At the start of any conversation in a directory containing `docs/plans/` + `docs/PROGRESS.md`, loads the active session entry, announces scope in 3-4 lines, and proceeds to build. Ambient replacement for `/session-start`.
- `global/hooks/spine-writeback.sh` — Stop hook. After every assistant turn, appends a one-line heartbeat to the active section's `## Session log` block recording which files changed. Idempotent (skips repeats sans timestamp), graceful (silent no-op outside plan-driven dirs, never blocks Claude on failure).
- `global/commands/done.md` — `/done` command. Walks the verify list, rolls up heartbeats into one PROGRESS.md log entry, advances the PROGRESS pointer, stages doc changes, suggests a commit message. Primary writeback command in the ambient flow.

#### Changed

- `global/commands/prep.md` — added Step 0: auto-runs `~/.claude-spine/init.sh .` if `docs/` doesn't exist. Removes the manual shell step before opening Claude on a new project.
- `global/commands/session-start.md` — top note marks it as **legacy / power-user**. Same gated protocol; default is now ambient. Use this when you explicitly need a "no code until you say go" gate.
- `global/commands/session-end.md` — top note marks it as **legacy alias for `/done`**. Same writeback protocol.
- `global/settings.json` — wires the Stop hook (`spine-writeback.sh`); adds `Bash(*claude-spine/init.sh:*)` to the allow list so `/prep` Step 0 doesn't prompt.
- `install.sh` — hook installer refactored to loop over `global/hooks/*.sh` (was hardcoded single-file). Picks up `spine-writeback.sh` automatically; future hooks land without installer changes.
- `global/INSTALL.md` — "Plan-driven workflow" rewritten with ambient default; explicit-command flow moved to a "Power-user / explicit mode" subsection.
- `README.md` — slash-commands table updated: `/done` added; `/session-start` + `/session-end` marked legacy; status blurb mentions ambient flow.

### L10.1 — Legacy session commands removed

Vibecoder default fully realized: no escape-hatch commands, no two-doors-to-one-room confusion. Plan mode (Shift+Tab Tab) is the recommended gate primitive for safety-critical sessions.

#### Removed

- `global/commands/session-start.md` — was the gated cold-start command. For safety-critical work that needs a code-gate, use Claude Code's built-in plan mode (Shift+Tab Tab) instead.
- `global/commands/session-end.md` — was a pure alias for `/done` with no unique behavior.

#### Changed

- `chapters/workflow/05j-cold-start-protocol.md` — rewritten without the gated variant. Plan mode is the recommended gate primitive.
- References to the removed commands dropped or replaced in: `chapters/workflow/05h-multi-session-planning.md`, `chapters/workflow/05i-execution-plan-anatomy.md`, `INDEX.md`, `README.md`, `global/INSTALL.md`, `global/commands/prep.md`, `global/commands/done.md`, `skills/core/op-spine-active/SKILL.md`, `skills/core/op-prepare/SKILL.md` + `procedure.md`, `templates/PROGRESS.md`, `templates/SECTION_PLAN.md`, `templates/SESSION_STARTER.md`, `init.sh`.

### Onboarding — Claude subscription awareness

Defaults today assume a Max-tier user with cheap Opus and 1M-context access. That misreads the Free / Pro segment and under-uses what Max users could be doing. Step one: ask the user which plan they're on; capture daily usage and cost sensitivity in the deep interview. Behavior changes that actually consume the captured field are queued separately ([`docs/archive/SUBSCRIPTION-AWARENESS-2026-05.md`](docs/archive/SUBSCRIPTION-AWARENESS-2026-05.md)) so the question can land without waiting on the multi-session implementation work.

#### Added

- `skills/core/op-onboard/questions-essential.md` — new Q1 "Which Claude subscription do you use?" with Free / Pro / Max 5× / Max 20× options (Other = free-text for Team / Enterprise / API). Existing Q1–Q5 renumber to Q2–Q6.
- `skills/core/op-onboard/questions-deep.md` — new Section 0 (subscription) with 0A "daily Claude usage" and 0B "cost sensitivity". Deep-question count 15 → 17.
- `skills/core/op-onboard/profile-template.md` — new `Subscription` section at the top of the profile with `Plan`, `Daily usage`, `Cost sensitivity` fields.
- `docs/archive/SUBSCRIPTION-AWARENESS-2026-05.md` — planning doc tracking the multi-session work to actually adjust behavior based on the captured plan (model recommendations, ultra-review framing, parallel-subagent caution, fresh-terminal cadence, etc.). Status: queued, not started.

#### Changed

- `skills/core/op-onboard/SKILL.md` — trigger description mentions subscription as a captured field; mode-selection counts updated to 6 essentials / 17 deep.
- `global/commands/onboard.md` — description updated to 6-question essentials / ~17-question deep.
- `skills/core/op-onboard/questions-deep.md` — every existing deep question rewritten in the same plain-language non-coder style as the essentials (parenthetical glosses for jargon, situational labels instead of survey buckets). Matches the style note added at the top of the file.

### Pre-launch cleanup — v1 root stubs removed

The 18 one-line redirect files at the repo root (`01-first-principles.md` … `18-anti-patterns.md`) have been deleted. They were kept earlier on the theory that external links (blog posts, gists, agent prompts) might point at them, but with public launch (L7) not yet shipped there are no external links to break. The original v1 bodies remain in `docs/v1-archive/` and the v1 → v2 navigation map in `V1-CHAPTERS-DEPRECATED.md` is unchanged — only the root stubs are gone.

#### Removed

- 18 v1 redirect stubs at repo root: `01-first-principles.md`, `02-context-window-truth.md`, `03-limits.md`, `04-models-and-economics.md`, `05-workflow.md`, `06-feature-sizing.md`, `07-collaboration-modes.md`, `08-brownfield.md`, `09-prompting.md`, `10-visuals.md`, `11-proactive-signaling.md`, `12-skills-memory-claudemd.md`, `13-custom-skills.md`, `14-hooks-and-automation.md`, `15-tool-palette.md`, `16-subagents.md`, `17-recovery-playbook.md`, `18-anti-patterns.md`.

#### Changed

- `V1-CHAPTERS-DEPRECATED.md` — top paragraph and "Why" passage rewritten to describe the new reality (bodies in `docs/v1-archive/`, no root stubs). Trailing "When are v1 stubs going away?" section replaced with "Where do the v1 bodies live now?" pointing at the archive directory.
- `docs/archive/SUBSCRIPTION-AWARENESS-2026-05.md` — table reference to `04-models-and-economics.md` repointed at `chapters/foundations/04a-model-tiers.md`.

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
