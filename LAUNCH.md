# Launch Plan — Path from "v2 complete" to "global product"

**If you're a Claude session reading this cold, this file is your first read.** It's the gap-fixing plan between the end of `RECONSTRUCTION.md` (v2 architecture shipped 2026-05-27) and a public launch. Each phase is sized for one focused session.

Companion docs:
- `RECONSTRUCTION.md` — v2 build history, frozen architectural decisions, pre-launch cleanup pass (items 1–8 done, item 9 still open).
- `PERSONALIZATION.md` — personalization loop design (Phase 8, shipped).
- `README.md` — public-facing entry point (already rewritten in Phase 6c).

---

## Why this file exists

The 2026-05-27 ship-readiness audit caught issues that don't belong in `RECONSTRUCTION.md` (that file is the build history, now frozen). These issues fall into three buckets:

1. **Self-consistency bugs** in the spine itself — chapters reference content that doesn't exist for default installers; new skills cross-reference the old skill names they're replacing; a few "Claude Code Operator's Manual" naming holdovers.
2. **Installer cutover bug** — `install.sh` adds new `op-*` symlinks but doesn't remove the legacy `op-manual-*` skills. Both load simultaneously. The new skills have never been observed in isolation.
3. **Pre-launch validation never done** — no clean-room install, no skill-trigger benchmarks, no hook test fixture, no demo, no telemetry, no community story.

Plus: Tim wants to migrate his personal setup off the standalone `~/.claude/CLAUDE.md` onto the spine. That's a separate low-risk path that can happen any time after L1 + L2 land.

---

## Verdict carried forward from the audit

- **Tim's personal upgrade** — ready today, after L1 + L2. The opinionated template captures ~95% of his current global verbatim (paths swept, identity placeholders); the missing 5% is Solvero/Dutch/Windows context restored manually.
- **Global launch (strangers installing)** — not ready. Blocking items are L0 (community story), L1 (self-consistency), L2 (installer cutover), L4–L5 (testing + clean-room install). L3, L6 are quality-of-life; L7 is the actual launch.

---

## Phase board

| Phase | Scope | Blocks | Status |
|---|---|---|---|
| L0 | Decide community/sharing story (no code, README + bucket/README touched) | L7 (waitlist messaging) | not started |
| L1 | Self-consistency sweep (circular refs, stale skill cross-refs, naming) | L8 (Tim migration), L7 (launch) | done (2026-05-27) |
| L2 | install.sh legacy `op-manual-*` cutover + `/uninstall` | L8 (Tim migration), L7 (launch) | done (2026-05-27) |
| L3 | settings.json default tuning (effortLevel, autoCompactWindow) | nothing | not started |
| L4 | Testing harness — skill-trigger benchmarks + hook test fixture | L7 confidence | not started |
| L5 | Clean-room install on fresh VM / Docker | L7 (launch gate) | not started |
| L6 | CHANGELOG.md + archive v1 root files + repo URL verify | L7 polish | not started |
| L7 | Launch assets — domain, landing page, demo, waitlist signup | nothing — launches | not started |
| L8 | Tim's personal migration | — | unblocked after L1+L2 |

Dependency graph: `L0 → L7`. `L1 → L8 → ...`. `L2 → L8 → ...`. `L4 + L5 → L7 confidence (not strict blocker)`. `L3, L6 can land anytime`.

---

## L0 — Community / sharing story (decision-only)

**Problem.** README says: *"if you want to share your skills, that's your problem to solve."* Tim wants a waitlist + community next. Those collide on day one of the community existing.

**One session.** No code. Outputs: decision recorded; README + `bucket/README.md` text updated to match.

**Three viable stances (pick one):**

1. **No sharing, here's why** — keep the line, expand it. The case: bucket contents are personal preferences, often security-sensitive (stack-specific paths, credentials structure), and the speculative-library trap (chapter 13d) is real. Direct people to fork and write their own.
2. **Minimal share-via-fork** — community is GitHub Discussions or a tag (`#claude-spine-skills`); users PR their favorite bucket skill into a `examples/` folder if they want, no formal review. Low-effort, signals the door is open without committing infrastructure.
3. **Curated examples folder** — `bucket-examples/` in this repo, maintained list of well-shaped public skills. Highest cost; commits to ongoing curation; conflicts with "single-maintainer, opinionated repo" framing in CONTRIBUTING.md.

