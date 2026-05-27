# FIXES — senior review pass, 2026-05-27

> Two passes are stacked in this file:
>
> **Pass 1 — drift catalog (HIGH / MEDIUM / LOW below).** From a fresh review
> on `main`. The previous internal audit in [`docs/JANITOR.md`](docs/JANITOR.md)
> shipped most of its items (op-prepare split, PERSONALIZATION archived,
> EXPLAINER pricing reframe). What's listed here is **new drift since that pass**
> — almost entirely a consequence of L10 adding `op-spine-active` (skill count
> 19 → 20) and L10's planning doc still living at the repo root. These are
> maintenance defects — outdated numbers, residual planning doc, broken links.
> Total work: ~20 minutes.
>
> **Pass 2 — strategic pillar findings (`## Pillar findings` further down).**
> From a deeper pre-global-launch review. Unlike the drift items, these are
> *content / architecture gaps* — a partly-hollow personalization promise on
> the README, a self-improvement loop with no closure, predictable workflow
> attention-leaks, first-run UX that requires README literacy, two weak skill
> triggers, and high-value hooks taught but not shipped. Six pillars; tackle
> one per session.

## Live counts on disk (truth source as of 2026-05-27)

- `op-*` skills under `skills/core/`: **20**
- `.md` files under `chapters/`: **80**
- Onboarding questions: **6 essential + ~11 deep = 6–17 total**

Anywhere a doc claims numbers different from the above and is making a
*current-state* claim (as opposed to historical/changelog narrative), it's wrong.

---

## HIGH — visible to readers, sweep before the next push

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

The fix is already scoped in `docs/SUBSCRIPTION-AWARENESS.md:30-49` (3 sessions
of work). Steps:

1. Write `chapters/personalization/19f-subscription-aware.md` — mirror the
   lever table at `docs/SUBSCRIPTION-AWARENESS.md:19-28` as concrete prose.
2. Add an INDEX.md row.
3. Update `skills/core/op-foundations/SKILL.md`, `op-tools/SKILL.md`,
   `op-subagents/SKILL.md`, `op-signaling/SKILL.md` — each references 19f
   and branches on `Plan:` / `Cost sensitivity:`.
4. Spot-check by re-onboarding as Free and Max 20×; confirm tone shifts.

#### P1.2 [P1] — Onboard Q5 conflates tone and depth

Q5 options ("Just the answer," "Short and clear," "Walk me through," "Teach me")
mix *how short* with *how much background*. A user who wants short answers but
full reasoning has no good option.

**Fix:** split into two questions in `skills/core/op-onboard/questions-essential.md`:

- Q5a — "How short should answers be?" (Terse / Standard / Verbose)
- Q5b — "How much should you explain reasoning?" (Just the answer / Show the
  path / Teach me the why)

Two new profile fields; both read by `op-collaboration-modes` and `op-prompting`.

#### P1.3 [P1] — Deep-mode questions assume jargon the essentials gloss

Essentials gloss "deploy (getting code online)" and "MVP (a first version to
show people)." Deep questions A3, C1, F1 reuse RLS / migrations / edge cases
without glossing.

**Fix:** sweep `skills/core/op-onboard/questions-deep.md` — apply the
plain-language gloss pattern from essentials. ~30 min.

---

### Pillar 2 — Self-improvement loop has no curation nudge

`op-suggest` is the best-designed skill in the library (4 narrow triggers,
explicit exclusions). `/curate` is solid. **But the loop has no closure** —
`chapters/personalization/19c-suggestion-loop.md:84-86` explicitly rejects
auto-nudging on queue growth, leaving the user to remember. For a system
marketed as "self-improving," capture-without-curation becomes a graveyard.
This is the single missing flywheel.

#### P2.1 [P1] — Ship the 5+-pending curation nudge

A single Stop-hook or `op-spine-active` extension: if `bucket/SUGGESTIONS.md`
has 5+ pending entries AND last `/curate` >30 days ago, emit *one* quiet line
at conversation start:

