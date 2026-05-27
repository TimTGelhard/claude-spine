# FIXES — senior review pass, 2026-05-27 (closed 2026-05-28)

> **Status as of 2026-05-28:** Pillars 1 (Sessions 1+2 of 3), 2, 4, 5, 6 + the
> HIGH/MEDIUM drift sweep + M4 have shipped — Sessions 1 + Pillars 2/4/5/6
> landed in `[0.10.0]`; Pillar 1 Session 2 (chapter-level cross-references to
> 19f) lands in the next `[Unreleased]` block. The open queue at this point is
> **Pillar 3** (workflow auto-inference — P3.1–P3.5, all P2 / post-launch),
> **Pillar 1 Session 3** (verify across all four plan tiers + docs sweep,
> tracked in `docs/SUBSCRIPTION-AWARENESS.md`), **P4.4** (landing-page
> screenshot + profile example, post-launch content work), **P6.4 + P6.5**
> (opt-in onboard-deep hooks), and the LOW items L2–L8.
> Each shipped item below has a `**[shipped …]**` annotation; unfixed items
> have no annotation. Two passes are stacked in this file:
>
> **Pass 1 — drift catalog (HIGH / MEDIUM / LOW below).** From a fresh review
> on `main`. The previous internal audit in [`docs/JANITOR.md`](docs/JANITOR.md)
> shipped most of its items (op-prepare split, PERSONALIZATION archived,
> EXPLAINER pricing reframe). What's listed here was **new drift since that
> pass** — almost entirely a consequence of L10 adding `op-spine-active` (skill
> count 19 → 20) and L10's planning doc still living at the repo root. Total
> work: ~20 minutes. All HIGH + MEDIUM items have shipped.
>
> **Pass 2 — strategic pillar findings (`## Pillar findings` further down).**
> From a deeper pre-global-launch review. Unlike the drift items, these were
> *content / architecture gaps* — a partly-hollow personalization promise on
> the README, a self-improvement loop with no closure, predictable workflow
> attention-leaks, first-run UX that required README literacy, two weak skill
> triggers, and high-value hooks taught but not shipped. Six pillars. Pillars
> 1, 2, 4, 5, 6 are done (with Pillar 1 covering Session 1 of 3); Pillar 3 is
> deferred to post-launch.

## Live counts on disk (truth source as of 2026-05-28)

- `op-*` skills under `skills/core/`: **22** (19 task-routers + 3 ambient: `op-spine-active`, `op-welcome`, `op-curate-nudge`)
- `.md` files under `chapters/`: **81** (Pillar 1 added `chapters/personalization/19f-subscription-aware.md`)
- Onboarding questions: **7 essential + 13 deep = 7–20 total** (Pillar 1.2 split Q5 into Q5a + Q5b)
- Slash commands under `global/commands/`: **9** (`/onboard`, `/prep`, `/done`, `/suggest`, `/curate`, `/add-skill`, `/refresh-bucket`, `/spine`, `/hooks`)
- Hooks under `global/hooks/`: **4** (`block-env-staging.sh`, `block-env-commit.sh`, `notify-long-task.sh`, `spine-writeback.sh`)

Anywhere a doc claims numbers different from the above and is making a
*current-state* claim (as opposed to historical/changelog narrative), it's wrong.

---

## HIGH — visible to readers, sweep before the next push

**[All H1–H4 shipped 2026-05-27 — commit `acc3769`, landed in `[0.10.0]`.]**
The drift sweep merged the four count-corrections into a single PR per the
"Suggested apply order" below. Subsequent pillars (Pillar 4 added `op-welcome`;
Pillar 2 added `op-curate-nudge`; Pillar 1 added 19f-subscription-aware.md;
Pillar 1.2 split Q5 into two essentials) have bumped the live counts further,
so the specific "20 skills" / "6 to 17 questions" / "~80 chapters" phrasings
recommended below are themselves now stale — current truth is in
"Live counts on disk" at the top of this file. The historical record below
documents the state at the time of the sweep, not the current state.

---

### H1. `README.md` — three live "19 op-* skills" claims should be **20**

These three lines all describe current state, not history:

- `README.md:13` — `**19 `op-*` skills**`
- `README.md:74` — `the 19 op-* skills`
- `README.md:131` — `the 19 op-* skills`

