# FIXES — senior review pass, 2026-05-27 (closed 2026-05-28)

> **Status as of 2026-05-28:** All six pillars (1, 2, 3, 4, 5, 6) + the
> HIGH/MEDIUM drift sweep + M4 have shipped — Pillar 1 Session 1 + Pillars
> 2/4/5/6 (P6.1–P6.3) landed in `[0.10.0]`; Pillar 1 Sessions 2 + 3, Pillar 3
> (all five P3.X items), and **Pillar 6 P6.4 + P6.5** (opt-in onboard-deep
> hooks — typecheck-after-edit and format-on-save, default-off, wired through
> the new deep-onboard Hook tuning pass) land in the next `[Unreleased]`
> block. The open queue at this point is **P4.4** (landing-page screenshot +
> profile example, post-launch content work) and the LOW items L2–L4 + L6–L8
> (L5 shipped 2026-05-28 as a single-edit micro-pass; the file itself
> recommends folding most of the remainder into a single post-launch trim
> pass; see Suggested apply order at the bottom).
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
- Hooks under `global/hooks/`: **6** (`block-env-staging.sh`, `block-env-commit.sh`, `notify-long-task.sh`, `spine-writeback.sh`, plus two default-off opt-ins added by P6.4/P6.5: `typecheck-after-edit.sh`, `format-on-save.sh`)

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

### L5. `skills/core/op-prepare/procedure.md` — `~`-prefixed link

**[shipped 2026-05-28 — single-edit micro-pass]** The P3.1/P3.2 restructure of
Step 6 shifted line numbers, so the actual occurrences live at lines 114 and
174 (not the originally-noted line 134) — both `[05j](~/.claude-spine/...)`
markdown links. Both rewritten to repo-relative
`[05j](../../../chapters/workflow/05j-cold-start-protocol.md)`. Line 57's
`~/.claude-spine/...` path in backticks is left as is — it's a literal code
reference, not a markdown link, so the previewer-rendering issue doesn't apply.

---

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

**[All 3 sessions shipped — Session 1 in `187ddbe` / `[0.10.0]`; Sessions 2 +
3 land in the next `[Unreleased]` block]** Session 1 of the 3-session plan in
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
wired in Session 1. Session 3 was a read-through verification across all
four plan tiers (Free / Pro / Max 5× / Max 20×) — no cross-reference drift
found. The Session 3 docs sweep added a "The subscription line" section to
`chapters/prompting/09c-examples-and-anti-examples.md` (shows the same
`/code-review ultra` question producing different answers per profile) and
clarified `19f`'s "How to consult this chapter" wording so the indirect
injection path for the external plugin slash commands is accurate.

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

**[shipped 2026-05-28 — landed in `[Unreleased]`]** `skills/core/op-prepare/procedure.md`
Step 6 restructured into 6.1 (scope inference from build steps), 6.2 (verify
scaffolds — see P3.2), 6.3 (compose). Step 6.1 adds a build-step → file-shape
heuristics table (schema → migration with RLS inline; API route → `route.ts`;
server action → `actions.ts`; UI step → `page.tsx` + component; zod → `schema.ts`;
webhook → `app/api/webhooks/<service>/route.ts`; public flow → `app/(public)/…`;
email → `lib/email/templates/` + `lib/server/email.ts`). The proposal is
explicit and editable, not auto-applied — `op-prepare` surfaces it and the
user adds/removes/corrects.

---

#### P3.2 [P1] — Scaffold verify checks by recognized pattern

**[shipped 2026-05-28 — landed in `[Unreleased]`]** `skills/core/op-prepare/procedure.md`
Step 6.2 adds the pattern catalog. Seven patterns covered: **Auth flow**
(sign-up / sign-in / sign-out / protected route), **CRUD resource** (table +
list + form), **API + UI** (server action driving a UI), **RLS section**
(per-user data), **Public form** (unauth input — contact, public quote-accept),
**Webhook ingestion** (Stripe / Resend with signature + idempotency), and
**Migration-only session** (no UI surface). Each scaffold lists 3-5 concrete
verify checks the user refines. `templates/SECTION_PLAN.md` Verify-section
instruction now points at procedure §6.2 so a fresh user doesn't ship generic
"test it works" by default.

---

#### P3.3 [P1] — Proactive next-section planning nudge at `/done`

**[shipped 2026-05-28 — landed in `[Unreleased]`]** `global/commands/done.md`
Step 4 now (a) writes the existing "Section N+1 needs `/prep <name>`" note to
PROGRESS.md when the next-section plan file is missing AND (b) flags the
condition for Step 9. Step 9 surfaces an explicit offer:
*"Section `<next-section>` has no plan file. Run `/prep <next-section>` now?
(Y/n)"* On `Y`, `/done` hands off to `op-prepare` scoped to that section.
On `N` or no-answer, the PROGRESS.md breadcrumb remains and the next ambient
`op-spine-active` will halt cleanly with the same suggestion. No silent state.

---

#### P3.4 [P2] — Auto-extract cross-session notes from turn signals

**[shipped 2026-05-28 — landed in `[Unreleased]`]** `global/hooks/spine-writeback.sh`
restructured into three blocks (heartbeat / cue-capture / long-session — see
P3.5). The cue-capture block reads `transcript_path` from the Stop-hook input,
locates the most recent `"type":"assistant"` JSONL entry, extracts its text
content via jq, and greps for a tight set of forward-looking cues
(`cross.?session note`, `follow.?up:`, `for (the |a )?(next|later|future) session`,
`FYI for next session`, `note for next session`, `need to … in/before (next|later|future) session`,
`schema (will need|needs to)`, `carry.?over:`). Up to 5 matches per turn are
deduped and appended to a `## Pending cross-session notes` block in the
active section file. `/done` Step 2 reviews entries (promote / edit-promote /
dismiss) and deletes the block. Set is intentionally tight — better to
under-capture than to flood the Pending block.

---

#### P3.5 [P2] — Long-session live signal

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Implemented as a third
block in `global/hooks/spine-writeback.sh` (not a new skill — ambient skills
only fire at conversation start, and the signal needs to fire mid-session).
Per-session state lives under `$TMPDIR/spine-signals/<session_id>.{turns,start,long-session}` —
counter, epoch, and single-fire marker. The counter increments on every Stop
event (even on no-file-change turns), so a 30-turn conversational session
still trips it. The signal fires once per session_id at ≥30 turns OR ≥2h
elapsed, whichever first: *"spine: past typical session size (N turns, Mm
elapsed). split now or push? — see chapter 06 (feature sizing)."*

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

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Implementation departs
slightly from the FIXES sketch — the question lives in
`skills/core/op-onboard/SKILL.md` (`## Hook tuning (deep mode only)`), not in
`questions-deep.md`, because the answer writes to settings.json rather than
the personal profile (same architectural split as the existing
"Subscription-based settings tuning" step). `questions-deep.md` carries a
cross-reference at the end so the interview ordering remains obvious. The
hook itself ships as `global/hooks/typecheck-after-edit.sh` — default-off,
advisory only (exit 0 always), surfaces only errors mentioning the edited
file. 11-case test fixture under `tests/hooks/`.

#### P6.5 [P2] — Opt-in `format-on-save` via onboard deep mode

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Same Hook-tuning pass as
P6.4 (asked back-to-back in deep mode). The hook
(`global/hooks/format-on-save.sh`) walks up from the edited file to detect
the formatter: Prettier (package.json + `node_modules/.bin/prettier` or PATH
`prettier`), Black (pyproject.toml with `[tool.black]` + PATH `black`),
gofmt (go.mod), rustfmt (Cargo.toml). Silent skip when a project doesn't have
its formatter configured — the hook doesn't impose a style on projects that
haven't asked for one. 12-case test fixture under `tests/hooks/` uses PATH
shims so it doesn't depend on any real formatter being installed.

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

10. **Pillar 3 — workflow auto-inference** (P3.1–P3.5). **Shipped 2026-05-28
    — landed in `[Unreleased]`.** Pulled forward into pre-launch; the
    ~half-day estimate held. The "needs real-user signal" caveat survives as
    a tuning note — the cue-phrase set in `spine-writeback.sh` and the
    long-session thresholds (30 turns / 2h) are easy to adjust once real
    sessions reveal misses or false positives.
11. **Pillar 6 — opt-in hooks via onboard** (P6.4, P6.5). **Shipped 2026-05-28
    — landed in `[Unreleased]`.** Pulled forward into pre-launch; the
    "deeper onboard-deep extension" caveat was resolved by adding a `## Hook
    tuning (deep mode only)` pass to `op-onboard/SKILL.md` parallel to the
    existing "Subscription-based settings tuning" step. Two new
    `global/hooks/*.sh` scripts ship default-off; the settings.json entry
    (written only on opt-in via `/onboard --deep`) is the on/off gate.
12. **L1–L5** — original deferred items per prior decisions.

**Estimated totals:**
- Pre-launch (drift + pillars 4, 1, 2, 5, 6, and Pillar 3 + Pillar 6 P6.4/P6.5 pulled forward): ~1-2 working days. Shipped 2026-05-27 → 2026-05-28.
- Post-launch (now only L1–L5 trim pass and P4.4 content work): ~half-day, content-pending.

---

---

# Pass 3 — second senior review (opened 2026-05-28)

A second deep read across every file Claude loads at runtime (skills, INDEX, hooks,
install scripts, the global stubs, the templates Claude reads first in a project).
Findings split into three new tiers below. Most are stale-count drift the existing
Pass-1 sweep missed because it scoped only to README + EXPLAINER + landing; a
handful are genuine writing bugs or efficiency wins for the discovery surface.
One — `uninstall.sh` — is a real functional bug.

Heaviest themes:

1. **Hook drift is everywhere.** Pillar 6 quadrupled the shipped hook count (2 → 6)
   but install/uninstall scripts, the global INSTALL guide, and the README still
   talk about "the env-leak hook" in the singular. One hook actually goes
   uninstalled because `uninstall.sh` only `rm`s `block-env-staging.sh`.
