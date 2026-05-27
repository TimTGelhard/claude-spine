# Changelog

All notable changes to **claude-spine** are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/spec/v2.0.0.html).

`git pull` is the update mechanism — there is no package registry. New entries land at the top.

---

## [Unreleased]

### Pillar 1 — Personalization payload (Session 2 of 3)

Session 1 (in `[0.10.0]`) shipped `chapters/personalization/19f-subscription-aware.md` and wired four routing skills to it. The chapters those routers point *into*, though, still read generically — a Free user reading `04a-model-tiers.md` got the same "default to Sonnet" framing as a Max 20× user with cheap Opus access. Session 2 closes that gap by adding bidirectional cross-references from five high-leverage chapters back into 19f, so the per-plan branch surfaces wherever a generic recommendation sits.

#### Changed

- `chapters/foundations/04a-model-tiers.md` — new "Plan-aware default" subsection between the mental rule of thumb and Related. Two paragraphs + a link into 19f (lever 1). Related section grows one bullet.
- `chapters/foundations/04b-plan-and-fast-mode.md` — fast-mode section gains one paragraph framing the per-plan stance (occasional treat for Free / Pro, default for Max). Related section grows one bullet.
- `chapters/foundations/04c-budget-and-cost.md` — "Plan budgets" section adds one paragraph pointing at 19f as the authoritative per-plan recommendation source, since 04c already enumerates plan tiers but doesn't surface the per-plan defaults table.
- `chapters/subagents/16c-parallel-and-background.md` — new "Plan-aware fan-out budget" subsection after Anti-patterns, with the four-row fan-out table (Free / Pro / Max 5× / Max 20×) and the `Cost sensitivity` modifier rule. TL;DR gains one bullet.
- `chapters/signaling/11-overview.md` — "five signal categories" framing preserved, with a clarifying line that cost/quota is cross-cutting, not a sixth category. New "Cost / quota signals" subsection between Anti-patterns and TL;DR — four-row decision table (Max 20× + Don't worry / Pro/Max 5× + Balanced / Free or Very careful / profile missing) for whether to flag, with 19f as the alternative-suggestion table.
- `docs/SUBSCRIPTION-AWARENESS.md` — status header marks Sessions 1+2 done; Session 3 (re-onboard as each plan tier + docs sweep) remains open. Records the realistic-injection-path caveat for the external `code-review` / `loop` / `schedule` skills.
- `FIXES.md` — status header drops Pillar 1 Sessions 2–3 → Pillar 1 Session 3. P1.1 entry annotation updated to credit Session 2.

No new files. No skill changes (the four routers were already wired in Session 1). No INDEX update needed (19f row was already present from Session 1).

### Still pending pre-launch

- **L4c** — token-efficiency benchmark (spine-on vs spine-off) for demo numbers.
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
- `docs/SUBSCRIPTION-AWARENESS.md` — status updated: Session 1 done, Sessions 2 + 3 remain.

Sessions 2 + 3 (adjusting individual chapters like `04a-model-tiers`, `chapter 16`, `chapter 11`, and the `code-review` / `loop` / `schedule` skill bodies, plus re-onboard verification across plan tiers) deferred to follow-up sessions — see `docs/SUBSCRIPTION-AWARENESS.md`.

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

Defaults today assume a Max-tier user with cheap Opus and 1M-context access. That misreads the Free / Pro segment and under-uses what Max users could be doing. Step one: ask the user which plan they're on; capture daily usage and cost sensitivity in the deep interview. Behavior changes that actually consume the captured field are queued separately ([`docs/SUBSCRIPTION-AWARENESS.md`](docs/SUBSCRIPTION-AWARENESS.md)) so the question can land without waiting on the multi-session implementation work.

#### Added

- `skills/core/op-onboard/questions-essential.md` — new Q1 "Which Claude subscription do you use?" with Free / Pro / Max 5× / Max 20× options (Other = free-text for Team / Enterprise / API). Existing Q1–Q5 renumber to Q2–Q6.
- `skills/core/op-onboard/questions-deep.md` — new Section 0 (subscription) with 0A "daily Claude usage" and 0B "cost sensitivity". Deep-question count 15 → 17.
- `skills/core/op-onboard/profile-template.md` — new `Subscription` section at the top of the profile with `Plan`, `Daily usage`, `Cost sensitivity` fields.
- `docs/SUBSCRIPTION-AWARENESS.md` — planning doc tracking the multi-session work to actually adjust behavior based on the captured plan (model recommendations, ultra-review framing, parallel-subagent caution, fresh-terminal cadence, etc.). Status: queued, not started.

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
- `docs/SUBSCRIPTION-AWARENESS.md` — table reference to `04-models-and-economics.md` repointed at `chapters/foundations/04a-model-tiers.md`.

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