**Recommendation:** start with #1 (no sharing) loudly defended, until real user volume creates pressure to revisit. The honest framing is "this is your toolbox, not your subreddit" — fits the existing voice. Revisit at v2 of the launch.

**Definition of done:** decision recorded inline in this file; README's "What's NOT in this repo" section + `bucket/README.md` reflect the stance with one paragraph of rationale.

---

## L1 — Self-consistency sweep

**Problem.** The spine has three classes of internal inconsistency that a cold-read user will hit immediately:

1. **Circular references.** Chapter `18f-security.md` says *"The forbidden list in your global CLAUDE.md is the authoritative checklist"* and `04c-budget-and-cost.md` says *"See the security section of your global CLAUDE.md."* A neutral-stub installer has no such list — the spine chapter points at content that doesn't exist for them.
2. **Stale skill cross-references.** Several new skills reference the old skill names they're replacing:
   - `skills/core/op-anti-patterns/SKILL.md:3` — *"Routes to chapter 18 of the **Claude Code Operator's Manual**"* (old project name).
   - `skills/core/op-subagents/SKILL.md:39` — *"→ `op-manual-recovery` (chapter 17)"*.
   - `skills/core/op-persistence/SKILL.md:29, 43` — *"→ `op-manual-templates`"*.
   - `skills/core/op-signaling/SKILL.md:43` — *"→ `op-manual-recovery` (chapter 17)"*.
3. **"Claude Code Operator's Manual" naming holdovers** across at least: `EXPLAINER.md`, `13-custom-skills.md` (deprecated v1 stub but text still references the manual), several skill files.

**One session.** No architectural decisions; pure factual edits.