2. **Question-count drift survived Pass 1.** Pass 1's H3/H4 swept the README +
   EXPLAINER, but `global/INSTALL.md`, `chapters/personalization/19b`, and the
   `/done` `uninstall.sh` comments still cite the pre-split 5/15/25-question
   numbers.
3. **`op-onboard/SKILL.md` is 286 lines** — five times the project's own
   "router skills stay ≤55 lines" thesis. Three large blocks (subscription tune,
   hook tune, handoff) should live in adjacent files the way `op-prepare/procedure.md`
   and `op-curate/stale-review.md` already do.
4. **INDEX.md doesn't tell Claude which skill owns each section.** Pure
   topic→file map. If no skill fires and Claude falls through to INDEX manually,
   she can't tell that `chapters/foundations/...` is `op-foundations`'s territory.
5. **18 skills repeat the same 2-line note** explaining how to expand `~`
   before reading. That's ~36 lines of pure boilerplate that bloats every
   loaded SKILL.md body. Either drop (Claude already knows what `~` means) or
   move to one anchor doc.
6. **One real writing bug** in `bucket/README.md:35` reverses the intended
   meaning of the "delete unused skills" rule.

The H-series numbering continues from Pass 1 (last was H4) — these are
H5–H10. Same for M (last was M4) — these are M5–M10. L continues from L8 — these
are L9–L14.

## HIGH — visible to users / breaks behavior

### H5. `uninstall.sh` only removes 1 of the 6 installed hooks

**Functional bug, not drift.** `install.sh:354-365` loops over
`global/hooks/*.sh` and `cp`s every file (6 hooks today:
`block-env-staging.sh`, `block-env-commit.sh`, `notify-long-task.sh`,
`spine-writeback.sh`, `typecheck-after-edit.sh`, `format-on-save.sh`). But
`uninstall.sh:132-139` only removes `block-env-staging.sh`:

```bash
echo "==> removing env-leak hook"
HOOK="$CLAUDE_DIR/hooks/block-env-staging.sh"
if [ -e "$HOOK" ] || [ -L "$HOOK" ]; then
  run rm -f "$HOOK"
```

After uninstall, the 5 other hook scripts stay on disk **and** the spine's
`~/.claude/settings.json` (which uninstall deliberately preserves as "user data")
still references all 6. Net effect: Claude Code starts up fine because the scripts
still exist — but the user thinks they uninstalled the spine. Worse, if a future
spine update changes a hook's behavior, the uninstalled-but-still-active hooks
will silently misbehave.

**Fix:** swap the single-file `rm` for the same `for hook_src in
"$SPINE_DIR"/global/hooks/*.sh; do ... done` loop install.sh uses. Also rewrite
the section banner (`# ---------- 3. env-leak hook ----------` → `# ---------- 3. hooks ----------`)
and the user-facing `echo "==> removing env-leak hook"` → `echo "==> removing hooks"`.

Decide separately whether uninstall should also `sed`-out the hook entries
from a preserved `settings.json`. Recommendation: don't — settings.json is
user-territory and may have hand-edits. Instead, add a closing note to the
uninstall summary: *"Your `~/.claude/settings.json` still references the
spine's hook scripts. If you want to keep settings but drop the hook
references, hand-edit the `hooks` block."*

### H6. `global/INSTALL.md` is wildly stale — 4 separate claims

`global/INSTALL.md` was last touched for L1 and hasn't been swept for any
subsequent pillar. Each of these is a current-state claim, not history:

- **Line 16 — hooks table cell:** only mentions `block-env-staging.sh` and
  `spine-writeback.sh`. Missing `block-env-commit.sh` (P6.1), `notify-long-task.sh`
  (P6.2), `typecheck-after-edit.sh` (P6.4, opt-in), `format-on-save.sh` (P6.5,
  opt-in). The table cell should list all four default-on hooks and note the
  two opt-in ones land via `/onboard --deep`'s Hook-tuning pass.
- **Line 18 — commands table cell:** missing `/spine` (P4.2) and `/hooks` (P6.3).
  Currently reads "`/prep` + `/done`" for the plan flow and lists onboard /
  suggest / curate / add-skill / refresh-bucket. Add the two discovery commands.
- **Line 31:** "`settings.json` and `~/.claude/hooks/block-env-staging.sh` are
  backed up …" — install.sh actually backs up every hook it overwrites. The
  phrasing should generalize to "settings.json and any hooks under `~/.claude/hooks/`".
- **Line 52:** "`/onboard` for the 5-question essentials, `/onboard --deep` for
  the full ~15-question interview." Pre-split. Should be **7-question
  essentials** and **~20-question interview** (7 essentials + 13 deep + 2
  hook prompts). Same fix Pass-1 H4 made to EXPLAINER.
- **Line 147 — uninstall description:** "the `~/.claude/skills/op-*`
  symlinks…, the `~/.claude/commands/*.md` symlinks the spine added,
  `~/.claude/hooks/block-env-staging.sh`, …" — singular hook reference, ties
  to H5 above. Once H5 is fixed, this line should say "all `~/.claude/hooks/*.sh`
  the spine installed" or list them.

This is one PR's worth of edits but five separate stale facts. Lump with H7
below.

### H7. `chapters/personalization/19b-profile-and-onboarding.md:35` — "25-question wall" stale

Inside the live "Two-tier interview" section (current-state framing, not
history): *"The whole point of the hybrid model is to not scare new users with
a **25-question wall** while still letting committed users get a fully-loaded
profile from day 1."*

Pre-split count. Today the wall is 20 (7 essentials + 13 deep) — still a wall,
but not a 25-question wall. Suggest:

> not scare new users with a 20-question wall

Bundled with H6 in the same sweep PR.

### H8. `README.md` — 3 "env-leak hook" singular references

Three current-state claims on the README (not changelog narrative):

- **Line 58 — Requirements:** "`bash`, `jq` (for the env-leak hook), `git`."
  Misleading — `jq` is now used by `block-env-staging.sh`, `block-env-commit.sh`,
  AND `spine-writeback.sh`. Suggest: *"`jq` (used by the safety hooks and the
  spine-writeback Stop hook)"*.
- **Line 152 — folder tree:** `│   ├── hooks/                   # env-leak hook`
  — should be `# safety hooks + Stop-hook writeback`.
- **Line 178 — fast suite description:** "Covers the env-leak hook
  (`global/hooks/block-env-staging.sh` …)" — but `tests/hooks/` actually has
  test fixtures for at least 3 hooks (`test-block-env-staging.sh`,
  `test-block-env-commit.sh`, plus the P6.4/P6.5 typecheck and format
  fixtures). The README description undersells what CI actually covers.

Sweep all three to the multi-hook framing.

### H9. `install.sh` — 3 singular-hook references in script comments + jq error

- **Line 5 — header docstring:** "Wires this clone into ~/.claude/ so Claude
  Code picks up the spine's skills, the global stub, the settings allowlist,
  and the env-leak hook." → "…and the safety + writeback hooks."
- **Line 14 — `--skip-hook` help:** "skip installing hooks (env-leak +
  spine-writeback)" — should drop the parenthetical or expand to all six.
- **Lines 92–103 — jq error block:** the error says *"jq is required for the
  env-leak hook (`global/hooks/block-env-staging.sh`)"*. True but
  incomplete — `block-env-commit.sh` and `spine-writeback.sh` also call jq.
  Rewrite the error as *"jq is required for the spine's hooks"* with a
  one-line list. Without this fix, a user who installs without jq AND skips
  the env-leak hook with `--skip-hook` won't learn that the other hooks
  will silently no-op too.

### H10. `uninstall.sh` — header + banner reference "env-leak hook" singular

Same string-sweep family as H5/H8/H9, but separable since these are
script-comment / user-message strings rather than the loop bug:

- **Line 4 — header:** "Removes the spine's symlinks and the env-leak hook
  from ~/.claude/."
- **Line 132 — section banner echo:** `echo "==> removing env-leak hook"`

Once H5's loop fix lands, both should become "hooks" (plural).

---

## MEDIUM — architecture / efficiency / discoverability

### M5. `op-onboard/SKILL.md` is 286 lines — violates the project's own router-skill ceiling

The bucket-skill template (`skills/core/op-add-skill/bucket-skill-template.md:46`)
codifies the rule:

> Use this when the body needs templates, question banks, checklists, or
> anything else that should be loaded on-demand. Same frontmatter rules as
> single-file. **SKILL.md stays ≤55 lines** and routes to the adjacent files.

`op-prepare/SKILL.md` (54 lines) routes to `procedure.md` (174 lines).
`op-curate/SKILL.md` (55 lines) routes to `stale-review.md` (49 lines).
`op-onboard/SKILL.md` is **286 lines** — by far the largest in the repo —
and could split into three adjacent files the same way:

- **Stays in SKILL.md (~75 lines):** frontmatter, "Mode selection" (4 entries),
  "Adjacent files" table, the 7-step "How to run the interview" outline,
  "Rules" section, the handoff intro that says "see the handoff file".
- **`subscription-tune.md` (~50 lines):** the mapping table + the 7-step
  Apply/Skip flow + the templated plain-English block.
- **`hook-tune.md` (~135 lines):** the per-hook pre-flight, the G1/G2 question
  text + plain-English blocks, the Case A/B/C write logic, the Hand-edit
  fallback. This is the largest single block today.
- **`handoff.md` (~50 lines):** the "After writing the profile" template + its
  hard rules.

Why this matters: `op-onboard/SKILL.md` is loaded every time the `/onboard`
command fires or the user mentions onboarding. The Hook-tuning block (~135
lines) is irrelevant on essentials-only runs. The handoff block (~50 lines)
matters only at the end. Splitting cuts the typical onboarding-conversation
load by roughly half, in line with how every other multi-file skill in this
repo is structured.

### M6. 18 skills repeat the same 2-line `~/.claude-spine/...` path note

Every routing skill body opens with some variant of:

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home
> directory (`$HOME`) before reading with the Read tool. `install.sh` ensures
> `~/.claude-spine` resolves to your spine clone.