**Fix:** sweep all three to `20`. Because the L10 changelog entry explicitly
mentions that `op-spine-active` was *added*, the most truthful phrasing is:

> 20 `op-*` skills (19 task-routers + 1 ambient cold-start)

…but the bare number `20` is fine if that reads too long. Pick one and apply
to all three call sites.

### H2. `landing/index.html:96` — landing page says **19**, should be **20**

Same fix as H1 — currently says `**19** `op-*` skills`. The landing page is a
user-facing surface, so do not skip this when fixing README.

### H3. `EXPLAINER.md:75` — "Around 50 short lessons" should be **~80**

Stale count from an earlier draft. The repo now has 80 chapter files. Suggest:

> Around 80 short lessons the AI reads when it needs them.

### H4. `EXPLAINER.md:122` — "15 to 25 questions" should be **6 to 17**

The actual onboarding interview is 6 essentials, with an opt-in `/onboard --deep`
that adds ~11 follow-ups grouped A–F. The upper bound "25" never matched ship
state. Suggest:

> First-time setup — 6 quick questions (17 if you opt into the deep pass)

This also matches the EXPLAINER's "essentials are quick; the deep pass is
opt-in" framing better than the current "15 to 25".

---

## MEDIUM — repo hygiene, do before public launch (L7)

### M1. Archive `PLAN-AMBIENT-WORKFLOW.md` — the work it describes has shipped

**[shipped 2026-05-27 — commit `0ffb618` + `1b314b2`]** Moved via `git mv` to
`docs/archive/PLAN-AMBIENT-WORKFLOW-2026-05.md`, archive preamble pointing at
the live mechanic (`op-spine-active`, `spine-writeback.sh`, `/done`,
chapter 05j), CHANGELOG + RECONSTRUCTION breadcrumb added.

---

The L10 ambient-workflow refactor is in `CHANGELOG.md` under `[Unreleased]`,
the `op-spine-active` skill exists on disk, the Stop hook is wired in
`global/settings.json`, and `/done` is installed. The planning doc is now a
historical artifact.

### M2. `docs/JANITOR.md` — broken relative links to `LAUNCH.md`

**[resolved 2026-05-27 by M3(b)]** The file was archived to
`docs/archive/JANITOR-2026-05.md` (one directory deeper); the two `LAUNCH.md`
links were rewritten to `../../LAUNCH.md` in the same commit.

---

Two link instances `[`LAUNCH.md`](LAUNCH.md)` appear in `docs/JANITOR.md`
(lines 206 and 223). Because `JANITOR.md` lives in `docs/`, these resolve to
`docs/LAUNCH.md`, which doesn't exist — `LAUNCH.md` is at the repo root.

**Fix:** change both occurrences to `[`LAUNCH.md`](../LAUNCH.md)`.

### M3. JANITOR's own status is itself drift-prone

**[shipped 2026-05-27 via option (b)]** `docs/JANITOR.md` archived to
`docs/archive/JANITOR-2026-05.md` with a frontmatter preamble describing
which items shipped vs deferred. This `FIXES.md` is now the live drift catalog.

---

The previous janitor pass (`docs/JANITOR.md`) lists items that have since been
fixed (op-prepare split, PERSONALIZATION archive, EXPLAINER pricing). Either:

(a) close out fixed items inside `docs/JANITOR.md` with a `## Resolved` log at
the bottom, or
(b) replace `docs/JANITOR.md` with a `docs/archive/JANITOR-2026-05.md` snapshot
and start a fresh JANITOR for the new drift listed above.

Option (b) is cleaner — JANITOR docs are point-in-time audits, not living docs.

### M4. CHANGELOG `[Unreleased]` is large enough to merit a version cut

**[shipped 2026-05-28 — landed in `[0.10.0]`]** Cut as `[0.10.0]` (minor
feature — the workflow change in L10 plus the personalization payload in
Pillar 1 plus three new ambient skills justify a minor bump, not a patch).
`[Unreleased]` now holds only the pre-launch gates left in `LAUNCH.md`
(L4c benchmark, L7a/c/d/e landing-page hardening + demo + public launch).

---

