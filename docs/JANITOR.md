# Janitor Report — claude-spine pre-launch sweep

**Author:** janitor pass, 2026-05-27
**Scope:** Find lazy logic, bad writing, stale references, dead files. Make this launch-ready and refined.
**Status:** report only — nothing executed yet. Each item is tagged with a recommended action and a risk level.

The user is handling external launch (website + waitlist). This report covers internal refinement only.

---

## Tag legend

- **SAFE** — objectively correct, no judgment call, just do it. Typo-level corrections, stale numbers, broken cross-refs.
- **STRUCT** — structural change. Reasonable but a judgment call; user should ack before executing.
- **DELETE** — file/section deletion. Always asks before pulling the trigger.
- **DEFER** — known issue, fine to ship without; should land post-launch.
- **OPEN** — needs the user's input on a question I can't decide alone.

---

## Top-line summary

| # | Item | Tag |
|---|------|-----|
| 1 | Skill count drift: README/INDEX/CHANGELOG say "18 skills" — actual is 19 (`op-prepare` is the new one) | SAFE |
| 2 | Chapter count drift: README says "~70 atomic chapters" — actual is 80 | SAFE |
| 3 | Command count drift: README mentions `/onboard` only — actual surface is 8 slash commands | SAFE |
| 4 | `op-prepare` SKILL.md is 174 lines, **2.7× over the 65-line skill cap** | STRUCT |
| 5 | INDEX.md does not list `op-prepare`, `/prep`, `/session-start`, `/session-end` anywhere | SAFE |
| 6 | RECONSTRUCTION.md line 16 still says profile writes to `op-manual-profile.md` (stale; should be `claude-spine-profile.md`) | SAFE |
| 7 | PERSONALIZATION.md is a **264-line stale planning doc**, header says "planning — not started"; the loop has been built and shipped | DELETE / STRUCT |
| 8 | EXPLAINER.md "**For €20–50, you get…**" pricing block conflicts with MIT free / no-subscription positioning | STRUCT |
| 9 | CHANGELOG "Unreleased" roadmap still lists L5 + L8 as upcoming — both have shipped per `git log` | SAFE |
| 10 | Landing page (`landing/index.html`) uses Tailwind Play CDN, has placeholder `og:url`, TODO og:image, no waitlist form | STRUCT + DEFER |
| 11 | `install.sh` polish — re-backs-up identical files; misleading dry-run echoes; doesn't strip opinionated template's meta-instructions | DEFER (L4c already filed in LAUNCH.md) |
| 12 | 18 v1 chapter stubs at repo root (`01-…` through `18-…`) — kept for external link compatibility (L6 decision) | OPEN |
| 13 | LAUNCH.md (538 lines, 60 KB) and RECONSTRUCTION.md (526 lines, 82 KB) — internal dev journals; either pin a slim "current state" preface or trim post-launch | DEFER |
| 14 | `tests/skill-triggers/results/` — 38 files (164 KB) committed as snapshots; correct call but worth noting | KEEP (no action) |

Sections below expand each item with exact locations and recommended edits.

---

## 1. Skill count drift — 18 → 19

**Reality:** 19 SKILL.md files exist under `skills/core/op-*/`. The new one is `op-prepare`, added with the plan-driven workflow. CHANGELOG line 30 says "18 core skills"; README line 13 / line 44 / line 54 / line 112 / line 151 all say "18"; INDEX.md doesn't list `op-prepare` at all.

**Locations:**