Repeated in: `op-foundations`, `op-workflow`, `op-prompting`, `op-signaling`,
`op-tools`, `op-anti-patterns`, `op-collaboration-modes`, `op-persistence`,
`op-subagents`, `op-brownfield`, `op-prepare`, `op-recovery`, `op-hooks`,
`op-visuals`, `op-add-skill`, `op-bucket-router`, `op-suggest`, `op-curate`,
`op-onboard`. **18 skills × ~12 lines (including the surrounding blockquote +
blank lines) = ~36–55 lines of pure boilerplate** that loads alongside the
matched skill's actual content.

Two options:

(a) **Drop entirely.** Claude already knows `~` is `$HOME`; this note doesn't
    add behavior, it adds friction. The skills that *don't* have this note
    (the auto-firing trio: `op-spine-active`, `op-welcome`, `op-curate-nudge`,
    plus `op-suggest` which has a shorter one-line version) operate fine
    without it.

(b) **Replace with a one-line reference** in any skill that wants to be
    self-contained: *"Expand `~` to `$HOME` per [13a-skill-anatomy]."* Add a
    short "How to read `~/.claude-spine/...` paths" subsection to
    `chapters/persistence/13a-skill-anatomy.md` as the single source of
    truth, since 13a already covers skill-file mechanics.

Recommendation: (a). The note is over-cautious; the global CLAUDE.md stub
already establishes `~/.claude-spine` as the spine path.

### M7. `INDEX.md` doesn't surface which `op-*` skill owns each section

INDEX.md is the chapter-routing fallback when no skill fired. Today it's a
pure topic→file map — Claude reads it, picks the file, reads. But each chapter
section is also routed by exactly one `op-*` skill (Foundations → `op-foundations`,
Workflow → `op-workflow`, etc.) and there's no signal of that in INDEX.md.

Two consequences:

1. If Claude reads INDEX.md as the fallback and picks a chapter, she doesn't
   know there's a routing skill that already knows the per-question subset.
   She'll read the chapter cold, missing the skill's "common triggers" table
   that maps user phrases to specific files.
2. A user reading INDEX.md as documentation can't tell which skill fires for
   which area — they have to grep `skills/core/op-*/SKILL.md` separately.

**Fix:** add a one-line note under each `## <Section>` heading in INDEX.md
naming the routing skill. E.g., under `## Foundations — how Claude Code
actually works`:

> *Routed by `op-foundations`. When that fires, use its trigger-keyword
> table instead of reading this section cold.*

This adds 9 lines total (one per topic section) and gives both Claude and
human readers the missing skill→chapter mapping in one place. Bonus: 19f
(subscription-aware) cross-references the routing skills already; the same
pattern works upstream.

### M8. `op-hooks/SKILL.md` index doesn't preview the spine's 6 shipped hooks

`op-hooks` routes to chapters 14a (settings cascade) and 14b (hook recipes).
14b's "Recommended starter set" was updated in P6.1/P6.2/P6.4/P6.5 to mention
the spine's shipped + opt-in hooks. But `op-hooks/SKILL.md` itself doesn't —
its index only lists the two chapter files. A user asking "what hooks does
claude-spine ship?" matches `op-hooks` (good), reads the SKILL.md (no
spine-specific info), then has to follow through to 14b's last paragraph to
find out.

**Fix:** add a third index row pointing at the live truth source:

| Question / situation | Atomic file |
|---|---|
| What hooks does claude-spine ship out of the box? | `~/.claude/settings.json` (read directly — or run `/hooks` for a formatted view) |

And/or add a "Spine-shipped hooks" subsection in the SKILL.md body listing the
six scripts with one-line descriptions. Pick one — both is overkill.

### M9. `bucket/README.md:35` — writing bug, reversed meaning

**[shipped 2026-05-28]** Bullet rewritten in place:

> If a skill *never* fires (or fires only once across many sessions),
> delete it — see `op-curate/stale-review.md` for the precise stale-review
> thresholds (never-fired-and->90-days, or last-fired->6-months).

The new wording matches `op-curate/stale-review.md:9-12` directly, so the
README and the curation skill now disagree about nothing. The cross-reference
also gives a curious reader a path to the rationale instead of asking them to
trust the rule cold.

---

Current text:

> One-off snippets you'll never reach for again. The bucket is for patterns
> you'll *route to* repeatedly. **If a skill fires twice ever, delete it.**

The intent is clearly "delete unused skills," but the rule as written says
"delete any skill that fires exactly twice" — which would mean keeping
never-fired and once-fired skills but pruning twice-fired ones. That's the
opposite of the stale-review logic in `op-curate/stale-review.md:9-12` (which
considers never-fired-and->90-days the *strongest* prune signal).

**Fix:** rewrite as

> If a skill *never* fires (or fires only once across many sessions), delete it.

…or rewrite the whole bullet to match the stale-review thresholds directly.
This is a small line but the README is the user's entry into the bucket, so
the wrong rule here misroutes a user's first prune-pass intuition.

### M10. Skill description verbosity is uneven — two outliers worth tightening

Skill `description:` fields are the matcher. Token count matters for skill
selection. Today they range from ~50 words (`op-visuals`) to ~150 words
(`op-foundations`, `op-suggest`). The outliers:

- **`op-foundations`:** ~150 words ("Use when asking how Claude Code actually
  works under the hood, how the LLM loop and tools combine, what the three
  levers…"). Could compress to ~80 by collapsing the question-list into 3-4
  high-leverage phrases ("how Claude Code's loop works", "context budget",
  "model + plan tradeoffs", "project-fit / hard limits"). Routes-here behavior
  unchanged.
- **`op-suggest`:** ~155 words. Includes the four conditions, the explicit
  NOT-for list, AND the never-modifies-X postscript. The body already has
  all of this in tabular form; the description could drop to the four
  triggers + the one "never modifies core" guarantee.

Not urgent — these descriptions fire correctly in the benchmark. Tighten if
the trigger benchmark is re-run for any reason and shows margin loss.

---

## LOW — minor

### L9. `op-onboard/SKILL.md:31` — "Right after Q6" cryptic after Q5 split

Step 3 reads *"Right after Q6: save the profile."* Q6 is the 7th (and last)
essential, but only the reader who has memorized the question list knows that.
Q5a + Q5b were added between original Q5 and Q6. Suggest:

> 3. **After all 7 essentials are captured (Q1 → Q6):** save the profile.

Single-line clarity edit; preserves the Q6 anchor for find-in-file but kills
the "wait, isn't Q6 the 6th?" doubt.

### L10. `global/commands/onboard.md` description doesn't mention the Hook-tuning pass

The command file (which is what the harness reads to surface `/onboard` to
the user) describes only the question count:

> Run or re-run the claude-spine personal profile interview. Pass --deep for
> the full ~20-question interview; otherwise runs the 7-question essentials.

In `--deep` mode, `op-onboard` now also runs Subscription-based settings
tuning AND Hook tuning (G1 + G2 prompts), both of which write to
`~/.claude/settings.json`. A user who types `/onboard --deep` expecting only
a longer interview gets two settings-write prompts at the end. Suggest:

> Run or re-run the claude-spine personal profile interview. `--deep` runs
> the full ~20-question pass plus two opt-in `settings.json` tweaks (auto-
> typecheck + auto-format hooks). The 7-question essentials path also
> proposes a one-time `settings.json` tune sized to your Claude plan.

### L11. `/hooks` command examples don't show the opt-in pair

`global/commands/hooks.md:28-31` example output:

```
PreToolUse   [Bash · if Bash(git add*)]      →   ~/.claude/hooks/block-env-staging.sh
PreToolUse   [Bash · if Bash(git commit*)]   →   ~/.claude/hooks/block-env-commit.sh
Notification                                  →   ~/.claude/hooks/notify-long-task.sh
Stop                                          →   ~/.claude/hooks/spine-writeback.sh
```

Accurate for the default install. But users who opt into typecheck/format via
`/onboard --deep` will see two additional `PostToolUse` rows that aren't
previewed here. Add one more row in the example with a `[opt-in via /onboard
--deep]` annotation so users don't think their `/hooks` output is malformed.

### L12. `global/commands/done.md` Step 5 doesn't mention plan updates from Pending notes

Step 2.3 (`Pending cross-session notes` review) can surface a promoted note
that names a new section or a section-shape change. Step 5 ("Check for
plan-level updates") only mentions "a major change happened (a new section
needed, a section's done-criteria changed, a risk materialized)" without
linking back to the cross-session-notes review as a source of such changes.
One-line tie: *"If a promoted note from Step 2.3 implies a new section or a
changed dependency, surface it here."*

### L13. `tests/run.sh:28` — "env-leak hook and the fixture" singular

Same string-sweep family as H8/H9/H10. Once the H-series fix lands, sweep
this one too. The fast suite actually covers multiple hook fixtures now.

### L14. `/done` Step 9 — "invoke it as the next action" is ambiguous

Reads: *"**Y** → hand off to `op-prepare` scoped to that section (`/prep
<next-section>`). Don't wait for the user to type — invoke it as the next
action."* Claude can't type a slash command on the user's behalf (slash
commands are user-input). What's meant: execute the procedure that `/prep
<section>` would run — i.e., read `op-prepare/SKILL.md` + `procedure.md` and
run them scoped to `<next-section>`. Rephrase for clarity:

> **Y** → execute the `op-prepare` procedure scoped to `<next-section>` —
> read `~/.claude-spine/skills/core/op-prepare/procedure.md` and follow it
> as if `/prep <next-section>` had just fired. Don't wait for the user.

---

## Pass-3 suggested apply order

The H-series is one PR's worth of string sweeps + the uninstall bug. Most of
the M-series is its own PR per item. L is post-launch.

1. **PR 1 — uninstall hook-loop fix** (H5). Smallest functional bug; ship first.
   Test: run `./install.sh --dry-run` and `./uninstall.sh --dry-run` back to back
   on a clean throwaway dir and confirm the same six hooks appear in both.
2. **PR 2 — hook + count drift sweep** (H6, H7, H8, H9, H10). Pure text edits
   across `global/INSTALL.md`, `chapters/personalization/19b`, `README.md`,
   `install.sh`, `uninstall.sh`. ≤30 lines total; one commit per file.
   Title: `docs: sweep stale "env-leak hook" singulars + 25-question wall`.
3. **PR 3 — `bucket/README.md:35` rewrite** (M9). One-line fix; bundle with
   PR 2 or ship standalone.
4. **PR 4 — INDEX.md skill-routing column** (M7). Touches one file, adds 9
   lines. Improves discovery surface for any future Claude that falls
   through to INDEX manually.
5. **PR 5 — `op-onboard/SKILL.md` split into adjacent files** (M5). Largest
   net edit but most direct win for per-conversation token cost. Pattern is
   already established by `op-prepare` and `op-curate`.
6. **PR 6 — boilerplate-note trim across 18 skills** (M6). Mechanical
   replace-all. Recommend option (a) — delete entirely. Add a brief paragraph
   in `chapters/persistence/13a-skill-anatomy.md` if the rule needs to live
   *somewhere*.
7. **PR 7 — `op-hooks/SKILL.md` spine-hooks index row** (M8). Two-line edit.
8. **Post-launch — L9–L14 bundle** with the JANITOR-item-13 trim pass.

**Estimated totals:**
- PR 1 (H5 functional fix): 15 min including running the fixture twice.
- PR 2 (drift sweep): ~30 min.
- PR 3 (one-line): ~5 min.
- PR 4 (INDEX routing column): ~20 min.
- PR 5 (op-onboard split): ~1–2 hours, plus re-running `tests/skill-triggers/run.sh op-onboard` to confirm the trigger description still matches (description doesn't change in this PR — only body — so the benchmark should be unaffected; verify regardless).
- PR 6 (boilerplate trim): ~30 min as a `replace-all` sweep, then one read-through.
- PR 7 (op-hooks index row): ~10 min.

Total pre-launch: ~3–4 hours. Post-launch L bundle: ~30 min.

---

---

# Pass 4 — Global-readiness review (opened 2026-05-28)

> **Progress as of 2026-05-28 (later same day, second sweep):** **B1, B2, B3,
> B4, B5, B6 (partial), B7, B8, N2, N6 (partial), N7, P1** plus the chapter
> prose strip (BIAS-AUDIT Priority 0 #3) and the format/typecheck hook
> expansion (BIAS-AUDIT Priority 1 #7) all landed in `[Unreleased]`.
>
> **Round-1 (earlier 2026-05-28):** neutral-default `global/settings.json`
> (broadened Bash + WebFetch allowlists, three plugins default-off), Q3
> restructured to product-shape families, B2 ("stacks to avoid") neutralized
> to free-text only, `op-spine-active` accepts four plan-layout conventions +
> a project-level `Plan layout:` override.
>
> **Round-2 (this sweep, derived from `BIAS-AUDIT.md`):** chapter prose
> stripped of Next/Supabase/Stripe specifics (12b-claudemd.md restructured
> with three multi-stack worked examples; 05b/05c/06/15h prose generalized);
> `op-prepare/procedure.md` Step 6.1 expanded to an 8-column per-stack file
> shapes table; Step 6.2 patterns renamed concept-first (RLS section →
> Per-row authorization; Mutation endpoint + UI; added CLI subcommand +
> Library public method patterns); Step 5 section-ordering templates added
> per project type (web SaaS, backend service, CLI/library, ML pipeline).
> Templates split: main `templates/{CLAUDE,ARCHITECTURE,DEPLOY,SMOKE_TESTS,DECISIONS,PROJECT_BRIEF,FEATURES,PROJECT_PLAN}.md`
> are now stack-agnostic skeletons; the previously-shipped worked Next/
> Supabase versions moved to `templates/examples/web-saas-next-supabase/`
> with a "this is a worked example" preamble. `global/opinionated/` renamed
> to `global/stacks/ts-next-supabase/`; one sibling
> `global/stacks/python-django/` added to demonstrate the multi-stack
> pattern; `install.sh` gained `--stack=<name>` flag (`--opinionated` kept
> as backward-compat alias for `--stack=ts-next-supabase`) with a
> validation step that lists available stacks if `<name>` doesn't resolve.
> `format-on-save.sh` + `typecheck-after-edit.sh` extended from 4 → ~10
> language detection paths (Ruby, PHP, Java, Kotlin, Swift, C#, shell,
> Elixir, Lua, C/C++ for format; Go, Rust, C#, Ruby, PHP added for
> typecheck; Python typecheck upgraded from py_compile-only to mypy →
> pyright → ruff → py_compile fallback). `templates/PROGRESS.md` got a
> bold HTML-comment marker above the Section/Session bullets warning that
> spine-writeback parses them by regex (N2). README cost framings
> ("~$5–10 (Sonnet)") replaced with token-count + Anthropic-pricing-link
> framings (N7).
>
> **What remains:** **B9** (un-audited chapter pass for project-type
> assumptions), **B10** (Windows installer), **B11** (i18n hook), **N1**
> (profile-settable thresholds — biggest single user-overridable-thresholds
> win), **N3/N4** (op-curate-nudge + op-suggest parser cleanups), **N5**
> (jq-based settings.json mutation in op-onboard — tied to P2 op-onboard
> split), **N8** (cue-phrase config — tied to N1), **C-block** (command
> consolidation 9 → 6), **U-block** (UX polish — Q1 mapping table extension
> for Free, onboard preview screen, /profile explain, cheatsheet), **P2-P4**
> (op-onboard split + skill boilerplate trim + per-stack CLAUDE.md split —
> the new per-stack templates are still ~260 lines each; P4 says move
> Sections 2-9 into an `op-tim-flavor`-style skill loaded on demand). The
> **new-onboard-questions** pass (OS / VCS / project type essentials + the
> 5 deep follow-ups from BIAS-AUDIT §10) is also still open — it needs
> count sweeps across 8+ surfaces (README, EXPLAINER, INSTALL, op-welcome,
> op-onboard, 19a, 19b, landing, /onboard description, install.sh).

A different lens from Passes 1–3, which were maintenance / audit. **This pass
asks: would someone outside the founder's stack feel welcome here? Would the
product feel refined by global-product standards?** The answer right now is
*partial*. The mechanics are solid; the discipline is universal; the
*content* is opinionated in ways the marketing doesn't admit, and the
*defaults* carry hidden assumptions (thresholds, hostnames, filesystem
layout) that lock the product to one operator's habits.

Five themes, lettered to avoid colliding with Pass-1/2/3's H/M/L numbering.
**B** = bias, **N** = naïve / lazy logic, **C** = command surface,
**U** = UX for a global audience, **P** = performance / context cost.

Headline: **the spine sells itself as a universal Claude Code discipline,
but ships as one operator's TS / Next.js / Supabase / Vercel toolkit with
a thin "neutral" variant on the global CLAUDE.md.** The disclaimer
"opinionated for solo-founder / MVP / agency work in TS / Next.js /
Supabase" is buried at `global/INSTALL.md:129` and the README's framing
("operating-discipline layer") promises something else. Fix this and the
product reads as a product. Don't fix it and it reads as a personal dotfiles
repo someone open-sourced.

---

## B — Stack / cultural bias (the most important block)

**91 references** to `supabase|vercel|next.js|tailwind|shadcn|resend|stripe|NEXT_PUBLIC|EXPO_PUBLIC`
exist across `chapters/`, `templates/`, and `skills/` (counted via `grep -rE`
on 2026-05-28). The product calls these chapters *universal*. They are not.

### B1. The "universal" `chapters/persistence/12b-claudemd.md` ships a Next.js template

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Option (b) from the
finding — the chapter now teaches the shape with placeholders, then ships
**three short worked examples** (Web SaaS / Next.js + Supabase, Python web API
/ Django REST, Go CLI tool) so no single stack reads as the canonical
"default." The 6 universal sections (Stack / Layout / Conventions / Smoke
tests / Domain knowledge / Read-order) live at the top with `<placeholder>`
markers; the worked examples follow as labeled blocks. Tail note explicitly
calls out that the point isn't which stack — it's that *every* CLAUDE.md
needs these sections, pick the closest example as a starting point.

---

### B2. Every template carries a "swap for your stack" disclaimer, then ships Next/Supabase

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Option (a) — the
minimum-viable path. Main `templates/{CLAUDE,ARCHITECTURE,DEPLOY,SMOKE_TESTS,DECISIONS,PROJECT_BRIEF,FEATURES,PROJECT_PLAN}.md`
rewritten as stack-agnostic skeletons with `<placeholder>` markers and
multi-stack callouts in the headers. The previously-shipped worked
Next/Supabase versions moved to `templates/examples/web-saas-next-supabase/`
with a per-file "Worked example" preamble that points back at the main
template as the lesson and labels itself as a copy/paste starting point if
the user's project matches the shape. PROGRESS.md, SECTION_PLAN.md, and
SESSION_STARTER.md already had no stack-specific content — left as is.

`init.sh`-time stack detection (option (b) — sniff `package.json` /
`pyproject.toml` / `go.mod` / `Cargo.toml` / `Gemfile` / `pom.xml` and copy
the matching variant) is **not yet shipped** — the agnostic-default version
is the floor; per-stack templates/examples/ dirs can grow over time as the
audience requests them.

---

### B3. `op-prepare/procedure.md` Step 6.1 — file-shape heuristics are Next/Supabase-only

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Build-step → file-shape
table restructured as a **per-stack columns** layout. Eight stacks covered
inline: Next.js / Supabase, Django / DRF, FastAPI / SQLAlchemy, Rails, Go
(net/http or gin), Rust (axum / actix), Java / Spring, Generic CLI (Go /
Rust / Python). Build-step rows: Create schema / Per-row authorization /
Mutation endpoint / Read endpoint / Input validation / UI surface / Webhook
ingestion / Public flow / Send email. The procedure prose now says "pick
the right column based on the project's stack" + names the manifest files
to sniff (package.json / pyproject.toml / go.mod / Cargo.toml / Gemfile /
pom.xml) + tells out-of-table stacks (PHP/Laravel, .NET, Elixir/Phoenix,
Kotlin/Ktor, embedded, ML, data pipelines) to use the closest column as a
template. Step 5 (PROJECT_PLAN.md drafting) also got per-project-type
section-order templates (web SaaS / backend service / CLI-or-library /
ML-or-data pipeline) so the section list doesn't read as web-only.

---

### B4. `op-prepare/procedure.md` Step 6.2 — verify scaffolds assume Supabase + RLS

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Pattern catalog rewritten
concept-first. Renames: "RLS section" → "Per-row authorization" (examples
cover RLS / Firestore rules / IAM / decorator-based / app-layer); "API + UI"
→ "Mutation endpoint + UI". New patterns added: "CLI subcommand" (`<bin>
--help` / golden output / non-zero exit on bad input / README row), "Library
public method" (contract test / docstring example compiles / typed errors /
CHANGELOG entry). The existing Auth flow / CRUD resource / Public form /
Webhook ingestion / Migration-only patterns rewritten to substitute
generic terms (datastore vs `auth.users`; "signature / HMAC verification"
vs Stripe-specific phrasing) so the checks fire correctly regardless of
which provider lives behind each pattern.

---

### B5. `global/opinionated/CLAUDE.md.template` is the founder's CLAUDE.md, not "opinionated"

**[shipped 2026-05-28 — landed in `[Unreleased]`]** `git mv
global/opinionated/CLAUDE.md.template global/stacks/ts-next-supabase/CLAUDE.md.template`
(history preserved). One sibling variant added:
`global/stacks/python-django/CLAUDE.md.template` (~260 lines, same
section shape as ts-next-supabase but with Django / DRF / Postgres /
Celery specifics — type hints + mypy / pyright stack, DRF permission
classes, Alembic-or-Django-migrations strategy, Celery background tasks,
django-environ env handling, etc.). `install.sh` gained a `--stack=<name>`
flag with validation (errors with the list of available stacks if
`<name>` doesn't resolve to a real template directory) and a variant-swap
detection step that also matches against any other shipped stack template
(so a user who installed `--stack=ts-next-supabase` and now passes
`--stack=python-django` gets a clean overwrite instead of the
"preserved — appears user-customized" branch). `--opinionated` kept as
backward-compat alias for `--stack=ts-next-supabase`. README, INSTALL.md,
and bucket/README.md all updated; `landing/index.html` "opinionated repo"
mention left as is (it describes the maintainer's stance, not the folder
name). Follow-up: add `global/stacks/go-stdlib/`, `global/stacks/rust-axum/`,
`global/stacks/rails/` as the audience requests them.

---

### B6. `global/settings.json` defaults — WebFetch + Bash allowlists + plugin set are stack-locked

**[partly shipped 2026-05-28 — landed in `[Unreleased]`]** Three changes in one
pass on `global/settings.json`:

- **Bash allowlist broadened from 60 → 78 entries.** Added `cargo`, `rustc`,
  `go`, `mvn`, `gradle`, `./gradlew`, `bundle`, `gem`, `rake`, `composer`,
  `php`, `dotnet`, `mix`, `swift`, `deno`, `bun`, `make`. Supabase + Vercel +
  GitHub entries stay (they're harmless if unused, and the per-onboard inject
  path described in this finding is still future work).
- **WebFetch allowlist broadened from 12 → 32 domains.** Added MDN
  (`developer.mozilla.org`), `gitlab.com`, Python (`docs.python.org`, `pypi.org`,
  `docs.djangoproject.com`, `fastapi.tiangolo.com`), Go (`go.dev`, `pkg.go.dev`),
  Rust (`doc.rust-lang.org`, `crates.io`), Ruby (`rubyonrails.org`,
  `rubygems.org`), PHP (`laravel.com`, `packagist.org`), .NET
  (`learn.microsoft.com`), Kotlin / Swift / Android / iOS docs, and `npmjs.com`.
- **`enabledPlugins` defaults flipped.** `vercel@`, `playwright@`, and
  `frontend-design@` now ship `false`; `skill-creator@` and `github@` stay
  `true` (both are reasonable universal defaults). Per-stack opt-in via
  `/onboard` is still on the table for a later pass but is no longer the only
  way to avoid loading three stack-specific plugins.

The per-onboard-stack inject path proposed in the original finding (drop-in
`global/settings-extras/+python-stack.json` fragments selected by Q3) is **not
yet shipped** — the immediate fix is just to make the default neutral. Per-stack
extras remain in the queue.

---



- **WebFetch allowlist** (lines 68–80) pre-approves `supabase.com`,
  `vercel.com`, `nextjs.org`, `react.dev`, `tailwindcss.com`. Missing
  ecosystems: Django, Flask, FastAPI, Rails, Spring, Laravel, Phoenix,
  .NET, Rust crates, Go stdlib, Kotlin, Swift. The README warns at line 78
  *"Add your own framework's docs domain; remove any you'll never use"* —
  putting the burden on the user. A globally-targeted product ships an
  allowlist that's neutral or stack-detected.

- **Bash allowlist** (lines 13–62) pre-approves `supabase` and `vercel`
  subcommands. Missing: `cargo`, `go`, `bundler/gem`, `mvn`, `gradle`,
  `composer`, `dotnet`, `swift`, `mix`, `dub`. A Rust user inherits a
  config that prompts for permission on every `cargo build`.

- **enabledPlugins** (lines 147–153) enables **5 plugins by default,
  including the Vercel plugin**. That's a chunky context-cost commitment
  for a user who doesn't deploy to Vercel. Per `chapters/tools/15h-mcp.md`,
  loaded MCPs add per-session context budget. Defaulting to the Vercel
  plugin is the strongest signal a non-Vercel user gets that this isn't
  built for them.

Two fixes:

- **Minimal default allowlist + plugin set.** Strip to truly universal
  entries: `git`, `ls`, `cd`, `cat`, `mkdir`, `node/npm/python/pip` —
  remove stack-specific commands. Ship a `global/settings-extras/` folder
  with `+vercel-supabase.json`, `+python-stack.json`, `+go-stack.json`
  drop-in fragments the user merges per their stack.
- **`/onboard` Q3 (primary stack) writes the matching extras.** When
  Q3 = "Python", the post-essentials writeback adds the Python extras
  (with explicit approval, same pattern as the existing settings tune).

### B7. `questions-deep.md` B2 ("stacks to avoid") frames mainstream ecosystems as deprecated

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Option (a) from the
finding — drop the pre-loaded list. B2 is now a free-text-only question with
one explicit single-select option (`"No, no strong preference"`); anything the
user wants flagged goes through the `Other` free-text. No pre-loaded "avoid"
roster, no parenthetical descriptors. The body explains the rationale inline
so a future contributor doesn't re-load the list out of "well, we should
suggest something."

---



Lines 92–98:

```
Question: "Are there any tools or languages you'd rather I *not* suggest?"
Options (`multiSelect: true`):
- PHP / Laravel (older web language and framework)
- Java / Spring (enterprise web framework)
- Ruby on Rails (web framework popular in startups)
- C# / .NET (Microsoft's ecosystem)
```

These four stacks employ **the majority of the world's professional
software engineers**. Laravel has ~80k GitHub stars and powers a meaningful
share of the web. Spring underpins a lot of regulated-industry backends.
Rails ships Shopify, Basecamp, GitHub's monolith. .NET runs enterprise on
every continent. Listing them as the canonical "to avoid" stack is
parochial in a way that will turn off any reader who works in those
ecosystems on day one of `/onboard --deep`.

The parenthetical descriptors compound the problem: *"PHP / Laravel
(**older** web language)"*, *"Ruby on Rails (web framework **popular in
startups**)"* — these are loaded framings, not neutral descriptions.

Two fixes:

- **Drop the question entirely.** The "avoid" field is rarely consulted
  downstream; the genuine signal is in Q3 ("primary stack") and B1
  ("secondary"). If the user has a strong avoid, `Other` + free-text covers
  it.
- **If kept, neutralize**: list the *most-common* stacks the user might
  want to opt out of (whatever they are), strip the parentheticals, and
  let `Other` carry the rest. Don't pre-list four "to avoid" options.

Recommendation: drop. Reduces the deep interview from 13 to 12, removes a
likely-source of negative first-touch reactions.

### B8. `questions-essential.md` Q3 (primary stack) is unbalanced

**[shipped 2026-05-28 — landed in `[Unreleased]`]** AskUserQuestion is
hard-limited to 4 options, so option (a) ("expand to 6-7") isn't directly
available. Took a hybrid path: kept 4 options but restructured them as
*product-shape families* rather than single-language buckets. The new Q3:

1. **Web apps + sites** — covers JS/TS, Python, Ruby, PHP, Java, C#, Go,
   Elixir, anything else doing web work.
2. **Mobile + desktop apps** — Swift, Kotlin, Expo/RN, Flutter, Electron,
   Tauri, .NET MAUI.
3. **Backend services, CLIs, systems** — Go, Rust, Java, C/C++, .NET, Node,
   JVM stacks, Elixir.
4. **Data, scripts, ML** — Python, R, Julia, SQL, shell.

Each option lists 4-6 ecosystems explicitly in plain-English text so a Rust
systems dev, a Ruby web dev, and a Java enterprise dev all see their stack
named on day one. The `Other` free-text path also remains, and the question
text now says "capture the free-text in addition to the bucket" so downstream
skills can route generic advice by bucket but pull concrete examples from the
user's actual language/framework.

`B1` (secondary stack) got the same 4-bucket restructure for consistency.

Two-step picker (option (b)) and stack-detection-at-onboard (option (c)) are
still on the table for a v2 onboard pass.

---



Four options:

- Websites and web apps (JS/TS, React, Next.js)
- Python (scripts, data, Django, FastAPI)
- Go (backend services or CLI)
- Phone apps (iOS Swift, Android Kotlin, Expo, React Native)

What's missing that has comparable-or-larger ecosystems: Rust, Java/Kotlin
(JVM), Ruby, PHP, .NET, Elixir, C++, Scala, Clojure. Some of those are
covered by `Other` — but `Other` produces unstructured free-text that
downstream skills can't branch on. **Q3 is a routing signal**; degraded
routing → degraded help.

Three structural options:

- (a) **Expand to 6–7 options** covering the largest ecosystems (web /
  Python / JVM / Go / Rust / mobile / Ruby/PHP). Cost: longer dropdown.
- (b) **Two-step picker**: family ("web / mobile / data / systems /
  enterprise / cli"), then ecosystem under it. Cost: extra click.
- (c) **Stack-detection at `/onboard` time**: scan recent project
  directories under `~/`, pick the most-common stack as a *suggestion*,
  let the user confirm or change. Cost: more code; needs to handle
  no-projects-yet case.

(a) is the cheapest meaningful improvement.

### B9. `chapters/foundations/03c-project-fit.md` and adjacent — assume web-app shapes

Not yet audited but the chapter titles ("project-fit", "model tiers") imply
web-app framing. A data scientist using Claude Code for notebook work, an
embedded engineer using it for C++ firmware, a game-dev using it for Unity
C# — these users may find the discipline applies but the *examples* don't.
Audit during the B-block sweep.

### B10. macOS / Linux only — Windows users hit `install.sh:79-83` and bounce

```bash
MINGW*|MSYS*|CYGWIN*)
  echo "Windows detected. This installer needs symlinks. Run inside WSL,"
  echo "or copy skills/core/, global/, and templates/ into ~/.claude manually."
  exit 1
```

For a globally-targeted product, "use WSL or copy by hand" cuts off a
double-digit percentage of devs. Windows has had native symlink support
since Windows 10 1703 (2017) with `New-Item -ItemType SymbolicLink` for
admins, or developer mode for non-admins. A PowerShell variant of
`install.sh` (or a Python-based cross-platform installer) would close this
gap.

Lower priority than B1–B8 — but a Windows-friendly installer is the single
change that most expands the addressable user base.

### B11. English-only — no i18n hook in the onboarding surface

`questions-essential.md` and `questions-deep.md` are pure English with
casual idioms ("scare new users with a 25-question wall", "garbage in,
garbage out" in foundations/01a). For a global product, at least the
onboarding question text should be translatable. Two options:

- Ship as English-only but **flag the questions in profile** so a later
  pass can localize. Mark `questions-essential-${locale}.md` as the load
  path; default to `-en` if no localized file exists.
- Defer until adoption signals localization is worth it. Add a TODO and
  one-line architectural note.

Recommendation: defer, but write the localization-friendly pattern into
the profile-template so future-you isn't refactoring across all skills.

---

## N — Naïve / lazy logic (the user's concern, expanded)

The user's example: "Claude put a threshold on what to split". The same
pattern exists throughout the spine — **arbitrary magic numbers with no
override and no rationale**, plus brittle string-parsing where structured
parsing would be more reliable.

### N1. Eight separate hard-coded thresholds with no user override

Listed:

| File | Magic number | What it gates |
|---|---|---|
| `op-curate-nudge/SKILL.md:14` | **5** pending entries | Nudge fires |
| `op-curate-nudge/SKILL.md:16` | **>30** days | Nudge cooldown |
| `op-curate/stale-review.md:9` | **>90** days | Never-fired stale signal |
| `op-curate/stale-review.md:10` | **>6** months | Date-based stale fallback |
| `op-add-skill/SKILL.md:22` | **3+** uses | Skill-add gate |
| `op-prepare/procedure.md:37` | **7** | Product-shape questions cap |
| `op-prepare/procedure.md:53` | **5-7** | Clarifying questions cap |
| `op-prepare/procedure.md:77` | **5-12** | Section count target |
| `op-prepare/procedure.md:90, 130, 172` | **100** lines | Session entry split threshold |
| `spine-writeback.sh:195` | **30** turns | Long-session signal |
| `spine-writeback.sh:204` | **7200** sec (2h) | Long-session signal |
| `chapters/personalization/19c:84` | **~5**, **~10** | Schedule-curation prompts |
| `templates/PROGRESS.md:45` | **~30** entries | Session-log prune |

Many of these are reasonable *defaults*. The problem is they're invisible
hard rules, not visible knobs. **A user with shorter / longer sessions, a
busier capture queue, or a different bucket-curation cadence has no way
to adjust without editing the spine source.** Editing the spine source
defeats the `git pull` upgrade path (their edits revert).

Two structural fixes:

- (a) **Move all thresholds into the user's profile** under a new section
  `## Spine defaults` (visible, hand-editable, survives `git pull`). The
  skills/hooks read from `~/.claude/claude-spine-profile.md` for the
  threshold and fall back to the shipped default if unset.
- (b) **At minimum, document why each threshold was chosen** so a user
  who hits it knows whether to override. Right now `op-curate-nudge`
  says "5 pending and 30 days mirrors the implicit guidance in 19c" —
  19c says "past ~5, schedule" with no rationale. The rationale chain
  bottoms out at "Tim picked it".

Recommendation: (a). The configuration surface lives in the profile
already; this extends it for behavior, not just personality. Same change
unblocks user-level customization of the long-session signal — which is
the user's specific complaint about Claude's threshold habit.

### N2. `spine-writeback.sh` parses PROGRESS.md by grep — silent failure on format drift

**[partly shipped 2026-05-28 — landed in `[Unreleased]`]** Self-documenting
marker comment added at the top of `templates/PROGRESS.md` above the
Section/Session bullets:
*"⚠️ DO NOT REFORMAT THE NEXT 6 LINES (or the **Session** bullet below).
They are parsed by `spine-writeback.sh` via a regex that expects the literal
`- **Section**:` / `- **Session**:` shape with backticks around the name.
If you swap the bold for italics, drop the backticks, change the bullet
style, or move these bullets to a different sub-heading, the Stop-hook
heartbeat will silently no-op — your session activity won't be logged."*
Now a user editing PROGRESS.md sees the constraint inline.

The fuller fixes from the original finding (YAML frontmatter parsing OR
write a `.parse-error` marker file the next `/done` surfaces) are **not
yet shipped** — they're separable from the marker comment. The marker
removes the most-painful failure mode (a user accidentally breaks the
parser and never finds out); the parse-error surface is the next step.

The original finding text:

---

Lines 51–66:

```bash
SECTION=$(grep -E '^\s*-?\s*\*\*Section\*\*:' "$PROGRESS" 2>/dev/null \
  | head -n1 \
  | sed -E 's/^[^`]*`([^`]+)`.*/\1/' \
  | tr -d '\n' || true)
```