**Tasks:**
1. Move the full security forbidden list from the opinionated template into `chapters/anti-patterns/18f-security.md` as the authoritative content. Update `04c` to reference `18f`, not "your global CLAUDE.md". The opinionated template can keep its copy (it's the user's runtime checklist), but the spine chapter is now self-contained.
2. Sweep `op-manual-*` → new skill names in the four files above (`op-recovery`, `op-anti-patterns`, `op-templates` if that's the right route — but templates have no `op-templates` skill; reconfirm the route).
3. Global grep for `Claude Code Operator's Manual` and replace with `claude-spine` (or contextual rephrasing). Skip RECONSTRUCTION.md's historical sections — those should preserve original phrasing as build history.

**Definition of done:** `grep -r "op-manual-" skills/` returns nothing in new skills (RECONSTRUCTION.md and historical notes excepted). `grep -r "Claude Code Operator's Manual"` returns only historical notes. Chapters 18f and 04c are self-contained for a neutral-stub user.

**Open question for this phase:** templates skill. The opinionated CLAUDE.md still mentions `~/.claude-spine/templates/`, which is correct, but there's no `op-templates` skill listed in INDEX.md. The legacy `op-manual-templates` is what currently routes to the templates folder. Confirm during the session whether one of the new core skills handles this (likely `op-persistence` covers project docs) or whether a separate `op-templates` skill is missing from the 18.

### L1 notes (2026-05-27)

**Resolved open question:** no new `op-templates` skill needed. `op-persistence`'s description already lists "project doc" as a covered persistence layer, and templates are static reference artifacts (no chapter content to route to). Fix was to replace the dangling `op-manual-templates` references in `op-persistence/SKILL.md` with direct pointers to `~/.claude-spine/templates/` and to enumerate the available templates inline. The 18-skill count is preserved.

**Scope of edits actually done:**
- `chapters/anti-patterns/18f-security.md` — rewritten to be self-contained. Added 6 missing forbidden-list items (hardcoded secrets, SQL injection, eval/Function on user input, JWTs in localStorage, RLS disabled on user-data tables, CORS `*` on user-data routes) in the existing "fails because / instead" format. Switched TL;DR self-reference (was: "the forbidden list in your global CLAUDE.md is the authoritative checklist"; now: "this catalog is the authoritative checklist").
- `chapters/foundations/04c-budget-and-cost.md` — line 68 now points to chapter 18f instead of "the security section of your global CLAUDE.md".
- Skill cross-references swept: `op-manual-recovery` → `op-recovery` in `op-subagents/SKILL.md` and `op-signaling/SKILL.md`; `op-manual-templates` → direct template-folder pointer in `op-persistence/SKILL.md` (two occurrences).
- Naming holdover swept: `Claude Code Operator's Manual` → `claude-spine` across all 14 affected skill descriptions. Pattern was uniform: "Routes to chapter X of the Claude Code Operator's Manual." → "Routes to chapter X (name) of claude-spine." Added the chapter name in parentheses where it was missing (op-anti-patterns, op-hooks, op-prompting, op-tools, op-visuals) so cold-read users see what the chapter is about without opening it.
- `EXPLAINER.md` and v1 root `13-custom-skills.md` were called out in the launch doc but contained no actual holdovers — already clean.

**DoD verification:** `grep -r "op-manual-" skills/` returns nothing. `grep -r "Claude Code Operator's Manual" .` returns only `LAUNCH.md` (this file) and `RECONSTRUCTION.md` (historical), as expected.

**Out of scope, not done in this phase:** the opinionated CLAUDE.md template still carries its own forbidden list — left in place per the launch doc's guidance ("the user's runtime checklist"). 18f is now the authoritative spine version; the opinionated copy is a deliberate, redundant runtime shortcut for users who want it inline.

---

## L2 — install.sh legacy cutover + /uninstall

**Problem.** `install.sh` adds the new `~/.claude/skills/op-*` symlinks but never touches `~/.claude/skills/op-manual-*`. After install, both live side-by-side. Trigger descriptions overlap. Tim's current session is loading both sets right now.

Also: there's no scripted uninstall. `global/INSTALL.md` documents the manual steps, but for users who want to bail cleanly it's all `rm` and `cp` from the backup folder.

**One session.** Touches `install.sh`, adds `uninstall.sh`, updates `global/INSTALL.md`.

**Tasks:**
1. Add a legacy-cleanup step to `install.sh`, **before** the symlink loop:
   - Detect `~/.claude/skills/op-manual-*` directories.
   - Back them up to `~/.claude-backup-<ts>/skills/` (using existing backup helper).
   - `rm -rf` the originals.
   - New flag `--keep-legacy` opts out (for users who want to A/B for a session).
   - Print the action clearly in the run summary.
2. Write `uninstall.sh`:
   - Remove `~/.claude/skills/op-*` symlinks (only the ones the spine installed — match the spine's `skills/core/op-*` set).
   - Remove `~/.claude/commands/*.md` symlinks the spine installed.
   - Remove `~/.claude/hooks/block-env-staging.sh`.
   - **Don't** touch `~/.claude/CLAUDE.md` (user may have edited it) — just print "your CLAUDE.md is unchanged; restore from `~/.claude-backup-...` if you want the original."
   - **Don't** touch `~/.claude/claude-spine-profile.md` — it's user data.
   - **Don't** touch `~/.claude-spine/bucket/` — it's user data.
   - Remove the `~/.claude-spine` symlink (if it's a symlink — leave real directories alone).
3. Update `global/INSTALL.md` to document both behaviors + the `--keep-legacy` flag.

**Definition of done:** A fresh run of `./install.sh --dry-run` shows the legacy cleanup step. A fresh run of `./uninstall.sh --dry-run` shows the exact files it'd remove and the user data it leaves alone. Both scripts have `--help`.

### L2 notes (2026-05-27)

**Scope of edits actually done:**
- `install.sh` — added `--keep-legacy` flag, added section `1b` (legacy `op-manual-*` cleanup) between the `~/.claude-spine` symlink and the core-skill symlink loop. Uses the existing `backup_path` helper. Conditional on `SKIP_SKILLS=0` (so `--skip-skills` users aren't surprised by skills disappearing). Updated `--help` sed range from `2,17p` to `2,18p` to cover the new flag line.
- `uninstall.sh` (new) — mirrors `install.sh`'s structure: resolves spine root the same way, parses `--dry-run` / `--help`, uses a `points_into_spine` helper that compares `readlink` output against `$SPINE_DIR/<subpath>/*`. install.sh writes absolute paths in its symlinks, so a literal prefix match is enough and avoids relying on `readlink -f` (BSD readlink on macOS doesn't support `-f`). Removes only spine-owned symlinks; leaves `CLAUDE.md`, `settings.json`, `claude-spine-profile.md`, and the spine's `bucket/` in place per spec. `~/.claude-spine` removed only when it's actually a symlink — a real directory at that path is left alone.
- `global/INSTALL.md` — added `--keep-legacy` row to the Flags table, added one short paragraph above the table explaining the legacy cutover behavior. Replaced the manual `rm` block in the Uninstall section with a pointer to `./uninstall.sh` + explicit list of what it leaves in place.

**DoD verification:**
- `./install.sh --dry-run` on Tim's machine (which still has all four legacy directories) shows the cleanup step firing — each `op-manual-*` backed up to `~/.claude-backup-<ts>/.claude/skills/` then `rm -rf`'d, followed by the standard `op-*` symlink creation.
- `./install.sh --keep-legacy --dry-run` correctly skips the cleanup and prints the "leaving any op-manual-* skills in place" notice.
- `./uninstall.sh --dry-run` reports `(none found)` for skill/command symlinks (none installed yet on Tim's machine), correctly flags the existing env-leak hook for removal, and lists `CLAUDE.md` / `settings.json` / `bucket/` under "intentionally LEFT IN PLACE".
- Both scripts respond to `-h` / `--help`.

**Out of scope, not done in this phase:** L8 (Tim's actual personal migration) is now unblocked but deliberately not executed here — `RECONSTRUCTION.md` and the cold-read rules say one session = one phase. The opinionated CLAUDE.md template's "currently /onboard" line in `global/INSTALL.md`'s table is now stale (5 commands exist) — left untouched because it's outside L2's scope; rolling it into L6 (CHANGELOG + polish) is the cleaner placement.

---

## L3 — settings.json default tuning

**Problem.** `global/settings.json` ships with `effortLevel: "xhigh"` and `autoCompactWindow: 800000`. Both are aggressive defaults — xhigh burns budget for Pro-plan users; 800K context assumes 1M-context model availability.

**One session.** Touches `global/settings.json` and `global/INSTALL.md`.

**Tasks:**
1. Decide defaults. Recommend: remove both keys entirely (let Claude pick) OR set `effortLevel: "high"` and `autoCompactWindow: 180000`. The minimalist path is safer for first-time installers.
2. Add a section to `global/INSTALL.md` titled "Tuning for Max 20x / 1M context" that documents how to opt up.
3. While here: review the `permissions.allow` list. Some entries are Tim-specific (Supabase, Vercel, Lighthouse). Consider splitting into a `permissions.allow.base` set everyone gets and a `permissions.allow.stack-specific` block users uncomment. Defer if it's a lot — note in this phase and roll into L6.

**Definition of done:** A Pro-plan user installing fresh doesn't unknowingly opt into expensive defaults.

---

## L4 — Testing harness

**Problem.** Zero automated tests. 18 skill trigger descriptions whose accuracy determines whether the system fires correctly. The `skill-creator` plugin (already enabled) has eval capability.

**One or two sessions.** This is foundational work; may want to split into L4a (skill-trigger benchmarks) and L4b (hook fixture + CI).

**Tasks (L4a — skill triggers):**
1. Use `skill-creator` to scaffold a benchmark file per skill.
2. Hand-write 10–20 trigger phrases per skill: 5–10 should-fire, 5–10 no-fire.
3. Run the benchmarks. Capture true-positive / false-positive rates per skill.
4. Skills with FP rate >20% or TP rate <80% need description tightening. Don't tighten in this phase — log them; tightening is a separate scope.

**Tasks (L4b — hook + CI):**
1. Write a test fixture for `block-env-staging.sh`: feed it the JSON hook protocol for `git add .env`, `git add foo/.env.local`, `git add .` (negative case), `git add file.txt` (negative case). Assert deny on the first two, allow on the last two.
2. Write a `test/install-dry-run.sh` that runs `./install.sh --dry-run` and grep-asserts the expected actions appear.
3. Wire all of the above into a `.github/workflows/test.yml` that runs on push / PR.

**Definition of done:** `make test` (or equivalent) passes. README has a "Running the tests" section.

---

## L5 — Clean-room install on fresh VM / Docker

**Problem.** Pre-launch cleanup item 9: never done. `--dry-run` on Tim's machine is not the same as a real install on a host with no prior state.

**One session, requires a fresh environment.** Spin up a Docker container (Ubuntu LTS + bash + git + jq) or a fresh macOS VM.

**Tasks:**
1. Inside the container: `git clone https://github.com/TimTGelhard/claude-spine ~/.claude-spine && cd ~/.claude-spine && ./install.sh`.
2. Capture every prompt, error, fallback. (Does the symlink work? Does the global CLAUDE.md render correctly? Does sed substitute `{{SPINE_DIR}}` cleanly?)
3. Restart Claude Code (or simulate — at minimum verify the symlinks resolve and the global is readable).
4. Run the two README verification queries: *"What's in my global CLAUDE.md? Summarize the section headings."* / *"List the op-* skills loaded."*
5. Run `/onboard` — walk the essentials interview. Verify `~/.claude/claude-spine-profile.md` is created.
6. Run `/curate` with an empty bucket — verify the empty-state messaging is sensible.
7. Capture every divergence between README and reality. Each divergence is an issue to fix in a follow-up session (or roll into L6).

**Definition of done:** A documented run report exists (commit it as `docs/clean-room-install-report.md`). Any divergence is either fixed in-session (small) or filed (large).

---

## L6 — CHANGELOG + archive v1 root + repo URL verify

**Problem.** Three loose ends:

1. No `CHANGELOG.md` at repo root. `git pull` is the update mechanism but users have no narrative of what changed.
2. The 18 deprecated v1 chapters at root (`01-first-principles.md` … `18-anti-patterns.md`) are noise for new clones. Pre-launch cleanup chose deprecation headers over `git mv archive/` to preserve external links. Re-evaluate: external link preservation is real, but a `docs/v1-archive/` move with a top-level redirector note might be cleaner. Lowest-cost compromise: keep the files at root, but add a single root-level `V1-CHAPTERS-DEPRECATED.md` that lists all 18 + their v2 atomic locations, and trim the per-file deprecation header to one line.
3. The README clone URL is `https://github.com/TimTGelhard/claude-spine`. Verify the repo actually exists at that URL before public launch.

**One session.**

**Tasks:**
1. Write `CHANGELOG.md`. Backfill from RECONSTRUCTION.md's phase history: condense each phase into 1–2 lines under a `## v0.x` heading. Pick a version scheme (recommend `v0.9` for current pre-launch state, `v1.0` for the launch tag).
2. Decide v1 root: keep with trimmed headers + add `V1-CHAPTERS-DEPRECATED.md` index, OR `git mv` to `docs/v1-archive/` with redirector notes. Document the call.
3. Verify the GitHub repo URL — if missing, file a separate task to create the repo (or pick a real URL).

**Definition of done:** Root has a `CHANGELOG.md`. v1 root clutter resolved one way or the other. README URL is real.

---

## L7 — Launch assets

**Problem.** Phase 7 in `RECONSTRUCTION.md` was "Demo + launch — end-to-end dry-run, video script outline, launch checklist" — sketchy by design. Now it's the real launch.

**Multi-session.** Sub-phases:

- **L7a — Domain.** Register `claudespine.dev` (or `.com`, or both). Configure DNS to point at a landing page host.
- **L7b — Landing page.** One-page site: tagline, three "what you get" bullets, install one-liner, link to GitHub. Plain HTML + Tailwind CDN (per Tim's landing-page stack default). Host on Vercel.
- **L7c — Waitlist.** Email capture on the landing page. Pick a provider (Beehiiv / ConvertKit / Loops — Tim's call). Capture: email + "what stack do you ship in" (informs which atomic chapters get loved).
- **L7d — Demo video.** 90-second screen recording: install → restart → run `/onboard` → ask a question that fires an `op-*` skill → show the skill loading the right atomic file → end. Loom or simple OBS recording. Embed on the landing page.
- **L7e — Public launch.** Twitter/X thread, Hacker News, r/ClaudeAI. Coordinate with L7a–L7d going live the same day.

**Definition of done:** Landing page live, waitlist accepting signups, demo embedded, public posts up.

---

## L8 — Tim's personal migration

**Unblocked after L1 + L2.** Can happen any time. ~30 minutes.

**Tasks (run in this order):**

1. Backup current state (belt-and-braces — install.sh does this too):
   - `cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.pre-spine`
   - `cp -r ~/.claude/skills ~/.claude/skills.pre-spine`
2. Read `./install.sh --opinionated --dry-run` output. Verify the legacy cleanup step (L2 work) is correctly removing the four `op-manual-*` directories.
3. Run for real: `./install.sh --opinionated`.
4. Open `~/.claude/CLAUDE.md` — fill in the `{{placeholders}}` (your name, the one-or-two-line intro, stack defaults if they differ from the example).
5. Re-add the three personal bits the opinionated template doesn't carry:
   - "Solo founder. This machine builds client websites (Solvero Digital, Dutch tradespeople) and MVP apps."
   - "Scraping / lead-gen lives on a separate Windows machine — skip that context."
   - Dutch locale specifics in the Client websites stack default: `lang="nl"`, Dutch date/phone/postcode formats, JSON-LD `LocalBusiness`.
6. Restart Claude Code.
7. Run `/onboard` (essentials) — confirm `~/.claude/claude-spine-profile.md` is created. Optionally run `/onboard --deep`.
8. Verify in a fresh session:
   - *"What's in my global CLAUDE.md?"* — should match the opinionated template with your personal bits.
   - *"List the op-* skills loaded."* — should be 18, no `op-manual-*` survivors.
   - Trigger one or two on purpose (e.g., ask about subagents → should fire `op-subagents`; ask about anti-patterns → should fire `op-anti-patterns`).

**Definition of done:** Tim is on the spine; his old global is backed up to `~/.claude-backup-<ts>/`; the legacy `op-manual-*` skills are gone from `~/.claude/skills/`; he can dismiss this CLAUDE.md as obsolete.

---

## Operating rules for execution sessions

When you're picking up a phase:

1. **Read this file first.** It's the cold-read entry point for launch work.
2. **Then read `RECONSTRUCTION.md`'s frozen architecture section** (around line 75–105) — those decisions still bind.
3. **Stay in your phase's scope.** No cross-phase work. If you spot something off-scope, note it in this file's "Open issues caught mid-phase" section (add it if missing).
4. **Update this file at end of session:**
   - Flip the phase status (not started → in progress → done).
   - Add anything you learned to the phase's notes section (`### L1 notes (YYYY-MM-DD)`).
   - Add any new issues to "Open issues caught mid-phase."
5. **L0 must be a real decision, not a vague one.** Tim picks the stance; the session updates README + bucket/README to match. Don't write a "we'll figure out community later" hedge.
6. **L4 + L5 are the only phases that need new tooling.** Everything else is editing files already in the repo.

---

## Open issues caught mid-phase

(Empty — to be appended as phases land.)

---

## Critical context for cold-read sessions

- Today's date (when this file was written): 2026-05-27. Use absolute dates for any new notes.
- The 18 op-* skills are listed in `INDEX.md` and `skills/core/op-*/`. Don't add new ones in launch work — that's a post-launch decision.
- The bucket loop (`op-suggest`, `op-curate`, `/suggest`, `/curate`) is fully shipped. Don't touch it during launch work unless an L-phase explicitly says to.
- Tim is the only user right now. The new skills have never been observed in isolation from the legacy `op-manual-*` set. L2 fixes this; until then, any skill-trigger benchmarks (L4) measure the *combined* set, not the new set alone.
- Auto mode is active. Bias toward execution within the phase's scope. When in doubt about a decision that affects the public surface (default settings, README copy, naming), ask.