`[Unreleased]` already documents L10 (3 new files, 5 changed). Holding this
under `[Unreleased]` indefinitely makes the changelog harder to read at launch.
Cut a `[0.9.1]` (or `[0.10.0]` if you want to mark the workflow change as a
minor feature, which it is) when L7 ships.

This is procedural, not a doc bug — flagging it so it's not forgotten.

---

## LOW — defer until post-launch, or never

### L1. 18 v1-stub redirect files at the repo root

**[reversed + shipped 2026-05-27 — commit `3ddef9d`]** All 18 stubs deleted
via `git rm`. The "keep for external-link compatibility" rationale didn't
survive scrutiny: L7 (public launch) hasn't shipped, so there are no public
links to preserve. Bodies still live in `docs/v1-archive/`;
`V1-CHAPTERS-DEPRECATED.md` is the navigation map for any future inbound
v1 reference. The CHANGELOG `[Unreleased]` block records the removal.

### L2. `chapters/prompting/10-visuals.md` placeholder image link

References `docs/screenshots/foo.png` (which doesn't exist). This is illustrative
content inside an example block, not a live cross-reference. Confirm during a
future content-pass; not blocking.

### L3. `RECONSTRUCTION.md` — 4 broken relative links to v2 chapter paths

`RECONSTRUCTION.md` is a frozen build-history doc, and the broken paths are
inside historical Phase-by-Phase narrative (chapter slugs that were renamed
during the v2 reorg). Fixing them touches a 526-line doc that the JANITOR
already flagged for post-launch trim/archive (`docs/JANITOR.md` item #13).
Bundle the link fixes into the trim pass, don't chase them now.

Specific broken links if a sweep does happen:

- `13b-trigger-descriptions.md` → `chapters/persistence/13b-trigger-descriptions.md`
- `../persistence/14b-hook-recipes.md` → `chapters/persistence/14b-hook-recipes.md` (path is wrong only when read relative to `RECONSTRUCTION.md` at repo root, not from inside `chapters/persistence/`)
- `19x-slug.md` (×2) → placeholder slugs in narrative; rewrite as code-fenced examples
- `../persistence/13d-skill-anti-patterns.md` / `../persistence/14a-settings-cascade.md` → same path issue as above

### L4. `LAUNCH.md` skill-count references (lines 104, 323, 470, 500: "18"; line 535: "19")

Historical snapshots from earlier launch phases. Not live claims — the
surrounding text marks them as L0/L3-era discoveries. Bundle with the JANITOR
item #13 post-launch trim, same as RECONSTRUCTION.md.

### L5. `skills/core/op-prepare/procedure.md:134` — `~`-prefixed link

`[05j](~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md)` works
when *Claude* follows the link (she expands `~`) but doesn't render in a
markdown previewer. Not a defect for Claude's runtime; only matters if humans
read procedure files directly. Defer; if you sweep, use a repo-relative path:
`[05j](../../../chapters/workflow/05j-cold-start-protocol.md)`.

### L6. `LAUNCH.md` L6 phase log describes a decision that was later reversed

The L6 plan + execution log (lines 365–402) argues for keeping the 18 v1
stubs at root *because* `git mv archive/` would either break external links
or require redirect stubs. That logic held at L6 time. The L9b/cleanup pass
on 2026-05-27 reversed the decision (the stubs were removed in commit
`3ddef9d`) because L7 hasn't shipped yet, so there are still no public
inbound links to break. Two DoD verification commands in the log are now
stale: `grep -l "V1-CHAPTERS-DEPRECATED" 0*-*.md 1*-*.md` (line 395) and
`head -1 0*-*.md 1*-*.md` / `grep -c "Content here is preserved" 0*-*.md 1*-*.md`
(line 396) both target files that no longer exist.

Do **not** rewrite the L6 log to match — it's a frozen point-in-time record
and the reversal is correctly captured in CHANGELOG `[Unreleased]`. Two
options for the post-launch trim pass:

(a) Add a one-line "Superseded 2026-05-27 — see CHANGELOG `[Unreleased]`"
breadcrumb at the top of the L6 section so a reader doesn't take the DoD
greps as a current-state check.
(b) Leave it alone and let the LAUNCH.md → archive move during the post-launch
trim (already flagged in L4 and JANITOR item #13) absorb the staleness.

Recommend (b) — LAUNCH.md is destined for `docs/archive/LAUNCH-pre-1.0.md`
once v1.0 ships, at which point the whole document becomes a frozen log.

### L7. `RECONSTRUCTION.md` phase-notes (lines 347–494) are post-launch archive bait

The first ~340 lines of `RECONSTRUCTION.md` are still-useful architecture
and decomposition rules; everything after is a Phase-by-Phase build journal
(Phase 0 through Phase 8e, plus Phase 6.5 and pre-launch). Once v1.0 ships,
the build-journal portion can be split out to
`docs/archive/RECONSTRUCTION-phases-2026-05.md` and the trimmed
`RECONSTRUCTION.md` keeps only the live architectural decisions (anchor
`#architecture-frozen-decisions` must survive — `V1-CHAPTERS-DEPRECATED.md:9`
and `LAUNCH.md:515` both link to it).

Bundle with JANITOR item #13 / FIXES L4 trim pass.

### L8. `V1-CHAPTERS-DEPRECATED.md` is archive-able once v2 has been canonical long enough

Now that the 18 root stubs are gone, the *only* reason this file lives at
repo root is to redirect any future inbound link of the form
`github.com/.../<repo>/01-first-principles.md`. Once L7 has been public
long enough that v1-era external links have decayed (rough guess: 6–12
months post-launch), this file can `git mv` to `docs/archive/` without
hurting anyone. Not actionable until then.

---

---

## Pillar findings — strategic review

The H/M/L items above are maintenance. The six pillars below are content and
architecture gaps from a deeper pre-launch pass. Each pillar is one focused
session of work. Items within a pillar are tagged **P0** (launch-blocking),
**P1** (ship before global), or **P2** (post-launch).

### Pillar 1 — Personalization is captured but inert

The profile is written by `/onboard` and lives at
`~/.claude/claude-spine-profile.md`, but **no downstream chapter or skill
conditions on its values.** A Python data scientist on Pro and a Rust systems
engineer on Max get identical advice. `docs/SUBSCRIPTION-AWARENESS.md:13`
admits it directly: *"Capturing it is useless if no chapter or skill actually
reads it. Today every recommendation assumes a Max-tier user with cheap Opus
access."* The branding on `README.md:15` is ahead of the implementation.

#### P1.1 [P0] — Ship `19f-subscription-aware.md` and wire the routing skills

**[Sessions 1+2 shipped — Session 1 in `187ddbe` / `[0.10.0]`; Session 2 lands
in the next `[Unreleased]` block]** Session 1 of the 3-session plan in
`docs/SUBSCRIPTION-AWARENESS.md` created
`chapters/personalization/19f-subscription-aware.md` (8 levers × 4 plan-rows
each, plus Cost sensitivity modifier + default-to-Pro fallback), added the
INDEX row, and wired four routing skills to read 19f and branch on `Plan:` /
`Cost sensitivity:` (`op-foundations`, `op-tools`, `op-subagents`,
`op-signaling`). Session 2 added bidirectional cross-references from
`04a-model-tiers`, `04b-plan-and-fast-mode`, `04c-budget-and-cost`,
`16c-parallel-and-background`, and `11-overview` back into 19f — chapter
content now surfaces the per-plan branch wherever a generic recommendation
sits. The `code-review` / `loop` / `schedule` skills called out in the
Session 2 plan are **external plugin skills** (not in this repo); the
realistic injection path is through `op-tools` and `op-signaling`, both
wired in Session 1. Session 3 (re-onboard as each plan tier to verify the
shift + final CHANGELOG sweep) deferred — see
`docs/SUBSCRIPTION-AWARENESS.md` for the open list.

---

#### P1.2 [P1] — Onboard Q5 conflates tone and depth

**[shipped 2026-05-27 — commit `cdbf591`, landed in `[0.10.0]`]** Q5 split into
Q5a (Answer length: Terse / Standard / Verbose) and Q5b (Reasoning depth: Just
the answer / Show the path / Teach me the why). Essentials count 6 → 7; total
interview 17 → 20 (essentials 7 + deep 13). Profile template updated, SKILL.md
counts swept, README + install.sh + op-welcome + EXPLAINER + 19a + 19b all
synced.

---

#### P1.3 [P1] — Deep-mode questions assume jargon the essentials gloss

**[shipped 2026-05-27 — commit `cdbf591`, landed in `[0.10.0]`]** Q0A and Q0B
gloss "Opus" (Claude's most capable but slowest and most expensive model) and
"multi-agent review" (several Claude sessions checking the same code in
parallel). Deep-question header count "~10" → "13".

---

### Pillar 2 — Self-improvement loop has no curation nudge

`op-suggest` is the best-designed skill in the library (4 narrow triggers,
explicit exclusions). `/curate` is solid. **But the loop has no closure** —
`chapters/personalization/19c-suggestion-loop.md:84-86` explicitly rejects
auto-nudging on queue growth, leaving the user to remember. For a system
marketed as "self-improving," capture-without-curation becomes a graveyard.
This is the single missing flywheel.

#### P2.1 [P1] — Ship the 5+-pending curation nudge

**[shipped 2026-05-28 — landed in `[0.10.0]`]** Implemented as a new auto-firing
skill (`skills/core/op-curate-nudge/SKILL.md`) rather than a Stop hook — keeps
the pattern consistent with `op-welcome` and `op-spine-active`, and the
"once per conversation" gate is enforced by the model rather than a marker file.
Fires when SUGGESTIONS.md has 5+ pending AND the latest `bucket/CHANGELOG.md`
date is >30 days ago (or never). Lines 84-86 of `19c-suggestion-loop.md`
rewritten — replaces the v1 "deliberately does not auto-propose" paragraph
with the bounded conversation-start variant + rationale (the per-capture
variant remains rejected). Skill count 21 → 22.

---

#### P2.2 [P1] — Add `Last fired:` field to `bucket/INDEX.md` rows

**[shipped 2026-05-28 — landed in `[0.10.0]`]** New fourth column on both
Skills and Chapters tables in `bucket/INDEX.md`. `op-bucket-router/SKILL.md`
gains a "Stamping Last fired" section (single carve-out from the
"don't modify the bucket" rule). `op-add-skill/SKILL.md` and `op-curate/SKILL.md`
extend their row-append format to include `Last fired: —`. `refresh-bucket`
preserves the column across rebuilds. `op-curate/stale-review.md` rewritten:
two-tier candidate pool (never-fired-and->90-days first, then
fired->6-months-ago).

---

### Pillar 3 — Workflow leaks five inferable attention points

The ambient cold-start is good. The Stop hook is well-designed. `/done` is
comprehensive. **But five per-session friction points are inferable by Claude**
— the user is still doing work the system could do. Saved per session: ~3-5 min.

#### P3.1 [P1] — Auto-infer scope list from build steps in `op-prepare`

Session entry with build steps "Create schema / Add API route / Wire UI" →
propose scope list (`schema.ts, routes/api.ts, Form.tsx`). User edits.
Touches `skills/core/op-prepare/procedure.md` near session-plan generation.

#### P3.2 [P1] — Scaffold verify checks by recognized pattern

Common patterns (auth flow, CRUD endpoint, API+UI, RLS) have predictable
verify lists. When `op-prepare` detects one, scaffold the checks; user refines.
Touches `op-prepare/procedure.md` and `templates/SECTION_PLAN.md`.

#### P3.3 [P1] — Proactive next-section planning nudge at `/done`

If `docs/PROGRESS.md` shows a `next-section` whose plan file doesn't exist,
`/done` should offer at completion: *"Section &lt;next&gt; has no plan file.
Run `/prep &lt;next&gt;` now? (Y/n)"* Prevents mid-session cold-start halts.
Touches `global/commands/done.md`.

#### P3.4 [P2] — Auto-extract cross-session notes from turn signals

Stop hook scans turn for cue phrases ("I found that," "discovered," "will need
to," "schema needs") and proposes them as cross-session-note candidates at
`/done`. Touches `global/hooks/spine-writeback.sh` and `global/commands/done.md`.

#### P3.5 [P2] — Long-session live signal

At 30+ assistant turns or 2h+ elapsed in a session, emit one soft signal:
*"Past typical session size — split now or push?"* Once per session. New
ambient skill or hook extension.

---

### Pillar 4 — First-run UX requires README literacy

A new user clones, runs `install.sh`, restarts Claude Code, and sees **nothing**.
No welcome, no `/onboard` prompt, no in-session tour. The README says "run
`/onboard`" but the system itself doesn't say it. The discovery surface for the
20 skills + 7 commands + 80 chapters is "go read the repo."

#### P4.1 [P0] — Auto-prompt `/onboard` on first run

**[shipped 2026-05-27 — commit `f18c905`, landed in `[0.10.0]`]** New
`skills/core/op-welcome/` sibling to `op-spine-active`. Auto-fires once when
`~/.claude/claude-spine-profile.md` is missing; emits a short welcome block
pointing at `/onboard`. Silent once the profile exists. Skill count 20 → 21
at the time of landing.

---

#### P4.2 [P1] — Add `/spine` command listing active skills, commands, profile

**[shipped 2026-05-27 — commit `f18c905`, landed in `[0.10.0]`]**
`global/commands/spine.md` ships. Reads disk every time — never hard-codes
counts. Prints profile path + status, slash commands list, op-* skills with
one-line triggers, chapters root, bucket state, pending-suggestions count.
Read-only, single-shot. Slash-command count 7 → 8 at the time of landing
(Pillar 6 later took it to 9).

---

#### P4.3 [P1] — `op-onboard` final line hands off to `/prep`

**[shipped 2026-05-27 — commit `f18c905`, landed in `[0.10.0]`]** Replaced the
prior terse three-bullet farewell with a structured "what just happened" + "you
have available now" + "what to do next" handoff block. Names every slash
command with a one-line use; explicitly points at `/prep` for new projects.
The post-essentials writeback step that proposes raising `autoCompactWindow` +
`effortLevel` for Max 20× users landed in the same commit (it shares the same
file region).

---

#### P4.4 [P2] — Landing page screenshot + profile example

`landing/index.html` has no screenshot, no profile example, no before/after.
Content work, post-launch.

---

### Pillar 5 — Two skill triggers fail their benchmark

20-skill set is right-sized overall. **But the skill-trigger benchmark shows
0% TP on `op-persistence` and `op-signaling`.** Test-harness caveat applies
(one-shot mode under-counts routing skills), but the descriptions themselves
are too broad to defend.

#### P5.1 [P1] — Tighten `op-persistence` trigger description

**[shipped 2026-05-28 — landed in `[0.10.0]`]** Description rewritten. Leads
with "deciding *where* a behavior or rule should persist across sessions"; adds
literal trigger phrases ("should this go in a skill or CLAUDE.md?", "I keep
telling Claude X every session"); body branches into the sub-tasks once routed.
NOT-for clause covers code-level persistence (localStorage, Redis, DB schemas,
session state). Eval-set unchanged — all 5 should-trigger queries still match;
benchmark re-run deferred to a separate session.

---

#### P5.2 [P1] — Tighten `op-signaling` or merge into `op-recovery`

**[shipped 2026-05-28 — landed in `[0.10.0]`]** Option (a) — tighten, not
merge. Description rewritten with user-facing trigger phrases ("are we still
in scope?", "is context filling?", "you contradicted yourself", "why didn't
you flag X earlier?", "you flag too often / not enough") plus the meta-scope
trigger (user proposing to extend Claude's setup). NOT-for clause covers
code-level signaling (SIGTERM, loading spinners, WebSocket events, notification
system design). Decision on (b) remains revisitable post-launch if real-session
data shows the skill still under-fires.

---

### Pillar 6 — High-value hooks taught but not shipped

`chapters/persistence/14b-hook-recipes.md` teaches 6 hooks; only 2 ship in
`global/settings.json`. For a "global usage workflow" install, more defaults
are defensible.

#### P6.1 [P1] — Ship `block .env on git commit` (default-on, mandatory)

**[shipped 2026-05-28 — landed in `[0.10.0]`]** Sibling `block-env-commit.sh`
(not an extension of the staging hook) — keeps the two scripts independently
testable. Reads `git diff --cached --name-only` for `.env*` final-segment
matches and denies with a remediation hint. Wired in `global/settings.json`
as a second `if`-gated entry under the existing PreToolUse Bash matcher.
12-case fixture (`tests/hooks/test-block-env-commit.sh`) sets up a throwaway
git repo to exercise the deny / allow decisions.

---

#### P6.2 [P1] — Ship `notify-on-long-task` (default-on)

**[shipped 2026-05-28 — landed in `[0.10.0]`]** `global/hooks/notify-long-task.sh`
ships. macOS uses `osascript display notification`; Linux uses `notify-send`;
cross-platform fallback is the terminal bell. Wired in `global/settings.json`
as a new `Notification` event hook. Graceful-fail throughout — never blocks
Claude even on malformed input.

---

#### P6.3 [P1] — Add `/hooks` listing command

**[shipped 2026-05-28 — landed in `[0.10.0]`]** `global/commands/hooks.md`
ships as a standalone command (not a subcommand of `/spine` — keeps each
discovery surface narrow). Reads `~/.claude/settings.json` plus any
project-level `.claude/settings.json`; prints one row per configured hook with
event, matcher / `if` filter, and resolved script path. Read-only single-shot.
Slash-command count 8 → 9.

---

#### P6.4 [P2] — Opt-in `typecheck-after-edit` via onboard deep mode

Add to `skills/core/op-onboard/questions-deep.md`: *"Auto-typecheck after
`.ts`/`.py` edits? (Y/n)"* If yes, write the hook to `~/.claude/settings.json`
post-onboard.

#### P6.5 [P2] — Opt-in `format-on-save` via onboard deep mode

Same pattern as P6.4. Stack-specific (prettier/black/gofmt); auto-detect from
`package.json` / `pyproject.toml` / `go.mod` and offer the matching formatter.

---

## What is explicitly NOT a bug

- `CHANGELOG.md:53` "19 core skills" — this is inside the `[0.9.0]` release
  block. v0.9.0 shipped with 19 skills. L10 (in `[Unreleased]`) is what adds
  the 20th. The line is correct in context. **Do not change.**
- `CHANGELOG.md:101` "18 op-* skills" — historical, describing the v1→v2
  legacy cleanup. **Do not change.**
- `RECONSTRUCTION.md:99` references to `op-manual-profile.md` — historical
  Phase-6 narrative recording the pre-rename path. **Do not change.**
- v1 root stubs still naming "18 chapters" — that count refers to the v1
  numbered chapters (01..18), not the v2 atomic chapters. Reference is correct.

---

## Suggested apply order

**Drift sweep (~20 min, do first — clears the deck for pillar work):**

1. **One PR, ≤15 lines** — H1, H2, H3, H4 (the four count-drift fixes).
   Title: `docs: sweep skill count 19→20 and refresh EXPLAINER numbers`.
2. **File move + breadcrumb** — M1 (archive PLAN-AMBIENT-WORKFLOW.md).
   Title: `docs: archive L10 planning doc — ambient workflow shipped`.
3. **Tiny patch** — M2 (broken JANITOR links).
4. **Janitor reset** — M3 (close out resolved items, file a fresh JANITOR with
   the M4 + L items as the new open list).

**Pillar work (one focused session per pillar, ordered by launch impact):**

5. **Pillar 4 — first-run UX** (P4.1, P4.2, P4.3). Most visible to new users.
   ~1-2 hours. Includes the one P0 outside the drift sweep.
6. **Pillar 1 — personalization payload** (P1.1, P1.2, P1.3). Biggest
   promise-vs-implementation gap. ~2-4 hours.
7. **Pillar 2 — self-improvement closure** (P2.1, P2.2). One hook + INDEX
   field. ~1-2 hours. Single highest-impact change for "self-improving."
8. **Pillar 5 — skill trigger tightening** (P5.1, P5.2). ~1 hour + benchmark
   spend (`tests/skill-triggers/run.sh` ~$5).
9. **Pillar 6 — ship default-on hooks + `/hooks` command** (P6.1, P6.2, P6.3).
   ~2 hours.

**Post-launch (defer):**

10. **Pillar 3 — workflow auto-inference** (P3.1–P3.5). ~half-day; needs
    real-user signal on which inferences are right.
11. **Pillar 6 — opt-in hooks via onboard** (P6.4, P6.5). Needs the deep
    onboard flow extension first.
12. **L1–L5** — original deferred items per prior decisions.

**Estimated totals:**
- Pre-launch (drift + pillars 4, 1, 2, 5, 6 partial): ~1-2 working days.
- Post-launch: ~half-day + opt-in extensions as needed.