The hook expects PROGRESS.md to have lines shaped exactly like
`- **Section**: \`<section-name>\``. If the user removes the bold, drops
the backticks, swaps to italics, or uses a different bullet style, **the
hook silently no-ops** (`[ -z "$SECTION" ] && exit 0`). No log, no warning,
no surface to the user. They'll never know their heartbeats stopped firing
until they open the section file and see no `## Session log`.

Two problems:

- **Brittle to format drift.** Templates are markdown; users edit
  markdown. The template-strict-parsing-by-grep contract should be
  obvious to the user, but it isn't.
- **Silent failure** is exactly the wrong failure mode for a hook the
  user can't see fire.

Fixes:

- Add a **`# DO NOT EDIT THE NEXT 3 LINES — parsed by spine-writeback.sh`
  comment** in `templates/PROGRESS.md` directly above the Section /
  Session bullets. Self-documenting.
- Or: switch to **YAML frontmatter** at the top of PROGRESS.md (`section:`,
  `session:`) and parse that. YAML is unambiguous, well-supported, and
  doesn't conflict with the markdown body.
- And: when the hook fails to parse, **write a one-line warning to
  `$TMPDIR/spine-signals/<session>.parse-error`**, then on the next
  `/done` or `/spine`, surface it: "spine-writeback couldn't parse
  `docs/PROGRESS.md` since <time>. Check the Section/Session line shape."