> "Your suggestion queue has 7 pending entries; consider `/curate` when you
> have 10 minutes."

Once per conversation, not per turn. Highest-impact change for "self-improving"
to be honest. Update `chapters/personalization/19c-suggestion-loop.md:84-86` —
replace the "v1 deliberately does not auto-propose" paragraph with the new
threshold rule and graveyard-prevention rationale.

#### P2.2 [P1] — Add `Last fired:` field to `bucket/INDEX.md` rows

Enables `/curate --review-stale` to surface "never-fired in 90 days"
candidates concretely instead of date-of-add only.

- `op-bucket-router` updates the row's `Last fired:` field on load.
- `op-add-skill` initializes it at creation.
- `op-curate` stale-review reads it; flags rows where `Last fired` is empty
  AND `Added` >90 days ago.

Touches `op-bucket-router/SKILL.md`, `op-add-skill/SKILL.md`,
`op-curate/stale-review.md`.

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

`op-spine-active` (or a new `op-welcome` sibling) should detect missing
`~/.claude/claude-spine-profile.md` and emit *once*:

> "Welcome to claude-spine. Run `/onboard` (2 min) to calibrate me to your
> stack and working style — every future session benefits."

Triggered by file absence, not message content. Silent after first emission.

#### P4.2 [P1] — Add `/spine` command listing active skills, commands, profile

User types `/` and sees 7 commands but no way to see the 20 op-* skills.
Add `global/commands/spine.md`: prints active skills, all slash commands,
profile path, INDEX.md location. Single-shot discovery surface.

#### P4.3 [P1] — `op-onboard` final line hands off to `/prep`

After `/onboard` completes, the procedure (`skills/core/op-onboard/SKILL.md`)
should end with: *"Profile saved. Next: open a session in a project directory
and run `/prep` to plan your first feature."*

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

`skills/core/op-persistence/SKILL.md:3` bundles 5+ tasks (CLAUDE.md editing,
skill design, library audit, "where to remember," hook vs CLAUDE.md choice).
Tighten to ONE primary trigger:

> "Use when deciding *where* a behavior should persist — CLAUDE.md vs skill
> vs memory vs hook. Body branches into the sub-tasks once routed."

Re-run `tests/skill-triggers/run.sh op-persistence` after the change.

#### P5.2 [P1] — Tighten `op-signaling` or merge into `op-recovery`

`skills/core/op-signaling/SKILL.md:3` blends three semantic categories and
reads like internal guidance, not a user-triggered router. Either:

(a) tighten to user-facing trigger ("flag when I'm drifting mid-session"), or
(b) merge mid-stream signaling into `op-recovery` and drop the skill.

Default: tighten, don't merge. Decide based on whether real-session signaling
questions surface post-launch.

---

### Pillar 6 — High-value hooks taught but not shipped

`chapters/persistence/14b-hook-recipes.md` teaches 6 hooks; only 2 ship in
`global/settings.json`. For a "global usage workflow" install, more defaults
are defensible.

#### P6.1 [P1] — Ship `block .env on git commit` (default-on, mandatory)

Closes the gap between `git add` (already blocked) and `git commit`. Same risk
profile as the existing PreToolUse hook. Extend `block-env-staging.sh` matcher
or add sibling `block-env-commit.sh`. Wire in `global/settings.json`.

#### P6.2 [P1] — Ship `notify-on-long-task` (default-on)

High-value, low-risk, no false positives. New `global/hooks/notify-long-task.sh`;
wire as `Notification` event in `global/settings.json`.

#### P6.3 [P1] — Add `/hooks` listing command

Currently the only way to see active hooks is reading `~/.claude/settings.json`.
Add `global/commands/hooks.md`: prints every configured hook with event +
matcher + script. Could also live as a subcommand of `/spine` (P4.2) — pick one.

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