- `README.md:7` — "18 `op-*` skills"
- `README.md:13` — "**18 `op-*` skills**"
- `README.md:44` — "should see all 18"
- `README.md:54` — "The 18 `op-*` skills"
- `README.md:112` — "the 18 op-* skills (shipped + maintained)"
- `README.md:151` — "./run.sh                       # all 18 skills"
- `INDEX.md:7` — "complete — every atomic file referenced below is written" (true for chapters; INDEX doesn't enumerate skills, but the prose tone implies completeness)
- `CHANGELOG.md:30` — "**18 core skills** in `skills/core/op-*/`"

**Action:** sweep `18` → `19` in these locations. Add an `op-prepare` row to INDEX.md under Workflow (it's the planning-pass skill — covers chapters 05h/05i/05j).

**Tag:** SAFE.

---

## 2. Chapter count drift — ~70 → 80

**Reality:** `find chapters -name '*.md' -type f | wc -l` = 80.

**Locations:**

- `README.md:14` — "**~70 atomic chapters**" → should read "**~80 atomic chapters**" or, better, the exact number.
- `CHANGELOG.md:29` — "**75 atomic chapter files**" — also stale; 5 more shipped since (likely the personalization quintet and some Phase 8 expansions).

**Action:** correct both. Suggest "**80 atomic chapters**" or keep the ~rounded form ("~80").

**Tag:** SAFE.

---

## 3. Command count + new commands not documented

**Reality:** `global/commands/` ships 8 slash commands: `add-skill`, `curate`, `onboard`, `prep`, `refresh-bucket`, `session-end`, `session-start`, `suggest`.

The CHANGELOG documents `/onboard`, `/suggest`, `/curate`, `/curate --review-stale`, `/refresh-bucket`, `/add-skill` (6 entries — already understated). It does **not** mention `/prep`, `/session-start`, `/session-end`.

`README.md` mentions only `/onboard` in the install flow (lines 42–43) and `/curate` / `/suggest` in the personalization section (lines 67–68). No mention of the plan-driven workflow.

**Action:**

- Add a small "Slash commands" section to README listing all 8 with one-liners.
- Update CHANGELOG `## [Unreleased]` (or open a `## [0.9.1]` block) noting the plan-driven workflow additions.
- Update INDEX.md to include rows for the new commands routing to `op-prepare` + the relevant workflow chapters.

**Tag:** SAFE.

---

## 4. `op-prepare` SKILL.md violates the 65-line skill body cap

**Reality:** `skills/core/op-prepare/SKILL.md` is 174 lines. The other 18 skills are 34–60 lines each (per the explicit "**bodies are 34–60 lines each**" claim in CHANGELOG.md:30, which is now wrong since op-prepare exists).

The 65-line skill cap is a **frozen decision** in RECONSTRUCTION.md ("routers, not content"). op-prepare is currently doing both — routing AND carrying the full planning procedure inline. The matching pattern already exists in the repo: `op-curate` was promoted to a folder skill (`SKILL.md` + adjacent `stale-review.md`) when adding the `--review-stale` path pushed it past the cap.

**Recommended action — split the same way:**

```
skills/core/op-prepare/
├── SKILL.md        # router only — frontmatter + 30-50 lines of "what to read first" + "when this fires"
└── procedure.md    # the actual 8-step planning pass body
```

`SKILL.md` keeps the frontmatter and tells Claude "for the planning pass procedure, read `procedure.md` from this same folder, plus chapters 05h/05i/05j". `procedure.md` carries the existing Step 1–8 content. Net result: cap respected; pattern matches op-curate; no behaviour change.

**Alternative:** document a documented waiver. Less consistent — I'd vote against unless the user prefers it.

**Tag:** STRUCT. Wants explicit ack.

---

## 5. INDEX.md missing op-prepare + new commands

`INDEX.md` has no row for `op-prepare`, `/prep`, `/session-start`, `/session-end`. Workflow section in INDEX (lines 39–55) ends at `05j-cold-start-protocol.md` but doesn't mention which skill routes there.

**Action:** add Workflow rows for the three new chapters' driver: `op-prepare` skill + `/prep`, `/session-start`, `/session-end` slash commands. Mirror how chapter 19 rows reference `op-onboard` / `op-suggest` / `op-curate`.

**Tag:** SAFE.

---

## 6. RECONSTRUCTION.md line 16 — stale profile path

**Line 16 (current "what v2 is" status):**

> Personalization — first-run interview (`op-onboard` skill) … Writes `~/.claude/op-manual-profile.md`.

This is at the top of the doc, in the *current* state explanation. The actual file path is `~/.claude/claude-spine-profile.md` (per global/neutral/CLAUDE.md.template and all other refs).

**Note:** line 99 is *also* stale-looking but is actually in a Phase 6 historical design note that explicitly says "(renames in Phase 6 to `~/.claude/claude-spine-profile.md`)" — leave that one alone, it's correctly historical.

**Action:** edit only line 16. Change `op-manual-profile.md` → `claude-spine-profile.md`.

**Tag:** SAFE.

---

## 7. PERSONALIZATION.md is stale

**Header (lines 1–6) currently says:**

> **Status:** planning — not started. Execution begins in Phase 8 after Phases 3–6.5 land.

But Phase 8 has shipped. CHANGELOG.md:21–22 says: "First tagged release. Pre-launch state — architecture frozen, personalization loop shipped, self-tests passing." The whole personalization mechanic this doc plans is **now in `chapters/personalization/19a–19e`** as the live, shipped content.

The file is 264 lines. It currently serves three audiences:

1. Pre-Phase-8 Claude session reading cold (no longer relevant — Phase 8 done)
2. External readers curious about the design rationale (covered better by chapters/personalization/19a–19e + CHANGELOG)
3. Maintainer audit trail (covered by RECONSTRUCTION.md Phase 8 entries + git log)

**Recommendations, in preference order:**

- **DELETE.** It's a planning artifact for work that's been shipped. Keeping it advertises a "planning" status that's now lying. The README links to it (line 98) — that link can be deleted with the file.
- **Demote.** Move to `docs/archive/PERSONALIZATION-plan-2026-05.md` with a 2-line preamble: "Historical planning document for Phase 8. The implementation shipped — see `chapters/personalization/19a–19e`."
- **Rewrite as as-built.** Strip the planning frame; reshape into a tight 50-line "personalization design notes" explainer that complements 19a–19e. Most expensive option, least likely to age well.

**Tag:** DELETE (preferred) or STRUCT (demote / rewrite). Asks before pulling.

---

## 8. EXPLAINER.md pricing — €20–50

**Location:** EXPLAINER.md:256–266.

Current text:

> ## What you'd actually pay for
>
> For €20–50, you get:
> 1. The handbook — …
> …
> No subscription. No login. No data sent anywhere. It lives on your computer, next to the AI, and works offline. You own it.

This conflicts with:

- `LICENSE` — MIT, free.
- `README.md:131` — "A managed product — claude-spine is a local install. No accounts, no telemetry, no auto-updates."
- The whole "git clone + ./install.sh" install flow.

**Reading:** EXPLAINER.md is the long-form "background reading on the v1 → v2 thinking" (per README.md:99). The "€20–50" feels like a leftover from an earlier consideration of selling it as a one-off. Either:

(a) **Sell it.** Open-source the install, sell a packaged tier (templates + setup + support). Out of scope for this janitor pass — that's a launch-strategy decision the user owns.

(b) **Remove the pricing.** Replace lines 256–266 with a tighter "what you actually get" section that drops the "For €20–50" framing. Matches the rest of the repo's free-and-local positioning.

**Tag:** STRUCT. Wants explicit decision on positioning.

---

## 9. CHANGELOG "Unreleased" roadmap is stale

**Lines 11–18:**

```
## [Unreleased]

Active roadmap in [`LAUNCH.md`](LAUNCH.md):

- **L5** — clean-room install on a fresh VM/container (pre-launch validation gate)
- **L7** — domain, landing page, demo video, waitlist (public launch)
- **L8** — opt-in: personal migration off a standalone `~/.claude/CLAUDE.md`
```

Per `git log`:
- `42d32e8 launch: L5 clean-room install report + 2 cosmetic divergences filed` — L5 done.
- `7965c4e launch: L8 Tim's personal migration to the spine` — L8 done.
- L7 — partially done: L7b (landing draft) is in; L7a/c/d/e still pending per LAUNCH.md.

**Action:** Rewrite the Unreleased section to reflect reality:

```
## [Unreleased]

Active roadmap in [`LAUNCH.md`](LAUNCH.md). Remaining gates before public launch:

- **L7a, L7c, L7d, L7e** — landing-page hardening (built CSS, OG image,
  waitlist wiring, copy polish) + demo recording.
- **L9 / L9b** — plan-driven workflow polish (already merged; documentation
  catch-up in flight).
```

Tighter, accurate, doesn't promise a v2 with a phantom L8/L5.

**Tag:** SAFE.

---

## 10. Landing page — `landing/index.html`

Known gaps from L7b notes:

1. **Tailwind Play CDN** — shows the "should not be used in production" warning in console. Replace with built CSS pre-launch (Tailwind CLI → `landing/dist/styles.css`).
2. **OG image** — line 14 has a TODO; no `og:image` meta tag present; need a 1200×630 PNG.
3. **`og:url`** — currently a placeholder (`https://claudespine.dev/`). Must point to the real launch URL.
4. **No waitlist form** — the user said they'd handle external infra; the form drop-in point is somewhere around the hero CTA. Just confirming this is in their scope, not mine.
5. **Pre-rendered "Copied" button** — already documented as a headless-Chromium incompatibility. Vanilla JS clipboard works in a real browser. Leave as-is unless the user wants a degradation path for the screenshot capture flow.

**Action breakdown:**

- (1) — STRUCT. Needs `npx tailwindcss -i ... -o ...` step + a build script. Worth filing as the actual L7a task.
- (2) — DEFER. Visual asset; user-driven.
- (3) — SAFE once the user picks a domain. Until then, leave the placeholder visible so it's obvious it's not real.
- (4) — Out of scope (user-handled).
- (5) — KEEP.

**Tag:** STRUCT + DEFER mix.

---

## 11. `install.sh` polish — known, deferred

LAUNCH.md L5 notes filed two cosmetic divergences:

1. Re-runs back up identical files even when the source and destination are byte-identical (no actual change). Should `cmp -s` first.
2. Dry-run mode prints `linked:` / `wrote:` messages even though nothing was written; should gate behind `[ "$DRY_RUN" -eq 0 ]`.

Plus the L8 open issue: the opinionated CLAUDE.md template (`global/opinionated/CLAUDE.md.template`) ships with template-author meta-instructions at the top and around the Stack defaults. Installing it copies the meta-blocks into the user's live `~/.claude/CLAUDE.md`. A `sed` strip during install would clean it up.

**Tag:** DEFER. Already filed in LAUNCH.md; not launch-blocking. Worth handling before public launch but not while the report is being read.

---

## 12. v1 chapter stubs at repo root (`01-…` through `18-…`)

18 files, ~140 KB total. Each carries a one-line deprecation header pointing at the v2 split in `chapters/<topic>/`. Body content is preserved for external-link compatibility per the L6 decision.

**The question:** are these still load-bearing?

Arguments to keep:

- External docs / blog posts / shares may link to `https://github.com/.../01-first-principles.md`. Removal breaks those links.
- Cost is low (~140 KB, doesn't affect spine routing — they're not in `chapters/` or `skills/`).
- L6 already evaluated this trade-off.

Arguments to remove (or relocate):

- Visual repo clutter at root. Adds 18 entries an external reader skims before finding the README structure.
- The deprecation header is one line; bodies haven't been edited since the split — drift risk is theoretical but real (a fix that lands in `chapters/foundations/` doesn't backport).
- Repository-relative search (`grep -r "..." .`) hits both copies — non-obvious if you don't know about the split.

**Recommendation:** move to `docs/v1-archive/` with one redirector stub at the root for each (just the one-line header, no body) **OR** GitHub-side 301s via a redirect file. The latter is cleaner if the user is willing to maintain a small map.

**Tag:** OPEN. Wants the user's call on the redirect strategy.

---

## 13. LAUNCH.md + RECONSTRUCTION.md size

- LAUNCH.md: 538 lines, 60 KB. Internal launch tracker. Useful for the maintainer; noisy for an external reader landing on the repo.
- RECONSTRUCTION.md: 526 lines, 82 KB. Build history of v2.

Both are linked from README (`README.md:97` for RECONSTRUCTION, `CHANGELOG.md:13` for LAUNCH). Both have served their purpose — they're now mostly historical.

**Recommendation post-launch (not before):**

- LAUNCH.md → trim to a 100-line "what we did to ship 0.9.0" recap; archive the long-form to `docs/launch-log.md`.
- RECONSTRUCTION.md → trim to a 150-line "v2 architecture decisions" doc; archive the phase-by-phase history to `docs/reconstruction-log.md`.

Don't touch these pre-launch. They are the audit trail for *how* the project got launch-ready.

**Tag:** DEFER.

---

## 14. `tests/skill-triggers/results/` — 38 committed files

The eval-set outputs (`.json` and `.log` per skill, plus `REPORT.md` and `needs-tightening.md`) are committed. 164 KB total.

This is intentional per CHANGELOG.md:59 ("documented bias toward under-counting routing-skill TP; reliable for FP regression detection"). The results serve as the regression baseline.

**Tag:** KEEP. No action.

---

## Smaller findings (in passing)

- `RECONSTRUCTION.md` mentions `/Users/macbook/.claude/plans/i-want-to-make-parallel-knuth.md` (line 19). This is an absolute path to a file on the maintainer's machine. External readers can't access it. Should either be removed or made a relative reference if the file is in the repo.
- `templates/CLAUDE.md` footer says `Updated: YYYY-MM-DD`. Fine for a template (it's a placeholder), but worth noting in case the user wants it pre-filled with a date.
- `templates/SESSION_STARTER.md` line 174 has the same `Updated: YYYY-MM-DD` placeholder.
- `bucket/SUGGESTIONS.md` and `bucket/CHANGELOG.md` — not read in this pass. Assumed to be small "seed" files. If they have any pre-baked example content from development, scrub it.

---

## Recommended execution order

If the user wants to act on this:

1. **Quick textual sweep** (15 min, all SAFE): items #1, #2, #3, #5, #6, #9, and the small findings. One commit: `cleanup: pre-launch documentation sweep`.
2. **op-prepare split** (#4): one focused commit. Mirror the op-curate folder-skill pattern. `skill: split op-prepare into router + procedure`.
3. **PERSONALIZATION.md decision** (#7): user picks delete / demote / rewrite. One commit either way.
4. **EXPLAINER.md €20–50** (#8): user picks reframe direction.
5. **Landing page CSS build** (#10.1): probably the actual L7a follow-up.
6. **v1 stubs decision** (#12): user picks the redirect strategy if they want to clean up.

Items 11, 13 are post-launch.

---

## Closing note

The repo is in better shape than this report makes it look. The drift is concentrated in three places (README/CHANGELOG/INDEX numbers, PERSONALIZATION.md status, RECONSTRUCTION.md line 16) and a single architecture-cap miss (op-prepare).

Everything else is "nice to clean up before strangers read it" rather than "blocks launch." If the user wants a one-PR cleanup that buys the most launch-readiness for the least time, it's items #1–#3, #5, #6, and #9. Maybe 20 minutes of edits.