YAML frontmatter is the cleanest. It also opens the door to programmatic
PROGRESS.md edits without text-replace fragility.

### N3. `op-curate-nudge/SKILL.md:15-16` — two parsing schemes silently coexist

> Count lines that match `- **Status:** pending` (case-insensitive). If
> no `Status:` markers exist (older format), count `##` second-level
> headings under the **Pending** section instead.

The "older format" fallback indicates the queue schema migrated at some
point. Two parsing schemes for the same data = a bug factory. If the new
format has *zero* `Status:` lines (e.g., the user hand-cleared the queue),
the fallback fires and counts `## ` headings — which under the new schema
include the heading rows that are NOT pending entries.

Fix: declare the new schema canonical, remove the fallback, **fail-loud
if the file shape is unrecognized** (one-line warning at session start
suggesting the user run `/curate` to migrate). One scheme, not two.

### N4. `op-suggest/SKILL.md:47` — assumes HTML-comment append marker exists

> Append above the marker, one blank line above the new `##` header.

If a user hand-edits `bucket/SUGGESTIONS.md` and deletes the
`<!-- op-suggest appends new entries above this comment. -->` marker —
which is invisible in rendered markdown and looks like cruft to a clean-up
editor — `op-suggest` either crashes or appends at end-of-file (depending
on how the skill body interprets the missing marker; the SKILL.md doesn't
specify the failure path).

Fixes:

- **State the failure path explicitly** in the SKILL.md: "If the marker
  is missing, append at end of the `## Pending` section, then re-insert
  the marker."
- Or: **drop the marker entirely** and append to a specific *section*
  ("Pending"). Sections are visible markdown; users won't accidentally
  delete them.

### N5. `op-onboard/SKILL.md` — edits `~/.claude/settings.json` by string-matching JSON

Lines 175–203 (Case A — settings.json edit for hook tuning):

> Use `Edit` to insert the new block. Match this exact slice of the
> current file: …
> If the `Edit` doesn't match (user reformatted settings.json, removed
> PreToolUse, etc.) → abort the write and fall to **Hand-edit fallback**.

`settings.json` is JSON. It should be **parsed as JSON**, mutated as an
object, and re-serialized. Today the skill works by text-replace on an
expected exact slice, which means the "Hand-edit fallback" path fires for
any user whose JSON has been reformatted (tab vs space, ordered keys,
trailing-comma differences).

Two options:

- **`jq`-based mutation**: read settings.json, parse, add the
  PostToolUse hook entry, write back. Preserves user formatting only if
  the user uses `jq`-default formatting. Doesn't preserve comments
  (settings.json is strictly JSON, no comments allowed — so this is
  fine).
- **Node-based mutation** with `JSON.parse` / `JSON.stringify` —
  requires Node, but Claude Code itself ships with Node so it's
  available.

`jq` is already required by the spine (see `install.sh:92`). Using it for
settings.json mutation is consistent.

This same anti-pattern likely lives in `op-curate`'s INDEX-row appends —
which append text to a markdown table by string-matching the empty-marker
row. Markdown tables are more text-than-data so the string-match is more
defensible there.

### N6. `op-spine-active` hardcodes the `docs/plans/` + `docs/PROGRESS.md` convention

**[partly shipped 2026-05-28 — landed in `[Unreleased]`]** Trigger description
and Step 1 of `skills/core/op-spine-active/SKILL.md` rewritten to accept four
common conventions in fallback order: `docs/plans/` + `docs/PROGRESS.md`
(canonical), `docs/specs/` + `docs/PROGRESS.md`, `plans/` + `PROGRESS.md`,
`specs/` + `PROGRESS.md`. Step 2's error messages reference whichever pair the
skill selected (`<progress-file>`, `<plans-dir>`) instead of hard-coding
`docs/PROGRESS.md`.

Project-level override: the skill now first looks at the project's `CLAUDE.md`
(or `.claude/CLAUDE.md`) for a line `Plan layout: <plans-dir> <progress-file>`.
Any project with an unusual convention can add that one line to opt the
ambient on without restructuring the repo. Notion / Linear / multi-app
monorepos with no local plan files still don't trigger — that's correct;
ambient cold-start only fires when local plan state exists.

The fuller "make all thresholds + paths configurable via the personal
profile" change from N1 + N6 is **not yet shipped** — this is the targeted
fix that takes ~four common project layouts out of "you have to rename your
folders to use the spine" territory.

---



`op-spine-active/SKILL.md:14` fires only when these two paths exist.
Teams using different conventions:

- `specs/`, `plans/`, `roadmap/` at repo root
- `docs/specs/` instead of `docs/plans/`
- `.spec/`, `.plans/` (dotted)
- Notion or Linear sync exports (no local filesystem)
- A monorepo with multiple `docs/` (one per app)

None of these trigger ambient. The user has to either rename their
convention to match the spine, or never get the ambient cold-start.
This is the same "Tim's habits = the product" anti-pattern as the
stack bias.

Fix: **make the trigger paths configurable** via the profile:

```
## Spine defaults
- Plan-driven trigger paths: docs/plans/, docs/PROGRESS.md
```

Same skill body; just don't hard-code the paths. Bonus: a user with
multiple conventions can comma-separate.

### N7. `README.md:188` — claims a specific $5-10 cost for the benchmark

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Both README references
(skill-trigger benchmark + token-efficiency benchmark) rewritten to drop
the specific `~$5–10 (Sonnet)` / `~$9–$15 (Sonnet)` framings and replace
with: "per-run token totals printed at the end (cost depends on the model
+ your region's Anthropic pricing — see https://www.anthropic.com/pricing)".
The `benchmarks/tokens/README.md` + LAUNCH.md + RECONSTRUCTION.md
references called out in the original finding are not yet swept — same
fix applies if those are touched in a future docs pass.

### N8. Fixed-list cue regex in `spine-writeback.sh:135`

The cross-session-note capture regex hard-codes English cue phrases:

```
(cross.?session note|follow.?up:|for (the |a )?(next|later|future) session|
 FYI for next session|note for next session|need to .{0,80}(in|before) .{0,30}(next|later|future) session|
 schema (will need|needs to)|carry.?over:)
```

Two issues:

- **English-only.** A localized session never captures.
- **Tied to Tim's phrasing.** "carry-over", "FYI for next session" are
  one operator's idiolect. A user who says "note this for tomorrow"
  or "remember this for next week" gets no capture.

Fix as part of N1's user-configurable thresholds: move the cue-phrase set
to a profile-settable list, so users can extend or replace per their
voice.

---

## C — Command surface — too many top-level commands

9 commands today. For a global product, the discoverable-command count
should be the smallest that covers the workflow. Three observations:

### C1. Bucket management is 4 commands when it could be 1 + subcommands

`/suggest`, `/curate`, `/add-skill`, `/refresh-bucket` are all "bucket
operations". A new user types `/` and sees 4 commands that look like
peers but actually decompose into one feature (the bucket) with four
operations.

Two options:

- **Subcommand consolidation**: `/bucket suggest`, `/bucket curate`,
  `/bucket add`, `/bucket refresh`. One top-level command, four
  operations. Cuts the slash-menu surface from 9 to 6.
- **Merge `/refresh-bucket` into `/curate`** (auto-run refresh as
  curate's preflight); drop `/refresh-bucket` as a standalone. Cuts to
  8. Half-step; the consolidation is the better story.

Recommendation: full subcommand consolidation. Matches the namespacing
of plugin commands (`/vercel:deploy`, `/vercel:env`, etc.) — a familiar
pattern.

### C2. `/spine` and `/hooks` are both discovery — merge

`/spine` already lists profile, skills, commands, chapters, bucket
status. `/hooks` lists hooks. The user looking for "what's running for
me?" runs both. Make `/spine` include the hook listing inline (or behind
a `/spine --hooks` flag), drop `/hooks` as a standalone.

Net: 9 commands → **6** (after C1 + C2). For a global product, 6 is the
right ceiling.

### C3. `/done` and `/prep` are the workflow primitives — keep, but name them better

Both names are fine in isolation. But `/done` reads ambiguously
("done with what?" — the file? the session? the whole project?). A
clearer name: `/wrap` or `/close-session`. Verb + noun beats bare verb.

Lower priority — renaming would invalidate the muscle memory of every
user who shipped with v0.x. Defer past v1.0.

---

## U — UX for a global / non-founder audience

### U1. The benchmark cost framing in `README.md` reads founder-friendly, not global-friendly

Already covered in N7. Reframing as token counts (not dollars) is the
cleanest fix.

### U2. The `effortLevel: high` + `autoCompactWindow: 180000` defaults assume Pro+

A Free user installs the spine and gets defaults sized for Pro. They'll
burn through their daily limit faster than necessary. No in-product
guidance toward "if you're on Free, drop effortLevel to medium". The
subscription-tune in `op-onboard` only fires *after* the user runs
`/onboard` and only proposes *raising* values for Max 20×, not *lowering*
for Free.

Fix: extend the Q1 mapping table in `op-onboard/SKILL.md:55-60` to
include Free → `effortLevel: medium` (or `low`) and a lower
`autoCompactWindow`. Symmetric with the Max 20× case.

### U3. The plan-driven workflow assumes a specific directory layout

Same as N6 but framed from UX: a user with a non-`docs/plans/`
convention can't enable the ambient at all. They either rename their
project layout (high friction, possibly breaks team conventions) or
never get the cold-start. Fix N6 closes this.

### U4. Onboarding has no preview of what's about to happen

The flow today: user runs `/onboard`, gets asked 7 questions one at a
time, then 13 more if they say yes to deep, then 2 hook prompts. There's
no "here are 22 questions across 4 sections; ~5 minutes; you can stop
anytime" overview at the start. Users who don't know what they're
signing up for hit `Cmd+C` after Q3.

Fix: add a single-screen preview before Q1: *"This will take ~2 minutes
across 7 questions. You can stop after, or continue into 13 more (~5
total minutes) for a fully-loaded profile. Press enter to start."*

### U5. No way to see what each profile field actually changes downstream

A user re-running `/onboard` to change one field doesn't know which
downstream behaviors that field affects. The handoff message
(`op-onboard/SKILL.md:236-278`) lists what was *captured*, not what
changes when each field changes. A "/profile explain <field>" command
or a per-field downstream-impact note in the handoff would close this.

Lower priority — but useful for the "I changed push-back from
'standard' to 'spar with me' and nothing seems different" frustration
pattern.

### U6. Discovery tree is 4 deep — INDEX → skill → chapter → section

A new user wanting to learn "how do I prompt well?" follows:
README → `/spine` → `op-prompting` SKILL.md → INDEX entry → chapter
file. Four hops. For the *atomic* discipline this is right (each layer
adds detail), but for *discovery* it's heavy.

Possible: ship a one-page **"start here" cheatsheet** that the user
opens once and bookmarks. Single file, ~50 lines, covers the 10 most
useful triggers ("when you're stuck → `op-recovery`", "when prompts
fail → `op-prompting`", etc.). Lives at the repo root as
`CHEATSHEET.md` and is linked from the README's first paragraph.

---

## P — Performance / context cost

### P1. Vercel plugin enabled by default — heavy context cost for non-Vercel users

**[shipped 2026-05-28 — landed in `[Unreleased]`]** Bundled with B6's
`global/settings.json` rework. `vercel@`, `playwright@`, and `frontend-design@`
all now default `false`; only `skill-creator@` and `github@` ship `true`. The
median-context-cost win predicted by this finding lands today; a future
benchmarks/tokens run can quantify the savings, but the four-line config
change itself is in.

The per-onboard re-enable (turn `vercel@` on automatically when Q3 = "Web apps
+ sites" AND the user mentions Vercel) is still future work.

---



`global/settings.json:152` enables `vercel@claude-plugins-official`. This
plugin loads ~20 skills + knowledge into every session start. A user who
doesn't deploy to Vercel pays this cost on every conversation.

Fix: **disable Vercel by default; enable via `/onboard` Q3** when the user
picks a web stack. Same for `frontend-design` (heavy, often unused) —
default off, opt in via the deep interview. Keep `skill-creator` and
`github` enabled (universal). `playwright` is borderline — useful for
verify flows but heavy.

The four-line config change to `global/settings.json` reduces median
context cost on a fresh install meaningfully. Quantify with one
benchmarks/tokens run before and after to verify.

### P2. `op-onboard/SKILL.md` 286 lines — already filed as M5 in Pass 3

Same finding, restated for completeness in the global-readiness context.
Splitting this skill is also a global-polish item: a refined product
doesn't ship a 286-line "router" skill when 80% of users only need 75
lines of it.

### P3. 18 skills repeat the same boilerplate — already filed as M6 in Pass 3

Same. The boilerplate adds context cost on every skill match.

### P4. Heavy opinionated CLAUDE.md at 258 lines vs. neutral at 25 lines — pick deliberately

The opinionated stub loads 258 lines into every session for users who
install it. If they're on Pro on a 200K-context window, that's a
meaningful percentage of always-on. Could be split:

- Section 1 (Always-on essentials) stays in CLAUDE.md (~30 lines).
- Sections 2–9 (How to work with me, Decisions, First touch, Workflow
  operating model, Proactive signaling, Code output, Verification,
  etc.) move to `~/.claude/skills/op-tim-flavor/SKILL.md` — loaded
  on-demand when behavior questions come up.

This is the "thin CLAUDE.md, fat skills" pattern that the spine itself
teaches in `chapters/persistence/12b-claudemd.md:60`. The opinionated
stub doesn't follow its own advice.

---

## Pass-4 suggested apply order

The B-block is the biggest unlock for global adoption. The N-block is the
fastest way to remove the user's "Claude makes up thresholds" complaint
across the spine itself. C / U / P are polish.

1. **PR 1 — stop sending Vercel into every session by default** (P1).
   One-line setting change. Highest-leverage polish in the entire pass.
2. **PR 2 — stack-agnostic templates + detection** (B2). Ship neutral
   templates as default; move worked Next/Supabase examples to
   `templates/examples/`. Optional: `init.sh` stack detection.
3. **PR 3 — `op-prepare/procedure.md` stack-rows** (B3 + B4). Add
   parallel rows / concept-first patterns for 2–3 stacks.
4. **PR 4 — rename opinionated → founder-ts-stack + add 1 sibling** (B5).
   Ship one stack-alternative variant to demonstrate the pattern.
5. **PR 5 — drop / neutralize Q3 + Q-B2** (B7 + B8). One-screen edit to
   `questions-essential.md` + `questions-deep.md`.
6. **PR 6 — user-overridable thresholds + cue phrases** (N1 + N8).
   Profile section + skill/hook reads. Biggest "stop hard-coding magic
   numbers" win.
7. **PR 7 — PROGRESS.md frontmatter + parse-error surface** (N2).
   Replaces grep-by-format with structured YAML + a visible failure
   mode.
8. **PR 8 — jq-based settings.json mutation in op-onboard** (N5).
   Removes one fragile string-replace anti-pattern.
9. **PR 9 — command consolidation** (C1 + C2). 9 → 6 commands.
10. **PR 10 — Windows-native installer** (B10). Stretch goal; opens a
    double-digit-percent addressable user base.

**Estimated totals:**
- PR 1 (Vercel default off): 10 min.
- PR 2 (template neutralization): ~2 hours.
- PR 3 (procedure stack-rows): ~2 hours.
- PR 4 (opinionated rename + 1 variant): ~3 hours.
- PR 5 (Q3 / Q-B2 cleanup): ~30 min.
- PR 6 (configurable thresholds): ~3 hours.
- PR 7 (PROGRESS.md frontmatter): ~1 hour.
- PR 8 (jq settings.json): ~1 hour.
- PR 9 (command consolidation): ~3 hours.
- PR 10 (Windows installer): ~half-day to a day.

Total: ~2 working days for PRs 1–9. Windows is a separate effort.

**The single change with the highest impact-per-minute is PR 1 —
default-off Vercel plugin.** Ten-minute config edit; closes the strongest
"this product wasn't built for me" signal that a non-Vercel user gets
on first launch.

---

## Shipped vs remaining (status as of the third 2026-05-28 sweep)

**Shipped in `[Unreleased]`:**

| PR # | Items | Status |
|------|-------|--------|
| PR 1 | P1 (Vercel + Playwright + frontend-design default-off) + B6 partial (Bash + WebFetch broadened) | ✅ shipped (round 1) |
| PR 2 | B2 (template neutralization — option (a): main templates stripped, worked examples moved to `templates/examples/web-saas-next-supabase/`) + B1 (12b multi-stack worked examples) | ✅ shipped (round 2) |
| PR 3 | B3 (Step 6.1 per-stack file-shape table, 8 stacks) + B4 (Step 6.2 concept-first patterns + CLI/library new patterns) + Step 5 per-project-type section templates | ✅ shipped (round 2) |
| PR 4 | B5 (opinionated → stacks/ts-next-supabase rename + python-django sibling + `--stack=<name>` flag + backward-compat `--opinionated` alias) | ✅ shipped (round 2) |
| PR 5 | B7 (B2 "stacks to avoid" → free-text) + B8 (Q3 → product-shape families) | ✅ shipped (round 1) |
| PR 6 | N1 + N8 (profile-settable thresholds + cue phrases): `## Spine defaults` section added to profile template covering bucket-loop thresholds, planning caps, writeback turn / elapsed thresholds, and user-extendable cue phrases. `spine-writeback.sh` now reads `Long-session turn threshold` + `Long-session elapsed seconds` + appends profile-supplied cue phrases. `op-curate-nudge`, `op-curate/stale-review`, `op-add-skill` all reference the profile fields. | ✅ shipped (round 3) |
| —    | N3 (op-curate-nudge: dual schema fallback dropped, fail-loud warning when `Status:` markers are absent) | ✅ shipped (round 3) |
| —    | N4 (op-suggest: missing-marker failure path specified — append to end of `## Pending` + restore marker, fail-warn if no `Pending` section at all) | ✅ shipped (round 3) |
| —    | U2 (Q1 mapping table extended for Free tier — `effortLevel: medium`, `autoCompactWindow: 120000`) | ✅ shipped (round 3) |
| —    | L9 (op-onboard "Right after Q6" wording → "After all N essentials are captured (last one is …)") | ✅ shipped (round 3) |
| —    | New-onboard-questions pass: 3 new essentials (Q7 OS, Q8 VCS host, Q9 Artifact shape) + 5 new deep (G1 Session shape, G2 Plans dir, H1 Bucket-loop opt-in, H2 Org shape, H3 Currency); profile template grew an `## Environment` section and added `Artifact` / `Org shape` / `Session shape` fields. Count claims swept across README, EXPLAINER, install.sh, op-welcome, op-onboard, 19b, INSTALL, /onboard command description. Essentials count 7 → 10; deep 13 → 18; total 20 → 28. | ✅ shipped (round 3) |
| —    | Bucket-loop optional reframe (BIAS-AUDIT P2 #11): `Bucket loop: on \| off` toggle added to profile `## Spine defaults` (default `on`); README personalization section reframed as "profile always-on, bucket loop opt-in"; `op-suggest`, `op-curate-nudge`, `op-bucket-router` all silent-skip on `off` (explicit user invocation still honored as a one-shot override). | ✅ shipped (round 3) |
| —    | Anti-pattern softening pass (BIAS-AUDIT P3 #13): 18g "One big PR" reframed with explicit long-lived feature-branch exception + the "I'll write the markdown files later" entry now acknowledges Linear/Notion as valid substitutes; 18b "Trying to do the whole app in one session" generalized to "one cohesive goal" with substitutes for debug/explore/refactor/explain shapes. | ✅ shipped (round 3) |
| —    | U6 (CHEATSHEET.md): one-page entry-point cheatsheet at repo root linked from README first paragraph. | ✅ shipped (round 3) |
| —    | BIAS-AUDIT P1 #7 (hook expansion: format-on-save 4 → 14 detection paths; typecheck 2 → 7 with mypy/pyright/ruff fallback) | ✅ shipped (round 2) |
| —    | Chapter prose strip (BIAS-AUDIT P0 #3): 12b + 05b + 05c + 06 + 15h all generalized | ✅ shipped (round 2) |
| —    | N6 partial (op-spine-active accepts four plan-layout conventions + `Plan layout:` override) | ✅ shipped (round 1) |
| —    | N2 partial (PROGRESS.md self-documenting marker comment above the parsed bullets) | ✅ shipped (round 2) |
| —    | N7 (README cost framings → token counts + Anthropic pricing link) | ✅ shipped (round 2) |

**Remaining:**

| PR # | Items | Notes |
|------|-------|-------|
| PR 7 (rest) | N2 (YAML frontmatter parser + `.parse-error` marker file) | Marker comment landed; structured parsing + visible failure mode separate. ~1h. |
| PR 8 | N5 (jq-based settings.json mutation in op-onboard) | Tied to P2 (op-onboard split — currently 286 lines); do them together. ~1h on top of P2. |
| PR 9 | C-block (command consolidation 9 → 6) | Significant UX change; needs broader sign-off. ~3h. |
| PR 10 | B10 (Windows-native installer) | Stretch goal. ~half-day to a day. |
| — | B9 (un-audited chapter pass for project-type assumptions) | Anti-pattern partial pass shipped (18b + 18g); foundations + persistence still un-audited. ~30min remaining. |
| — | B11 (i18n hook in onboarding) | Deferred per finding; not urgent until adoption signals localization. |
| — | U-block remainder (onboard preview, `/profile explain <field>`) | Polish; ~1h combined. Cheatsheet + Free-tier landed in round 3. |
| — | P2/P3/P4 (op-onboard split + skill boilerplate trim + per-stack CLAUDE.md split) | M5/M6 from Pass 3, restated for global-readiness. ~4h combined. |
| — | Per-stack settings extras (B6 follow-up): drop-in `global/settings-extras/+python-stack.json` fragments + onboard inject path | Floor (broadened defaults) landed in round 1; per-stack inject still future. ~2h. |
| — | VCS-host-aware install (BIAS-AUDIT P3 #14) | Now enabled by new Q8 (VCS host); next pass wires the inject of `gh` / `glab` / `bb` allowlist + per-host WebFetch domains. ~1-2h. |

**Round-3 totals:** ~5-6 hours wall time across N1+N8 (profile-settable
thresholds), the 8-question onboard expansion + count sweep, N3/N4 parser
cleanups, Free-tier Q1 mapping, anti-pattern softening, the CHEATSHEET,
bucket-loop optional reframe, L9 wording fix, plus this FIXES.md update.
