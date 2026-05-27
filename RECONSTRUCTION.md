# Reconstruction State — v2 Public Toolbox

**If you're a Claude session reading this cold, this file is your first read. It tells you exactly where the v2 reconstruction stands and what to do next.**

---

## What v2 is

The manual is being reconstructed from a private 18-chapter operating guide into a **public Claude Code toolbox** that anyone in the world can install. Three problems being solved:

1. **Granularity** — current chapters cluster multiple concepts (one chapter is 290 lines, several are >200). Reconstruction breaks them into ~55 atomic files (<150 lines each), one concept per file, organized by topic folder.
2. **Public-readiness** — founder-specific language (solo founder, Solvero, Dutch tradespeople, Next.js+Supabase opinions) is being neutralized. Stack opinions move to an explicit `global/opinionated/` variant; defaults become `global/neutral/`.
3. **Sophisticated routing** — instead of Claude loading whole chapters, a layer of skills + an index router picks the right atomic file for the task. Aim: Claude reads only what it needs.

Plus two novel mechanics:
- **Personalization** — first-run interview (`op-onboard` skill) calibrates Claude to user experience level, stack, push-back intensity, verbosity. Writes `~/.claude/op-manual-profile.md`.
- **Personal skill library (the "bucket")** — `skills/bucket/` ships empty. Each user builds their own library over time via `op-add-skill`. Not a sharing mechanism — purely personal. A core skill `op-bucket-router` reads `skills/bucket/INDEX.md` (auto-maintained), picks the right bucket skills for the current task, loads only those. Core skills age slowly (discipline); bucket skills can age fast (stacks/projects) without rotting the spine.

Full plan: `/Users/macbook/.claude/plans/i-want-to-make-parallel-knuth.md`.

Phase 8 plan (personalization + self-evolution loop): `PERSONALIZATION.md` in this repo.

---

## Current phase

**Phase 8d — bucket integration (chapters discovery + INDEX unification + stale-review + project-shift docs) — done** (2026-05-27). Ships `skills/core/op-curate/stale-review.md` (~65 lines) and updates `bucket/INDEX.md`, `op-bucket-router/SKILL.md`, `op-curate/SKILL.md`, `/curate`, `/refresh-bucket`, `bucket/README.md`, and chapters 19d + 19e. Three open questions resolved: (1) **unified bucket INDEX** — one `bucket/INDEX.md` with both Skills and Chapters tables, each with its own append-marker, `op-bucket-router` reads one file; split rejected because decomposition-rule #3 fails when the router always reads both halves; (2) **stale-review proxy** — driven by the `Added` date column in `bucket/INDEX.md` (default 6-month cutoff, tunable per session), no firing-timestamp tracking, no auto-archival; (3) **project-shift flow** — explicit only: run `/onboard --deep` to update the profile, then `/curate --review-stale` to walk the now-misaligned bucket entries. No auto-detection. `/onboard --refresh` references (5× in PERSONALIZATION.md, 1× in chapter 19e) replaced with `/onboard --deep` (the actual surface). `op-curate` became a folder skill (SKILL.md + adjacent `stale-review.md`) when adding `--review-stale` would have pushed SKILL.md past the 55-line cap — same pattern as `op-onboard`. `install.sh` needed zero changes — all touched files are in already-globbed paths.

**Phase 8c — `op-curate` curation skill — done** (2026-05-27). Ships `skills/core/op-curate/SKILL.md` (single-file, ~60 lines incl. frontmatter — same shape as `op-suggest`) and `global/commands/curate.md`. Read-before-write encoded as a numbered list in the body (three required reads: `SUGGESTIONS.md`, `INDEX.md`, overlapping bucket files). Diff-preview pattern spelled out by file type (new files → full body in code block; modifications → unified diff). Hard-refusal table covers four paths (`chapters/`, `skills/core/`, profile, global stub). Status flow: resolved entries move from "Pending" to "Applied / rejected (archive)" with `Status: applied|rejected` + added `Resolved: YYYY-MM-DD` line — the 8b open question resolved this direction.

**Phase 8b — `op-suggest` capture skill — done** (2026-05-27). Ships `skills/core/op-suggest/SKILL.md` (58 lines, single-file — no adjacent files; the entry schema lives inline) and `global/commands/suggest.md`. The trigger description in the frontmatter is locked: four narrow conditions to fire (explicit user signal, repeated friction 2+, end-of-session reflection, `/suggest`); five explicit no-fires (speculation, one-off, mid-task ideation, Claude hunch, dedupe-at-capture). Dry-run walked 8 scenarios through the description and all classified correctly. Claude can now capture suggestions during normal work; curation (`op-curate` / `/curate`) lands in 8c.

**Phase 8a — personalization chapters + bucket scaffolding — done** (2026-05-27). Ships `chapters/personalization/` (19a–19e), `bucket/SUGGESTIONS.md`, `bucket/CHANGELOG.md`, `bucket/chapters/` skeleton, and integrations into `INDEX.md` + `bucket/README.md`. The manual now *describes* personalization end-to-end; the skills that implement the loop land in 8b/8c.

**Phase 6.5 — bucket infrastructure — done** (2026-05-27). Ships `op-bucket-router`, `op-add-skill`, `/refresh-bucket` + `/add-skill` slash commands, and the seed `bucket/` folder at the repo root.

**Phase 6a (done 2026-05-27):**
- Phase 5 work committed.
- All 13 core skill bodies path-swept: `/Users/macbook/claude-op-manual/` → `~/.claude-spine/`. Each skill now carries a one-line note explaining the convention.
- Cross-reference back-fill complete: 17 stale `../../<N>-<chapter>.md` links across foundations, workflow, and signaling files now point at the correct atomic targets. The "Cross-reference back-fill" open question is **closed**.

**Phase 6b (done 2026-05-27):**
- `install.sh` shipped at repo root. Symlinks `~/.claude/skills/op-*` → `<spine>/skills/core/op-*`, ensures `~/.claude-spine` resolves to the spine clone, installs `settings.json` + env-leak hook, renders the global stub (substituting `{{SPINE_DIR}}`). Idempotent. Backs up overwritten files to `~/.claude-backup-<timestamp>/`. Flags: `--opinionated`, `--skip-global|skills|settings|hook`, `--dry-run`. Windows path warns to use WSL.
- `global/neutral/CLAUDE.md.template` written — thin stub (~20 lines) per locked architecture. Identity, spine path, INDEX.md pointer, profile file reference, override hierarchy.
- `global/opinionated/CLAUDE.md.template` — the founder-flavored heavy template moved here via `git mv`. `{{MANUAL_DIR}}` placeholders renamed to `~/.claude-spine` paths; old root-level chapter references (e.g., `06-feature-sizing.md`) re-pointed at the new atomic files (e.g., `~/.claude-spine/chapters/workflow/06-feature-sizing.md`). Header note added explaining this is the heavy variant.
- `global/INSTALL.md` rewritten to document install.sh + both variants + verification + uninstall.
- Templates audit complete. Decision: **light neutralization**, not abstract placeholders. Each template got a one-line "Example uses Next.js + Supabase + quote-management" header note so a Django/Go/Rails user understands the structure is stack-agnostic even though the filled-in examples aren't. SESSION_STARTER.md needed no change (already stack-agnostic). The templates are intentionally opinionated — they ARE the filled-in example users edit; abstract placeholders would have weakened them.

**Phase 6c (done 2026-05-27):**
- `skills/core/op-onboard/` shipped — SKILL.md (router, 43 lines incl. frontmatter), `questions-essential.md` (the 5 essentials with full phrasing + option sets), `questions-deep.md` (~10 follow-ups grouped A–F), `profile-template.md` (the exact layout the profile file must follow). Auto-fires when `~/.claude/claude-spine-profile.md` is missing; re-runnable via `/onboard` (essentials) and `/onboard --deep` (full).
- `global/commands/onboard.md` slash command added. `install.sh` updated: new section "3. slash commands" symlinks `global/commands/*.md` → `~/.claude/commands/*.md`; new `--skip-commands` flag; sections renumbered (3→4 global, 4→5 settings, 5→6 hook).
- `global/INSTALL.md` updated — new commands row in the install table, new `--skip-commands` flag, step-2 mention of running `/onboard` after restart, op-onboard added to the verify list (14 skills now), uninstall block adds the commands + profile cleanup lines.
- README rewritten as public-facing v2 entry point (129 lines, down from 235). Structure: tagline + v2 status banner → what you get (5 bullets) → install (one block) → first session (4 steps including `/onboard`) → architecture (stub + spine) → human read-order → folder tour → what's NOT here → contributing/license. The v1 layered-explanation, manual TOC, and triage table are gone — their content lives in INDEX.md and the atomic chapters now.

**Phase 6.5 (done 2026-05-27):**
- Bucket promoted to top-level `bucket/` at the repo root — matches the Phase 8 locked decision (PERSONALIZATION.md). Built at the final location to avoid a migration in 8a. Old `skills/bucket/` removed; `.gitkeep` moved via `git mv` to `bucket/skills/.gitkeep`.
- `bucket/INDEX.md` seed written — router-map table with an empty-marker row and the `<!-- op-add-skill appends rows above this comment. -->` insertion point. Explains the "loaded only when `op-bucket-router` fires" rule.
- `bucket/README.md` — explains what the bucket is, what NOT to put in it (project docs, secrets, one-offs), how Claude finds bucket skills (routed-to, not auto-loaded), and how `git pull` interacts with personal additions.
- `skills/core/op-bucket-router/SKILL.md` (42 lines) — fallback router. Fires only when no core `op-*` matched. Reads `bucket/INDEX.md`, picks one row, loads one file. Never invents bucket skills.
- `skills/core/op-add-skill/SKILL.md` (51 lines) + adjacent `bucket-skill-template.md` (70 lines, content) — guides bucket-skill creation. Gate enforces the "3+-times-paste-in" rule from chapter 13d. Single-file vs folder form is the user's call. Auto-appends a row to `bucket/INDEX.md`.
- `global/commands/refresh-bucket.md` — rescans `bucket/skills/`, rewrites the INDEX, shows a unified diff before saving, preserves `Added` dates on existing rows.
- `global/commands/add-skill.md` — direct entry point to `op-add-skill`.
- Top-level `INDEX.md` fallback section + RECONSTRUCTION target-folder-structure swept to the new `bucket/` location.
- `install.sh` needed **no changes** — its `op-*/` skill glob and `global/commands/*.md` command glob automatically pick up the new files. Verified via `--dry-run`.

**Phase 8e — dry-run + threshold tuning + README personalization section — done** (2026-05-27). End-to-end dry-run walked the loop on paper: onboard → capture via `op-suggest` → `/curate` → `op-curate` applies → `bucket/INDEX.md` row + `bucket/CHANGELOG.md` entry + `SUGGESTIONS.md` archive move → later sessions `op-bucket-router` finds the new row. One real friction caught: the empty-state placeholder rows in `bucket/INDEX.md` (both tables) and the `_(no pending suggestions yet)_` line in `bucket/SUGGESTIONS.md` were left in place when the first real entry appended — `/refresh-bucket` cleaned them up retroactively, but the user shouldn't need to. Fixed in `op-add-skill`, `op-curate`, and `op-suggest` by adding a one-line "replace the placeholder on first real append" rule to each (no template changes, no logic refactor — just an extra sentence in the apply step). Threshold tuning: **none**. The "auto-propose `/curate` at 5+ pending" idea deferred from 8c → 8d → 8e is explicitly **not shipped in v1** — rejected as speculative tuning without real-user data, same anti-pattern the personalization loop exists to fight. 19c's "When the queue gets long" section rewritten to be honest about the v1 surface (manual `/curate` invocation, no auto-nudge). README gained a "Personalization" section between "How it works" and "Read order" that walks the profile + the bucket loop end-to-end (capture / curate / route) and names the slash commands and skills. Two short bullet edits in "What you get" replaced the old single-line personalization mention with a pointer to the new section, and fixed the `skills/bucket/` → `bucket/` path lie left over from pre-6.5. Folder tree in the README updated to match. Phase 8 overall flips done.

**Next:** Phase 7 (demo + launch). The pre-launch cleanup section below is the lead-in — execute its items, then Phase 7. The personalization loop is feature-complete; the open work is doc lies, the v1/v2 root-file duplication, the skill-cap decision (60 vs 55), and a clean-room install verification on a fresh host.

---

## Architecture (frozen decisions)

- **5-layer architecture:** core skills → bucket → index → atomic chapters → templates → global setup.
- **Folder structure:** see "Target folder structure" below.
- **Variant policy:** `global/neutral/` is the default install; `global/opinionated/` is the founder-flavored example users can opt into.
- **Distribution:** bash `install.sh` only for v1. No npm, no MCP, no auto-update.
- **Bucket policy:** ships empty. Never pre-seeded. The whole point is to avoid the speculative-library trap.
- **Decomposition rule:** split a chapter when its sub-topics are *independently load-bearing* — i.e., a user asking a focused question should be able to read one slice and get a complete answer without the others. Line count is not the test. The questions to ask before splitting:
  1. Do the candidate pieces answer different user questions? (Not "different paragraphs" — different *questions*.)
  2. Does each piece stand alone — readable without its siblings?
  3. Does splitting actually reduce what Claude loads per task, or does the router end up loading two of them together anyway?
  4. Is anything load-bearing only when read with another piece? If yes, those belong in one file.

  If the answer to 1–3 is yes and 4 is no → split. Otherwise keep as one file regardless of size. A 200-line file on one tight topic beats five 40-line files that always get read together.
- **Skill body cap:** 55 lines (revised 2026-05-27 in Phase 6c). Original cap was 40; in practice every router needs frontmatter + one-line path-resolution note + index table + how-to-use + common triggers + sibling skills, and clean writing lands at 40–50 lines. Skills covering more than one source chapter (e.g., `op-workflow` covers ch 05 + 06) reach 52 cleanly. The cap exists to keep skills as *routers*, not content — none of the 14 core skills have crossed into content territory. If a skill body needs more than ~55 lines, the extra material is content and should move to an adjacent file in the skill folder (see `op-onboard` for the pattern: SKILL.md routes to `questions-essential.md` / `questions-deep.md` / `profile-template.md`, all loaded on-demand).
- **Atomic file cap:** 150 lines. A hard ceiling, not a decision rule — if you'd exceed it, the content is almost certainly load-bearing for multiple distinct questions and the decomposition rule above will tell you where the seams are. If it doesn't, leave the file at 150+ rather than splitting on a fake seam.
- **Naming (locked 2026-05-27):** the public name is **`claude-spine`**. Tagline: "The spine of every Claude Code project." Local folder, GitHub repo, all internal references rename together in Phase 6. Current folder `claude-op-manual` and remote `claude-code-operators-manual` are both pre-rename names — don't update them yet.
- **Onboarding mechanic (re-locked 2026-05-27):** both mechanisms — `op-onboard` auto-fires when no profile file exists; `/onboard` slash command re-runs / edits the profile. The interview is **deep, not shallow** — this profile is meant to last across all of the user's projects long-term, so the upfront cost is justified. Target ~15–25 questions, branching by experience level. Captured dimensions (designed in Phase 6):
  - **Developer profile** — years of experience, self-assessed level, comfort areas
  - **Stack preferences** — primary, secondary, "avoid," version pinning where it matters
  - **Project context** — typical project types, solo vs team, production user scale, time pressure
  - **Working style** — verbosity, push-back intensity, mentor vs peer tone, signal preferences (context-filling, scope-creep, drift, verification gaps)
  - **Output format** — diffs vs full files, commenting density, emoji policy, diagram style
  - **Risk + safety** — production-app strictness, version-control hygiene, command-execution tolerance

  Profile written to `~/.claude/op-manual-profile.md` (renames in Phase 6 to `~/.claude/claude-spine-profile.md`). Global CLAUDE.md references it; Claude reads it every session. **Open design question:** all upfront vs progressive (5 essential up front + Claude asks 1–2 more when relevant decisions come up in real work). Decide in Phase 6 — instinct says progressive, since 25-question walls scare off new users.
- **Bucket sharing (re-locked 2026-05-27):** **no sharing model at all.** The bucket is each user's *personal* skill library. They write their own skills into it; they keep them. No companion repo, no GitHub topic convention, no fork-and-share community story. If someone wants to share, that's their problem — claude-spine doesn't ship any sharing infrastructure. The earlier "fork-and-share" framing was misleading and is removed.
- **Bucket index (re-locked 2026-05-27):** **yes, there's a `skills/bucket/INDEX.md`.** Same pattern as the chapter `INDEX.md` — Claude reads the index, picks the matching skills for the task, loads only those. This keeps per-task reads small even when the user's library grows to 50+ skills. Maintenance: `op-add-skill` updates `INDEX.md` automatically whenever it writes a new skill. For users who drop files into `skills/bucket/` manually, a `/refresh-bucket` slash command regenerates the index by scanning the folder. `op-bucket-router` trusts the index (no scan-on-fire). This matches the chapter-routing pattern; one mental model for routing instead of two.

---

## Progress by phase

| Phase | Scope | Status |
|---|---|---|
| 0 | Bootstrap — `RECONSTRUCTION.md`, `INDEX.md` skeleton, folder skeleton, README banner | **done (2026-05-27)** |
| 1 | Foundations — `chapters/foundations/` (atomize ch 01–04) + `op-foundations` skill | **done (2026-05-27)** |
| 2 | Workflow core — `chapters/workflow/` (atomize ch 05–08) + workflow/modes/brownfield skills | **done (2026-05-27)** |
| 3 | Prompting + signaling — `chapters/prompting/`, `chapters/signaling/` + skills | **done (2026-05-27)** |
| 4 | Persistence + tools — `chapters/persistence/`, `chapters/tools/`, `chapters/subagents/` + skills. **Includes the ch 13 thesis revision.** | **done (2026-05-27)** |
| 5 | Recovery + anti-patterns — `chapters/recovery/`, `chapters/anti-patterns/` + skills | **done (2026-05-27)** |
| 6a | Structural cleanup — commit Phase 5, sweep hardcoded paths to `~/.claude-spine/`, back-fill cross-references, lock install + onboarding decisions | **done (2026-05-27)** |
| 6b | `install.sh` + neutral global template + opinionated example + templates audit | **done (2026-05-27)** |
| 6c | `op-onboard` skill (hybrid interview) + README rewrite | **done (2026-05-27)** |
| 6.5 | Bucket infrastructure — `op-bucket-router`, `op-add-skill`, `bucket/INDEX.md` seed, `/refresh-bucket` + `/add-skill` slash commands. Bucket built at top-level `bucket/` to align with Phase 8's locked decision. | **done (2026-05-27)** |
| 7 | Demo + launch — end-to-end dry-run, video script outline, launch checklist | not started |
| 8 | Personalization + self-evolution loop — `op-suggest`, `op-curate`, `bucket/SUGGESTIONS.md`, `bucket/chapters/`, personalization chapter. **Full plan: `PERSONALIZATION.md`.** Splits into sub-phases 8a–8e (one per session). | **done (2026-05-27)** |
| 8a | Personalization chapters (19a–19e) + bucket scaffolding (`SUGGESTIONS.md`, `CHANGELOG.md`, `bucket/chapters/`) + INDEX section. The manual describes personalization; skills land in 8b/8c. | **done (2026-05-27)** |
| 8b | `op-suggest` capture skill + `/suggest` slash command + entry-schema lock + dry-run | **done (2026-05-27)** |
| 8c | `op-curate` curation skill + `/curate` slash command + read-before-write enforcement + diff-preview pattern | **done (2026-05-27)** |
| 8d | Integration: `op-bucket-router` discovers `bucket/chapters/`; bucket INDEX unification decision; stale-review tooling; project-shift handling | **done (2026-05-27)** |
| 8e | End-to-end dry-run, trigger threshold tuning, README personalization section, Phase 8 done flip | **done (2026-05-27)** |

Phases 1–5 are content-independent; any order works, but listed order is dependency-friendly. Phase 6 needs 1–5 done. Phase 6.5 should land before Phase 8 (bucket infrastructure first, then the evolution loop on top). Phase 7 needs 6 + 6.5 + 8.

---

## Target folder structure

```
claude-op-manual/
├── README.md                      # public-facing
├── INDEX.md                       # router map for atomic chapters
├── RECONSTRUCTION.md              # this file
├── CONTRIBUTING.md                # how outsiders propose changes
├── LICENSE                        # MIT
├── install.sh                     # one-shot installer (Phase 6)
├── chapters/
│   ├── foundations/               # Phase 1
│   ├── workflow/                  # Phase 2
│   ├── prompting/                 # Phase 3
│   ├── signaling/                 # Phase 3
│   ├── persistence/               # Phase 4
│   ├── tools/                     # Phase 4
│   ├── subagents/                 # Phase 4
│   ├── recovery/                  # Phase 5
│   └── anti-patterns/             # Phase 5
├── skills/
│   └── core/                      # shipped + maintained by the manual
├── bucket/                        # PERSONAL layer — top-level (promoted from skills/bucket/ in Phase 6.5)
│   ├── INDEX.md                   # router map; auto-updated by op-add-skill, /refresh-bucket for manual adds
│   ├── README.md                  # what the bucket is, what NOT to put in it
│   └── skills/                    # empty by design — each user's personal skill library
├── templates/                     # existing — neutralize in Phase 6
└── global/
    ├── neutral/                   # default install (Phase 6)
    ├── opinionated/               # founder-flavored example (Phase 6)
    ├── commands/                  # slash commands (onboard, add-skill, refresh-bucket)
    └── hooks/                     # existing — keep
```

Current state (post-Phase 0): all `chapters/` and `skills/` subfolders exist as `.gitkeep`-only placeholders. `global/neutral/` and `global/opinionated/` exist empty. Existing files (18 chapters at repo root, `templates/`, `global/CLAUDE.md.template`, etc.) remain in their old locations until their phase touches them.

---

## Atomic-file map

This table grows as each phase lands. Each new file added here when it's written.

| File | Source chapter | Phase | Status |
|---|---|---|---|
| `chapters/foundations/01a-llm-loop.md` | 01 | 1 | written 2026-05-27 |
| `chapters/foundations/01b-three-levers.md` | 01 | 1 | written 2026-05-27 |
| `chapters/foundations/01c-failure-modes.md` | 01 | 1 | written 2026-05-27 |
| `chapters/foundations/02-context-budget.md` | 02 | 1 | written 2026-05-27 (no split, renamed only) |
| `chapters/foundations/03a-hard-limits.md` | 03 | 1 | written 2026-05-27 |
| `chapters/foundations/03b-soft-limits.md` | 03 | 1 | written 2026-05-27 |
| `chapters/foundations/03c-project-fit.md` | 03 | 1 | written 2026-05-27 |
| `chapters/foundations/04a-model-tiers.md` | 04 | 1 | written 2026-05-27 |
| `chapters/foundations/04b-plan-and-fast-mode.md` | 04 | 1 | written 2026-05-27 |
| `chapters/foundations/04c-budget-and-cost.md` | 04 | 1 | written 2026-05-27 |
| `skills/core/op-foundations/SKILL.md` | new | 1 | written 2026-05-27 |
| `chapters/workflow/05-overview.md` | 05 | 2 | written 2026-05-27 |
| `chapters/workflow/05a-stage-0-decide.md` | 05 | 2 | written 2026-05-27 |
| `chapters/workflow/05b-stage-1-prep.md` | 05 | 2 | written 2026-05-27 |
| `chapters/workflow/05c-stage-2-architect.md` | 05 | 2 | written 2026-05-27 |
| `chapters/workflow/05d-stage-3-build.md` | 05 | 2 | written 2026-05-27 |
| `chapters/workflow/05e-stage-4-integrate.md` | 05 | 2 | written 2026-05-27 |
| `chapters/workflow/05f-stage-5-harden.md` | 05 | 2 | written 2026-05-27 |
| `chapters/workflow/05g-stage-6-ship.md` | 05 | 2 | written 2026-05-27 |
| `chapters/workflow/06-feature-sizing.md` | 06 | 2 | written 2026-05-27 (no split, renamed only) |
| `chapters/workflow/07a-executor-mode.md` | 07 | 2 | written 2026-05-27 |
| `chapters/workflow/07b-reviewer-mode.md` | 07 | 2 | written 2026-05-27 |
| `chapters/workflow/07c-explainer-mode.md` | 07 | 2 | written 2026-05-27 |
| `chapters/workflow/07d-planner-mode.md` | 07 | 2 | written 2026-05-27 |
| `chapters/workflow/07-mode-switching.md` | 07 | 2 | written 2026-05-27 |
| `chapters/workflow/08a-discovery-sequence.md` | 08 | 2 | written 2026-05-27 |
| `chapters/workflow/08b-safety-patterns.md` | 08 | 2 | written 2026-05-27 |
| `chapters/workflow/08c-teaching-unfamiliar.md` | 08 | 2 | written 2026-05-27 |
| `chapters/workflow/08d-rewrites.md` | 08 | 2 | written 2026-05-27 |
| `skills/core/op-workflow/SKILL.md` | new (supersedes `op-manual-workflow`) | 2 | written 2026-05-27 |
| `skills/core/op-collaboration-modes/SKILL.md` | new | 2 | written 2026-05-27 |
| `skills/core/op-brownfield/SKILL.md` | new | 2 | written 2026-05-27 |
| `chapters/prompting/09a-five-principles.md` | 09 | 3 | written 2026-05-27 |
| `chapters/prompting/09b-prompt-structure.md` | 09 | 3 | written 2026-05-27 |
| `chapters/prompting/09c-examples-and-anti-examples.md` | 09 | 3 | written 2026-05-27 |
| `chapters/prompting/10-visuals.md` | 10 | 3 | written 2026-05-27 (no split, moved into prompting/) |
| `chapters/signaling/11-overview.md` | 11 | 3 | written 2026-05-27 |
| `chapters/signaling/11a-context-signals.md` | 11 | 3 | written 2026-05-27 |
| `chapters/signaling/11b-scope-signals.md` | 11 | 3 | written 2026-05-27 |
| `chapters/signaling/11c-drift-signals.md` | 11 | 3 | written 2026-05-27 |
| `chapters/signaling/11d-verification-signals.md` | 11 | 3 | written 2026-05-27 (verification + end-of-session merged) |
| `chapters/signaling/11e-meta-scope.md` | 11 | 3 | written 2026-05-27 |
| `skills/core/op-prompting/SKILL.md` | new | 3 | written 2026-05-27 |
| `skills/core/op-visuals/SKILL.md` | new | 3 | written 2026-05-27 |
| `skills/core/op-signaling/SKILL.md` | new | 3 | written 2026-05-27 |
| `chapters/persistence/12a-three-layers-overview.md` | 12 | 4 | written 2026-05-27 |
| `chapters/persistence/12b-claudemd.md` | 12 | 4 | written 2026-05-27 |
| `chapters/persistence/12c-memory.md` | 12 | 4 | written 2026-05-27 |
| `chapters/persistence/13a-skill-anatomy.md` | 13 | 4 | written 2026-05-27 |
| `chapters/persistence/13b-trigger-descriptions.md` | 13 | 4 | written 2026-05-27 |
| `chapters/persistence/13c-skill-design-patterns.md` | 13 | 4 | written 2026-05-27 |
| `chapters/persistence/13d-skill-anti-patterns.md` | 13 | 4 | written 2026-05-27 (revised library thesis) |
| `chapters/persistence/14a-settings-cascade.md` | 14 | 4 | written 2026-05-27 |
| `chapters/persistence/14b-hook-recipes.md` | 14 | 4 | written 2026-05-27 |
| `chapters/tools/15-selection-principles.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15a-file-ops.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15b-search.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15c-execution.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15d-planning.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15e-delegation.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15f-scheduling.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15g-web.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15h-mcp.md` | 15 | 4 | written 2026-05-27 |
| `chapters/tools/15i-slash-commands.md` | 15 | 4 | written 2026-05-27 (not in original INDEX skeleton — added to INDEX) |
| `chapters/subagents/16a-when-to-delegate.md` | 16 | 4 | written 2026-05-27 |
| `chapters/subagents/16b-agent-types.md` | 16 | 4 | written 2026-05-27 |
| `chapters/subagents/16c-parallel-and-background.md` | 16 | 4 | written 2026-05-27 |
| `skills/core/op-persistence/SKILL.md` | new | 4 | written 2026-05-27 |
| `skills/core/op-hooks/SKILL.md` | new | 4 | written 2026-05-27 |
| `skills/core/op-tools/SKILL.md` | new | 4 | written 2026-05-27 |
| `skills/core/op-subagents/SKILL.md` | new | 4 | written 2026-05-27 |
| `chapters/recovery/17a-failure-triage.md` | 17 | 5 | written 2026-05-27 |
| `chapters/recovery/17b-recovery-moves.md` | 17 | 5 | written 2026-05-27 (absorbed step 3 "update the system" + "when to walk away") |
| `chapters/recovery/17c-high-stakes-cases.md` | 17 | 5 | written 2026-05-27 |
| `chapters/anti-patterns/18a-prompting.md` | 18 | 5 | written 2026-05-27 (absorbed communication anti-patterns) |
| `chapters/anti-patterns/18b-scope.md` | 18 | 5 | written 2026-05-27 |
| `chapters/anti-patterns/18c-context.md` | 18 | 5 | written 2026-05-27 |
| `chapters/anti-patterns/18d-tools.md` | 18 | 5 | written 2026-05-27 |
| `chapters/anti-patterns/18e-verification.md` | 18 | 5 | written 2026-05-27 |
| `chapters/anti-patterns/18f-security.md` | 18 | 5 | written 2026-05-27 |
| `chapters/anti-patterns/18g-workflow.md` | 18 | 5 | written 2026-05-27 |
| `chapters/anti-patterns/18h-long-term.md` | 18 | 5 | written 2026-05-27 |
| `chapters/anti-patterns/18-meta-patterns.md` | 18 | 5 | written 2026-05-27 (absorbed cross-catalog TL;DR) |
| `skills/core/op-recovery/SKILL.md` | new (supersedes recovery half of `op-manual-recovery`) | 5 | written 2026-05-27 |
| `skills/core/op-anti-patterns/SKILL.md` | new (supersedes anti-pattern half of `op-manual-recovery`) | 5 | written 2026-05-27 |
| `skills/core/op-onboard/SKILL.md` | new | 6c | written 2026-05-27 |
| `skills/core/op-onboard/questions-essential.md` | new | 6c | written 2026-05-27 |
| `skills/core/op-onboard/questions-deep.md` | new | 6c | written 2026-05-27 |
| `skills/core/op-onboard/profile-template.md` | new | 6c | written 2026-05-27 |
| `global/commands/onboard.md` | new | 6c | written 2026-05-27 |
| `bucket/INDEX.md` | new | 6.5 | written 2026-05-27 |
| `bucket/README.md` | new | 6.5 | written 2026-05-27 |
| `skills/core/op-bucket-router/SKILL.md` | new | 6.5 | written 2026-05-27 |
| `skills/core/op-add-skill/SKILL.md` | new | 6.5 | written 2026-05-27 |
| `skills/core/op-add-skill/bucket-skill-template.md` | new | 6.5 | written 2026-05-27 |
| `global/commands/refresh-bucket.md` | new | 6.5 | written 2026-05-27 |
| `global/commands/add-skill.md` | new | 6.5 | written 2026-05-27 |
| `chapters/personalization/19a-overview.md` | new | 8a | written 2026-05-27 |
| `chapters/personalization/19b-profile-and-onboarding.md` | new | 8a | written 2026-05-27 |
| `chapters/personalization/19c-suggestion-loop.md` | new | 8a | written 2026-05-27 |
| `chapters/personalization/19d-curation-session.md` | new | 8a | written 2026-05-27 |
| `chapters/personalization/19e-extending-the-bucket.md` | new | 8a | written 2026-05-27 |
| `bucket/SUGGESTIONS.md` | new | 8a | written 2026-05-27 |
| `bucket/CHANGELOG.md` | new | 8a | written 2026-05-27 |
| `bucket/chapters/.gitkeep` | new | 8a | written 2026-05-27 |
| `skills/core/op-suggest/SKILL.md` | new | 8b | written 2026-05-27 |
| `global/commands/suggest.md` | new | 8b | written 2026-05-27 |
| `skills/core/op-curate/SKILL.md` | new | 8c | written 2026-05-27 |
| `global/commands/curate.md` | new | 8c | written 2026-05-27 |
| `skills/core/op-curate/stale-review.md` | new | 8d | written 2026-05-27 |

---

## Pre-existing assets to preserve

- **The 4 already-working skills** (`op-manual-workflow`, `op-manual-tactics`, `op-manual-templates`, `op-manual-recovery`) — these are the seed. Don't recreate; rename/expand as their phases land.
- **Current 18 chapters at repo root** — source material. Each gets atomized and moved into `chapters/<topic>/`. Voice and examples carry over.
- **Existing templates** — content stays; neutralize the Tim/Solvero-specific examples in Phase 6.
- **`global/hooks/block-env-staging.sh`** — keep, ship in both neutral and opinionated variants.

---

## Operating rules for execution sessions

When you're picking up a phase:

1. **Read this file first.** It's the cold-read entry point.
2. **Then read `INDEX.md`.** It shows the target router map for atomic chapters.
3. **Then read the plan** at `/Users/macbook/.claude/plans/i-want-to-make-parallel-knuth.md` — the full architecture, decisions, and roadmap.
4. **Stay in your phase's scope.** No cross-phase work. If you spot something off-scope, note it in "Open questions" below — don't bundle.
5. **Update this file at end of session:**
   - Flip the phase status (in-progress → done).
   - Add new files to the atomic-file map.
   - Add anything you learned to "Open questions."
6. **Atomize on real seams, not on size.** The point of v2 is small per-task reads — Claude loads one slice per question. Run the chapter through the decomposition rule (above): independently load-bearing sub-topics that answer different user questions → split. One tight topic that always lands together → keep as one file even if it's long. The failure mode is in *both* directions: leaving a multi-topic chapter as one file because it reads smoothly end-to-end **and** chopping a single-topic chapter into stubs that always get loaded together.
7. **Voice consistency.** Carry the current manual's voice forward. Atomization is structural; tone shouldn't shift.

---

## Open questions

To be resolved in their phase.

- Public landing page / docs site for v1, or GitHub README only? (Phase 7.)
- Domain registration for `claudespine.dev` / `.com` — desirable for the launch/video, not blocking. (Phase 7.)

(Resolved 2026-05-27: repo name → `claude-spine`; onboarding → auto-fire + slash command; bucket sharing → no sharing model at all; bucket index → `skills/bucket/INDEX.md`, auto-maintained.)

(Resolved 2026-05-27, pre-Phase-6 audit: install architecture → stub + spine; rename `claude-op-manual` → `claude-spine` is **done** — folder is now `/Users/macbook/claude-spine/`.)

(Resolved 2026-05-27, Phase 6a: skill installation → **symlink** (`~/.claude/skills/op-*` → `<spine>/skills/core/op-*`); interview depth → **hybrid** (5 essentials up front + opt-in `/onboard --deep` for the full ~15-question set); cross-reference back-fill **complete**; hardcoded path sweep **complete** — all skills now use `~/.claude-spine/...` paths.)

(Resolved 2026-05-27, Phase 6c: **skill body cap raised from 40 → 55 lines.** All 14 core skills fit — range 34–52, op-onboard at 43. The cap exists to keep skills as routers; none crossed into content territory. When a skill needs more than 55 lines, extra material goes in adjacent files loaded on-demand — `op-onboard` is the reference pattern.)

(Resolved 2026-05-27, Phase 8d: **unified bucket INDEX** — one `bucket/INDEX.md` holds both Skills and Chapters tables, each with its own append-marker. Split rejected (decomposition-rule #3: router always reads both halves). **Stale-review proxy** — `Added` date in INDEX, 6-month default cutoff, no firing-timestamp tracking. **Project-shift flow** — `/onboard --deep` then `/curate --review-stale`, explicit only, no auto-detect. `/onboard --refresh` references replaced with `/onboard --deep` (5× PERSONALIZATION.md, 1× chapter 19e).)

---

## Install architecture (locked 2026-05-27, pre-Phase-6 audit)

**Mechanism:** stub + spine.

- `~/.claude/CLAUDE.md` is a **thin stub** that points Claude at the spine. It contains: (a) one-line identity ("this machine uses claude-spine"), (b) path to the spine root, (c) instruction to consult `<spine>/INDEX.md` when a task needs manual content, (d) a pointer at `~/.claude/claude-spine-profile.md` for personalization. Everything else (discipline, security, stack, anti-patterns) lives in the spine's chapters and is loaded on-demand by the core skills.
- `<spine>/INDEX.md` is the **lookup mechanism**. Skills route through it; Claude reads only the atomic files that match the task.
- `<spine>/` can live anywhere — `~/.claude-spine/` is the default but installable elsewhere. `install.sh` writes the path into the stub global and into the skill files (or symlinks them).
- **Core skills are installed into `~/.claude/skills/op-*/`** (because Claude Code only auto-loads skills from there). Two implementation options for Phase 6 (sub-decision above): copy + rewrite paths, or symlink to the spine. Either way, the skill bodies reference paths inside `<spine>/chapters/...` — resolved at install time.
- **Profile file:** `~/.claude/claude-spine-profile.md`. Written by `op-onboard`. Referenced from the stub global so Claude reads it every session.

This replaces the earlier hard-coded `/Users/macbook/claude-op-manual/...` paths in every skill with an install-time-resolved location. The "Skill install path" open question (Phases 1–5 notes) is now closed at the architecture level; only the copy-vs-symlink choice remains.

**Why this matters for the "make global obsolete" claim:** the stub is small enough (~15–25 lines) that any user's hand-written global is structurally replaced — identity + pointer + profile reference. Stack opinions, security rules, and discipline aren't *in* the global anymore; they're loaded on-demand from the spine, filtered by the profile. This is what makes the obsolescence claim defensible at launch — pending the personalization interview actually capturing enough nuance (the deferred conversation in `[[project-revisit-global-obsolete-claim]]`).

### Phase 2 notes (2026-05-27)

- Chapter 06 (feature sizing) stayed as a single file — sizing rules, the smell tests, and the split heuristics all answer the same question ("does this fit one session?") and only land when read together. No independent slices to extract.
- Chapter 07 atomized into 4 mode files + a `07-mode-switching.md` because each mode answers a distinct question ("when is executor right?", "when is planner right?", etc.) that a user asks one at a time, and the cross-cutting "switch modes within a session" content is its own question. Each file is independently load-bearing.
- `op-manual-workflow` (the still-loaded legacy skill) is not deleted — Phase 2 adds the new `op-workflow` / `op-collaboration-modes` / `op-brownfield` in `skills/core/` alongside it. The cutover happens at Phase 6's `install.sh`.
- Same hard-coded-path issue noted in Phase 1's open questions still applies to the three new skills here. Phase 6 needs to template these.

### Phase 3 notes (2026-05-27)

- Chapter 09 split into 09a (principles), 09b (structure), 09c (examples). Each answers a different user question: 09a is "what are the rules?", 09b is "how do I structure a non-trivial prompt?", 09c is "show me good vs bad on a real task — and which patterns do I memorize?". A user typically loads exactly one. The split is content-driven, not length-driven.
- Chapter 10 stayed as a single file — when/why to use visuals, how to pair them with text, ASCII vs Mermaid, mockups, mobile screenshots. All answer one question ("how do I use visuals well?") and land together. No independent slices.
- Chapter 11 atomized into 5 category files plus a new `11-overview.md`. Each category file answers a distinct in-the-moment question Claude itself faces ("is context filling?", "is this scope creep?", "is this meta-scope?") and fires from a different trigger. The overview holds the cross-cutting "how does proactive signaling work as a discipline" content — premise, phrasing, cadence, anti-patterns — which is its own question (typically the user's, not Claude's). Same shape as `07-mode-switching.md`. **INDEX updated** to add the overview row.
- Verification-gates and end-of-session signals merged into one file (`11d-verification-signals.md`) — INDEX listed them as separate categories, but both answer the same in-the-moment question: "is this actually done, or just compiled?" The end-of-session triggers are the closing case of the verification check, not a different category. Splitting would have produced two pieces that always get read together, which fails decomposition-rule question 3.
- All three new skills (`op-prompting`, `op-visuals`, `op-signaling`) sit alongside the legacy `op-manual-tactics` skill, which still covers prompting today. Cutover at Phase 6's `install.sh`, same as Phase 2's pattern.
- Same hard-coded-path issue (open question carried from Phase 1/2) applies to the three new skill files. Phase 6 must template.
- Cross-references in `09b`, `09c`, `11c`, `11d`, `11e` still point at original root-level chapters (e.g., `../../17-recovery-playbook.md`, `../../13-custom-skills.md`, `../../18-anti-patterns.md`) because those chapters aren't atomized yet. Sweep when phases 4–5 land — already noted in "Open questions / Cross-reference back-fill."

### Phase 4 notes (2026-05-27)

- **Chapter 12 split into 3 (12a overview, 12b CLAUDE.md, 12c memory).** Each answers a distinct user question — "where does X go?", "how do I write CLAUDE.md?", "how does memory work?" The "skills" section of ch 12 was *not* given its own file because ch 13 covers skills deeply; 12a contains only the routing fact that skills exist alongside the other two layers, which is enough for the decision-tree question 12a answers.
- **Chapter 13 split into 4 (13a anatomy, 13b triggers, 13c patterns, 13d anti-patterns with revised thesis).** Each is a different question a user lands on individually. 13d contains the **revised library thesis** the plan calls for: the "don't ship libraries" framing is wrong — the right rule is "ship libraries with narrow triggers and slow-aging content." The manual itself is the existence proof. The personal-collection 3+-paste-ins rule still stands.
- **Chapter 14 split into 2 (14a cascade, 14b recipes).** Different questions ("where do settings live?" vs "what should I hook?"). 14a also absorbs the keybindings-help mention since it's an adjacent settings concern at the same level of abstraction. The full chapter is only ~148 lines, but the split is content-driven, not length-driven — a user on the cascade question doesn't need recipes loaded.
- **Chapter 15 split into 10 files (15 selection + 15a-i).** INDEX had 9 planned splits (no slash-commands file). Added `15i-slash-commands.md` because slash commands are substantial in the source, don't fit cleanly into any other category, and answer a distinct "which command for this work" question. **INDEX updated to add the 15i row.** The brief "skills" recap in ch 15 was *not* given its own file — it was already a cross-reference to ch 12, so the cross-reference is sufficient (now to `op-persistence` 13a). The "choosing between similar tools" matrix was absorbed into `15-selection-principles.md` rather than getting its own file — same question as the principles.
- **Chapter 16 split into 3 (16a when, 16b types, 16c parallel/background).** "Writing a good subagent prompt" was placed in 16a (same question as "should I delegate") rather than its own file — when a user decides to delegate, prompt-writing is the immediate next step. The orchestrator-with-specialists trap went in 16b (it's a *pattern of custom subagents*, which is the question 16b answers).
- **Cross-references inside Phase 4 files use relative paths** between sibling atomic files (`[13b](13b-trigger-descriptions.md)`) and cross-folder paths (`[14b](../persistence/14b-hook-recipes.md)`). Phase 5 should follow the same convention. Earlier-phase files that still point to root-level chapters can now be swept to point at the new atomic files — open question "Cross-reference back-fill" is still pending; do it in Phase 5 or 6.
- **All four new skills (`op-persistence`, `op-hooks`, `op-tools`, `op-subagents`) use hardcoded `/Users/macbook/claude-op-manual/...` paths**, same as every prior phase. The "Skill install path is hard-coded" open question remains; Phase 6's `install.sh` must template.
- **The legacy `op-manual-*` skills still load** — Phase 4 added new core skills alongside them, did not replace. Cutover happens at Phase 6's `install.sh`.

### Phase 5 notes (2026-05-27)

- **Chapter 17 split into 3 (17a triage, 17b moves, 17c high-stakes).** This matches the INDEX target. The decomposition rule passes cleanly: 17a is the *diagnosis* question, 17b is the *generic-action* question, 17c is the *unrecoverable-cost-of-getting-it-wrong* question. A user typically loads exactly one — the triage table when they don't know what's wrong, a specific move when they do, or 17c directly when they recognize a high-stakes situation.
- **17b absorbed step 3 ("update the system") and the "when to walk away" section.** Both are the closing case of applying a move — they're not independently load-bearing questions on their own, they're the "what next" after a recovery. Putting them in their own file would have failed decomposition-rule question 3 (the router would just load them together with 17b every time).
- **Chapter 18 split into 9 files (18a–18h + 18-meta-patterns).** This matches the INDEX target with one decomposition decision: the "Communication anti-patterns" section in the source chapter was *not* given its own file. The three entries fold naturally into 18a-prompting (two are about how you prompt across turns; the third — "treating Claude as if it remembers other sessions" — is also a prompting/persistence boundary issue and goes in 18a). 18a's title in INDEX was updated to "Prompting + communication anti-patterns" to make this visible. Adding 18i-communication.md would have left a 3-entry stub that always reads together with 18a.
- **Cross-catalog TL;DR moved into 18-meta-patterns.md.** The original chapter ended with a TL;DR that summarized all categories. Each atomic file now has its own TL;DR for its category. The cross-catalog summary went into 18-meta-patterns because meta is the highest-leverage category — a user landing on the meta file is the one most likely to benefit from the wider list of failure-mode clusters.
- **18-meta-patterns.md keeps the bare `18-` prefix** (not `18i-`) per the INDEX skeleton — it sits apart from the lettered categories because it's about extending the system, not about a category of in-codebase work.
- **The two new skills (`op-recovery`, `op-anti-patterns`) supersede the single legacy `op-manual-recovery`.** The legacy skill covered both recovery and anti-patterns in one description; splitting them lets each skill have a sharper trigger (recovery fires on quality-dropping symptoms; anti-patterns fires on "about to do the thing" intents). The legacy skill remains loaded until Phase 6's `install.sh` does the cutover.
- **Cross-references** in the new Phase 5 files use the established convention — relative paths between sibling atomic files (`[17b-recovery-moves.md]`) and cross-folder paths (`[../foundations/01c-failure-modes.md]`, `[../workflow/06-feature-sizing.md]`, `[../persistence/12c-memory.md]`, `[../signaling/11e-meta-scope.md]`, etc.). Every cross-reference target now exists — the **"Cross-reference back-fill" open question can be closed in Phase 6** by sweeping any remaining root-level chapter links in earlier-phase files (09b, 09c, 11c, 11d, 11e from Phase 3 notes) to point at the new atomic files.
- **Same hard-coded `/Users/macbook/claude-op-manual/...` path issue** applies to both new skill files. Phase 6's `install.sh` must template.

### Phase 6a notes (2026-05-27)

- **Phase 6 split into 6a / 6b / 6c.** Original Phase 6 conflated 5+ deliverables into one session — failing the "one session = one feature" rule. 6a handles structural cleanup (path sweep + cross-ref back-fill), 6b handles install + global template, 6c handles onboarding + README rewrite.
- **Install mechanism decision: symlink.** install.sh (6b) will create `~/.claude/skills/op-*` → `<spine>/skills/core/op-*` symlinks. `git pull` in the spine flows updates instantly to every installed skill. Skill bodies use `~/.claude-spine/...` paths; install.sh ensures `~/.claude-spine` resolves to the user's spine clone (real path or symlink). On Windows, install.sh falls back to copy + per-update re-install (Phase 6b detail).
- **Onboarding mechanism decision: hybrid.** First-run interview asks 5 essentials (experience level, primary stack, push-back intensity, verbosity, project type). User can opt into the full ~15-question deep interview now or later via `/onboard --deep`. Captures both casual users (who'd bounce off a 25-question wall) and committed ones who want a fully-loaded profile from day 1.
- **Path-resolution convention.** Skills read `~/.claude-spine/chapters/...` paths. Claude expands `~` to `$HOME` before passing to Read. Each skill now carries a one-line note at the top of the index explaining this. (Alternative considered: `$CLAUDE_SPINE_DIR` env var in shell rc — rejected because env var resolution requires a Bash round-trip on every chapter read. Tilde expansion is direct.)
- **17 cross-references back-filled.** Files swept: `02-context-budget`, `01c-failure-modes`, `04b-plan-and-fast-mode`, `03a-hard-limits` (foundations); `05b`, `05d`, `05f`, `07a`, `07b`, `07d` (workflow); `11b`, `11c`, `11e` (signaling). All point at correct atomic files now. Cross-reference back-fill open question **closed**.
- **Skill body line-cap broken across all 13 skills.** Pre-existing condition (most were over 40 before the path-note insert). New open question added for 6b/6c to decide cap revision vs body prune.
- **Phase 6a touched no chapter content.** Only path strings and cross-reference link targets. Voice/structure/decomposition unchanged. This is structural cleanup work, not new content.

### Phase 6c notes (2026-05-27)

- **`op-onboard` is a multi-file skill, not a single SKILL.md.** SKILL.md is the router (49 lines: mode-selection table → adjacent-files table → how-to-run → rules → post-interview message). Question banks and the profile-file layout live in `questions-essential.md`, `questions-deep.md`, `profile-template.md` — Claude loads them on-demand only when the skill fires. This is the pattern future complex skills should follow: if SKILL.md needs more than 50 lines, the content is operational data, not routing, and belongs adjacent.
- **Interview is one-question-at-a-time via `AskUserQuestion`.** Each question has 2–4 pre-defined options; the tool auto-adds "Other" for free-text. Multi-select used for comfort/lean-in areas, stacks-to-avoid, and active-signal preferences. No question walls — the whole point of the hybrid model is essentials don't scare new users and deep is opt-in.
- **Profile file is `~/.claude/claude-spine-profile.md`** with a fixed 6-section structure (Developer profile, Stack preferences, Project context, Working style, Output format, Risk + safety) plus optional Notes. Unfilled deep sections render as `(unfilled — run /onboard --deep to capture)` — leaves a visible trail of what's missing. Strict structure so future tooling can parse it.
- **`/onboard` slash command** lives in `global/commands/onboard.md` with frontmatter (`description`, `argument-hint: [--deep]`). The command file references `$ARGUMENTS` so Claude reads `--deep` and routes accordingly — no arg-parsing logic in SKILL.md itself. `install.sh` was extended with a new section 3 to symlink `global/commands/*.md` into `~/.claude/commands/` and a matching `--skip-commands` flag. Sections 4/5/6 renumbered from 3/4/5.
- **`global/INSTALL.md` updated** alongside install.sh to document the new commands row + `--skip-commands` flag + step-2 mention of `/onboard` after restart + 14 skills (not 13) in the verify list + uninstall additions for commands and profile.
- **README rewritten from 235 → 129 lines.** Old README described v1 architecture (root-level chapters, copy-paste install, layered manual/templates/global story). New README leads with the v2 status banner, then five "what you get" bullets, install + first-session + how-it-works + read-order + folder tour + what's-NOT-here + contributing. INDEX.md is now the manual TOC; triage table lives in `chapters/recovery/17a-failure-triage.md`. The README's job shrank to *entry point* — get them installed, oriented, and reading.
- **Skill body cap raised to 55** (was 40). All 14 skills fit — range 34–52, op-onboard at 43, op-workflow at 52 (legitimately wider because it covers ch 05 + 06). New rule: if you need more than 55, extract to adjacent files. See Architecture section above.
- **No chapter content touched.** Phase 6c was skill + global + README — exactly the planned scope, no drift.

### Phase 6.5 notes (2026-05-27)

- **Bucket built at top-level `bucket/`, not `skills/bucket/`.** PERSONALIZATION.md locked the top-level decision, and RECONSTRUCTION explicitly flagged the "coordinate 6.5 and 8" concern. Building at the final location now means Session A of Phase 8 ("lift `skills/bucket/` → `bucket/`") is already done — no migration, no path-rewrite churn later. Phase 8 will *extend* `bucket/` (adding `bucket/chapters/`, `bucket/SUGGESTIONS.md`, `bucket/CHANGELOG.md`); 6.5 only ships `bucket/skills/` + INDEX + README.
- **`bucket/INDEX.md` has a marker comment** (`<!-- op-add-skill appends rows above this comment. Don't move this marker. -->`) so `op-add-skill` can append rows without re-templating the whole file. `/refresh-bucket` regenerates the table body while preserving the marker. Same shape as common static-site index conventions.
- **`op-bucket-router` is a fallback router, not a front-door router.** It fires only when no core `op-*` matched the task. The skill description names this explicitly: "Use as the fallback router when the user's task isn't covered by any other core `op-*` skill." The skill body has explicit "When NOT to fire" rules to prevent it from interrupting flows where a core router already fits.
- **`op-add-skill` has a gate at the top of the body** — refuses to add a skill unless the user has reached for the pattern 3+ times or named an explicit "I always do this" condition. Without the gate, this skill becomes the speculative-library factory chapter 13d warns against. The gate is the same rule the user must apply manually elsewhere; encoding it into the skill removes the temptation to skip it.
- **`op-add-skill` is a folder skill** (with `bucket-skill-template.md` adjacent) following the `op-onboard` pattern: SKILL.md routes, the template is loaded only when actually writing a file. Keeps SKILL.md at 51 lines and prevents the template's content from being read on every fire.
- **Two slash commands shipped, not one.** `/refresh-bucket` (rebuild the INDEX from disk) is the obvious one; `/add-skill` (direct entry point to `op-add-skill`) is the second. Without `/add-skill`, the user would rely on natural-language phrasing to fire the skill — works most of the time but fails in the edge case where the skill description's triggers don't match the user's words. The direct command is the safety net.
- **`install.sh` needed zero changes.** Section 2 already globs `skills/core/op-*/`, section 3 already globs `global/commands/*.md`. Both new skills and both new commands are picked up automatically. Verified by `./install.sh --dry-run` — the new symlink lines appear without code edits.
- **Bucket folder is NOT symlinked into `~/.claude/`.** Bucket skills are deliberately *not* auto-loaded — they're routed-to by `op-bucket-router`. Symlinking them into `~/.claude/skills/` would make Claude Code auto-load them as core-equivalents, defeating the routing pattern (and risking trigger noise as the user's library grows to 30+ entries). The bucket lives at `~/.claude-spine/bucket/` and is reached only through `op-bucket-router` reading `bucket/INDEX.md`.
- **No chapter content touched.** Phase 6.5 was infrastructure-only: folders, INDEX seed, two skills, two slash commands. Exactly the planned scope.

### Phase 8b notes (2026-05-27)

- **`op-suggest` is a single-file skill** (`SKILL.md` only, no adjacent files). The entry schema is small enough to pin inline; `SUGGESTIONS.md` itself already documents the same schema with its own example block. No template duplication needed. Skill body lands at 58 lines — three over the ~55 soft cap, but the description is intentionally rich (Session B locks the trigger description as the failure-prone surface — bloating *here* means noise everywhere, so the literal trigger phrases need to be in the frontmatter for the matcher to catch them). Body content is all routing, not operational data — no candidate to move to an adjacent file.
- **Trigger description is locked.** Four fire conditions: (1) explicit user signal with quoted phrases ("we should add this to the manual," "remember this," "next time we hit this, let's…"); (2) same friction 2+ times this session — same mistake, same direction, same correction; (3) end-of-session reflection ("what did we learn here?," "anything worth capturing?"); (4) `/suggest`. Five no-fires explicitly listed: speculation, one-off friction, mid-task ideation, Claude's own hunches, already-pending duplicates. The "prefer silence over capture" bias from 19c is encoded directly: "Missed signal is $0; queue noise wrecks curation."
- **Entry schema pinned in the body** as a literal markdown block matching `SUGGESTIONS.md`'s example. Type enum: `new-skill | new-chapter | profile-update | observation`. `profile-update` is explicitly logs-only (never auto-applied; user runs `/onboard`) — this resolves the Session B open question about "profile-affecting suggestions" cleanly: capture them but never act on them.
- **`/suggest` slash command at `global/commands/suggest.md`.** Bypasses the high-threshold gate (the slash command IS the gate — user explicitly opted in). Walks the user through title → type → proposed change → append. Same shape as `/add-skill`.
- **Dry-run walked 8 scenarios** through the locked description: 4 should-fire (explicit signal, repeated friction, end-of-session reflection, `/suggest`) and 4 no-fires (one-off correction, mid-task ideation, Claude hunch, speculation). All classified correctly. The "orthogonal contexts" carve-out from 19c is handled by the "same mistake, same direction, same correction — you can quote both corrections" line: if both corrections can't be quoted side-by-side as the same statement, it's not a pattern.
- **`install.sh` needed zero changes.** Sections 2 (`skills/core/op-*/`) and 3 (`global/commands/*.md`) already glob the new files. Same as Phase 6.5 — the install architecture is correctly future-proofed against new skills and commands landing.
- **Open question for 8c:** SUGGESTIONS.md status updates on resolution — does `op-curate` flip `Status: pending` in-place (preserving chronological order) or move the entry under "Applied / rejected (archive)"? The current SUGGESTIONS.md skeleton supports either path; the schema-in-body for `op-suggest` doesn't take a position (it only writes the initial `pending` entry). 8c decides — Session C will make the call when implementing the curation skill body. **Resolved in 8c: move-to-archive (see 8c notes).**
- **No chapter content touched.** Phase 8b was skill + slash command only — exactly the planned scope.

### Phase 8c notes (2026-05-27)

- **`op-curate` is a single-file skill** (`SKILL.md` only, no adjacent files). Same shape as `op-suggest`: the curation flow is operational checklist, not template content — nothing to load on-demand. Body lands at 55 lines (at the cap), frontmatter adds 4. Total file ~60 lines, in the same band as `op-suggest` (58) and `op-workflow` (52). All 15 core skills now sit at 34–60 lines.
- **Status flip = move-to-archive (not in-place).** The 8b open question is closed in this direction. On apply or reject, the entry leaves the Pending section and lands under "Applied / rejected (archive)" with `Status: applied|rejected` and an added `- **Resolved:** YYYY-MM-DD` line. The SUGGESTIONS.md skeleton from 8a already supports this — the archive heading was written then. Reasons: (a) the Pending section stays small as the queue grows; (b) `op-suggest`'s append marker is inside Pending and never gets touched by curation; (c) the archive preserves chronological capture order without polluting the active queue. The alternative (in-place flip) was viable but would have left Pending bloated with resolved entries that `op-curate` has to filter on every read.
- **Read-before-write encoded as a numbered list, not a soft rule.** Three explicit reads (`SUGGESTIONS.md`, `bucket/INDEX.md`, any overlapping bucket files). The skill body says: "if you're about to propose a write without having opened the bucket INDEX this session, that's the bug." Same shape as the 19d chapter rule.
- **Diff preview is spelled out by file type.** New files → full body in fenced code block. Modifications → unified diff. The skill body names both shapes inline; the chapter (19d) doesn't go into format-by-type — that's an operational detail belonging to the skill.
- **Hard refusal table = the same four paths as 19d.** `chapters/`, `skills/core/`, profile, global stub. Each row names where the user *should* go instead (PR, `/onboard`, re-run install) so the refusal isn't a dead-end.
- **New-chapter writes are explicitly half-supported.** Phase 8d wires `op-bucket-router` to discover `bucket/chapters/`; until then, op-curate can write a chapter and log it in CHANGELOG, but the router won't auto-find it. The body flags this with a one-line "bucket-router chapter discovery lands in Phase 8d." Avoids pretending the chapter path is fully integrated when it isn't.
- **`/curate` slash command at `global/commands/curate.md`.** Same shape as `/suggest`: short frontmatter description, one-paragraph invocation pointing at the SKILL, with an explicit "confirm the mode switch if user was mid-task" note. No args — `--review-stale` lands in 8d.
- **Auto-propose at 5+ pending NOT encoded into the skill.** Both PERSONALIZATION.md and 19d mention "Claude proposes curate when 5+ pending." That's a signaling rule in normal sessions, not part of the on-demand curation flow. The skill itself is invoked, never autonomous. Pre-emptive proposal logic is deferred — likely a hint in 19c or a tiny standalone behavior in 8d, not a third skill.
- **`install.sh` needed zero changes.** Sections 2 (`skills/core/op-*/`) and 3 (`global/commands/*.md`) absorb the new skill and command automatically. Same outcome as 6.5, 8a, 8b — the install architecture continues to absorb new skills and commands without code edits.
- **No chapter content touched.** Phase 8c was skill + slash command only — exactly the planned scope.

### Phase 8e notes (2026-05-27)

- **Dry-run was on-paper, not multi-session.** PERSONALIZATION.md's Session E originally proposed a "10-session arc" dry-run. That's not realizable inside one session and was an aspirational framing. The actually-useful dry-run for an in-session pass is walking the loop's file-shapes against each other and checking the seams. Did that: onboard → `op-suggest` append schema vs `SUGGESTIONS.md` Pending shape → `/curate` read-before-write reads vs the existing INDEX/CHANGELOG/SUGGESTIONS shapes → `op-curate` apply-step writes vs `bucket/INDEX.md` Skills/Chapters table format → `op-bucket-router` read-back of those tables. Loop is end-to-end consistent.
- **One real friction caught: empty-state placeholder rows.** `bucket/INDEX.md` Skills and Chapters tables both have a `_(no skills yet — ...)_` / `_(no chapters yet — ...)_` row so the table renders before any real rows land. `bucket/SUGGESTIONS.md` Pending section has the same shape with `_(no pending suggestions yet)_`. None of `op-add-skill`, `op-curate`, or `op-suggest` removed the placeholder on first real append — the file ended up with the placeholder *and* the real row sitting together. `/refresh-bucket` cleaned it up retroactively, but a user shouldn't need to. Fixed by adding a one-line "if the body holds only the empty-marker / placeholder row, **replace** instead of appending" rule to each of the three skills' apply steps. No template changes, no logic refactor — three single-line edits.
- **Threshold tuning: none.** The Phase 8b lock on `op-suggest`'s four-condition trigger (explicit signal / 2+ same friction / end-of-session reflection / `/suggest`) and five no-fires stays. Same on `op-curate`'s read-before-write + one-change-per-approval enforcement. Speculative tuning without real-user data is the exact anti-pattern the loop exists to fight ([13d](chapters/persistence/13d-skill-anti-patterns.md)); v1 ships the locked thresholds and waits for actual signal from users to justify changes.
- **Auto-propose `/curate` at 5+ pending: deliberately not shipped.** Carried 8c → 8d → 8e as "maybe in 19c, maybe in op-suggest." Final call: no. The trade-off — a recurring "queue has N pending — want to `/curate`?" nudge after every capture past the threshold — adds Claude-noise on every fire, against a visibility cue (the file is right there) that the user can hit at will. The threshold itself ("is 5 right?") is also a guess without real-user data. Rewrote 19c's "When the queue gets long" section to be honest about the v1 surface: manual `/curate` invocation, no auto-nudge, document the deferred call explicitly. Open for revisit post-launch if real usage shows queues going graveyard before users notice.
- **README gained a Personalization section** between "How it works" and "Read order." Walks the profile + bucket loop end-to-end with the slash-command and skill names called out (`/onboard`, `op-suggest` / `/suggest`, `/curate` / `/curate --review-stale`, `op-bucket-router`). Two existing "What you get" bullets replaced: the old single-line personalization mention now points to the new section; the bucket bullet's path fixed from the pre-6.5 `skills/bucket/` to top-level `bucket/`. Folder tree at the bottom of the README also fixed (`skills/bucket/` → `bucket/` as a sibling of `skills/`). Did **not** touch the other doc-lies in the "Pre-launch cleanup" section (skill count, v2 status banner, root v1/v2 duplication, INDEX header) — those are explicitly out of 8e scope and waiting for the pre-launch sweep.
- **No skill or chapter additions; no atomic-file-map changes.** Phase 8e was tuning + verification + README, not new content. The placeholder-replace fixes landed inside the three already-listed skill files; the 19c reframe landed inside the already-listed chapter file; the README section landed inside the already-shipped README.
- **`install.sh` needed zero changes.** Continues the post-6.5 pattern: every Phase 8 sub-phase landed inside already-globbed paths.

### Phase 8d notes (2026-05-27)

- **Unified bucket INDEX locked.** `bucket/INDEX.md` now has two tables — Skills and Chapters — each with its own append-marker (`<!-- op-add-skill appends rows above this comment. -->` and `<!-- op-curate appends chapter rows above this comment. -->`). The split alternative was rejected because decomposition-rule #3 fails: `op-bucket-router` always reads both halves to answer "is there a bucket entry for this task?", so two files would always load together — the router never benefits from the split. The single-file shape also matches 19e's pre-written description (the chapter was authored agnostically in 8a but leaned unified throughout).
- **`op-bucket-router` discovers chapters via the INDEX, not by folder-scan.** Router reads `bucket/INDEX.md` and scans both tables. Chapters are *loaded as content* (not "fired" — there's no trigger to satisfy); skills *fire* as before. Added a "Skills vs chapters — when each fits" decision table to the router body to keep the routing semantics legible. Chapter discovery doesn't add a separate code path; it adds a second table read inside the same INDEX read.
- **`op-curate` became a folder skill.** Adding the `--review-stale` mode pushed the SKILL.md body past the 55-line cap, so the stale-review procedure moved to `op-curate/stale-review.md` — loaded only when `/curate --review-stale` fires. Same architectural pattern as `op-onboard` (`questions-essential.md` / `questions-deep.md` loaded on-demand). SKILL.md gained an "Adjacent files" table and a one-line argument-dispatch rule at the top of "When to fire."
- **Stale-review proxy = `Added` date column.** No firing-timestamp tracking, no per-file last-used field. The `Added` column already exists in the INDEX (`op-add-skill` writes it, `op-curate` writes it when applying a suggestion, `/refresh-bucket` preserves it). 6-month default cutoff, tunable per session ("show me anything older than 3 months"). The date is a *coarse* proxy — the user's judgment is the actual filter. Rejected alternatives: tracking last-fired (heavy, requires hook plumbing); auto-archival (violates "no auto-GC" rule from 19e).
- **`/curate --review-stale` is opt-in only and never composed.** Stale-review never auto-fires at the end of a normal curation pass. Never auto-proposes itself. The user invokes it explicitly. Mixing modes within a session was considered and rejected — same "one session, one kind of work" rule from 19d.
- **Project-shift handling is documentation, not new tooling.** `/onboard --refresh` was a phantom command — referenced in PERSONALIZATION.md (5×) and chapter 19e (1×) but never built. Real surface is `/onboard --deep`. Replaced all references. The shift flow is now spelled out in 19e: `/onboard --deep` first (re-set profile), *then* `/curate --review-stale` (walk the now-misaligned bucket). Order matters and is called out.
- **`op-curate` now writes Chapters table rows on apply.** When a `new-chapter` suggestion is approved, the SKILL.md body says: append a row to the Chapters table in `bucket/INDEX.md` above its marker, same shape as the Skills row. The Phase 8c caveat ("bucket-router chapter discovery lands in Phase 8d") was deleted from the body — both halves are now wired.
- **`/refresh-bucket` rebuilds both tables.** Scans `bucket/skills/` (folder-form + single-file) and `bucket/chapters/` (single-file only — bucket chapters are flat per 19e). Chapter row summary comes from the chapter file's first H1 (no frontmatter convention for bucket chapters). Markers are preserved per-table; `Added` dates are preserved per-row. The command's existing diff-preview / no-invent-rows / read-only-on-core rules carry over unchanged.
- **`bucket/README.md` updated** with the three-way add path (guided skill via `op-add-skill`, via curation, by hand + `/refresh-bucket`) and a one-line note about the two-table INDEX shape.
- **Chapters 19d and 19e updated.** 19d's "deferred to Phase 8d" caveat replaced with the real procedure pointer. 19e's `/onboard --refresh` replaced; the garbage-collection section spells out the `Added`-date cutoff mechanic and the project-shift order-of-operations.
- **`install.sh` needed zero changes.** Sections 2 (`skills/core/op-*/`) and 3 (`global/commands/*.md`) absorb the new adjacent file and the changed slash commands automatically. Consistent with 6.5, 8a, 8b, 8c — the install architecture continues to absorb new files in already-globbed paths without code edits.
- **What's NOT in 8d.** No auto-propose-curation behavior (carried into 8e as a possible signaling tweak in 19c). No new top-level skill. No `op-add-chapter` — chapters land via curation or hand-drop + `/refresh-bucket`. No project-shift detection logic — explicit only.

### Phase 8a notes (2026-05-27)

- **Five chapters written under `chapters/personalization/`.** Each answers a distinct user question: 19a is "what is personalization here?", 19b is "how does the profile work?", 19c is "when does Claude capture a suggestion?", 19d is "what happens in a curation session?", 19e is "when do I extend the bucket — and how?". Decomposition-rule check: each piece stands alone; none read as paired-only; the router will load one per user question. Line counts: 19a 76, 19b 96, 19c 94, 19d 112, 19e 99 — all comfortably under the 150 cap.
- **Voice carried forward** from the existing chapters (12a/13d as references). Direct, table-heavy, internal cross-links via `[19x](19x-slug.md)` short form, "TL;DR" footer per file. No tone drift.
- **Personalization section added to top-level INDEX.md** between "Anti-patterns" and "Fallback: personal skill library." Five rows for 19a–19e. The fallback section still points at `bucket/INDEX.md` — unchanged from 6.5.
- **`bucket/SUGGESTIONS.md` skeleton** ships with the entry-format example baked in (so 8b's `op-suggest` has a target schema already documented in-file), a `<!-- op-suggest appends new entries above this comment -->` marker (same convention as `bucket/INDEX.md`), and a "Pending" / "Applied / rejected (archive)" split per the curation pattern in 19d. Entries don't auto-archive on resolution — 8c can either move them under the archive heading or leave them inline with status flipped; both shapes work and the decision lives in `op-curate`'s body.
- **`bucket/CHANGELOG.md` skeleton** mirrors the SUGGESTIONS.md shape with its own append-marker. Format-by-example, same as the suggestion entries.
- **`bucket/chapters/.gitkeep`** placeholder so the folder is tracked. No content — personal chapters land there as users add them.
- **`bucket/README.md` updated** to mention `bucket/chapters/`, `SUGGESTIONS.md`, `CHANGELOG.md` — the "Phase 8 will add..." parenthetical is gone now that those exist. Cross-references to 19c/19d/19e added.
- **No skill bodies touched.** Phase 8a was content + scaffolding only — exactly the planned scope. `op-suggest` and `op-curate` land in 8b/8c.
- **Open question carried into 8d:** unified `bucket/INDEX.md` vs split skills/chapters INDEX files. 8a leaves the existing single `bucket/INDEX.md` from 6.5 alone (currently scoped to skills). 8d decides whether to extend it or split — both routes are still viable, and 19e is written agnostically ("`op-bucket-router` reads `bucket/INDEX.md`") so the chapter doesn't need a re-edit either way.
- **Cross-references** in the new files: same convention as Phases 1–5. Sibling files use `[19x](19x-slug.md)`; cross-folder uses `[13d](../persistence/13d-skill-anti-patterns.md)`, `[14a](../persistence/14a-settings-cascade.md)`, `[14b](../persistence/14b-hook-recipes.md)`. All targets exist.

### Phase 6b notes (2026-05-27)

- **`install.sh` lives at the repo root.** Self-locates the spine via `${BASH_SOURCE[0]}` resolution, so it works whether the user clones to `~/.claude-spine/`, `~/dev/claude-spine/`, or anywhere else. It then creates a `~/.claude-spine` symlink pointing at the real clone so all the skills' `~/.claude-spine/...` paths resolve consistently. Idempotent: re-running detects existing correct symlinks and is a no-op for those; non-symlink files get backed up to `~/.claude-backup-<timestamp>/`.
- **Default install = neutral stub.** `./install.sh` (no args) installs the thin stub. `./install.sh --opinionated` installs the heavy template instead. This matches the locked architecture decision: neutral is the default, opinionated is the opt-in example.
- **`{{SPINE_DIR}}` is substituted at install time** via `sed` against the template before writing. Only used in the neutral stub; the opinionated template uses `~/.claude-spine` directly (since it was already hand-written with that convention).
- **Skill symlinks back at `~/.claude/skills/op-*`** because Claude Code only auto-loads skills from there. `git pull` in the spine clone propagates to all installed skills instantly with no re-install.
- **Windows path:** install.sh detects `MINGW*/MSYS*/CYGWIN*` and bails with a message pointing at WSL. Real Windows support (with `mklink /J` junction-points or copy-on-update) deferred to a future phase if anyone asks.
- **Granular skip flags** (`--skip-global|skills|settings|hook`) allow partial installs — useful when iterating on the installer itself or for users who only want the skills, not the global rewrite. `--dry-run` prints the exact actions without touching the filesystem; verified working before the real run.
- **`global/CLAUDE.md.template` moved to `global/opinionated/CLAUDE.md.template`** via `git mv` (history preserved). Inside it: `{{MANUAL_DIR}}` placeholders (~5 occurrences) rewritten to `~/.claude-spine/...`; old root-level chapter references (`06-feature-sizing.md`, `02-context-window-truth.md`, `16-subagents.md`, `17-recovery-playbook.md`, `11-proactive-signaling.md`, `18-anti-patterns.md`) re-pointed at the new atomic files in `chapters/<topic>/`. Header note added to signal "this is the heavy variant."
- **`global/INSTALL.md` rewritten** to document the install.sh path + both variants + verification queries + uninstall. The earlier copy-paste instructions are gone — `install.sh` does the same thing more safely (backups, idempotency, dry-run).
- **Templates audit: light neutralization.** Each template got a one-line header note explaining that the example domain (Next.js + Supabase + quote-management for tradespeople) is concrete by design and the structure is stack-agnostic. SESSION_STARTER.md needed no change. Rejected: abstract placeholders (would have weakened the templates as filled-in demos); a templates/neutral/ + templates/opinionated/ split (YAGNI for v1, users will heavily edit anyway).
- **Skill body line-cap open question still pending.** Phase 6b didn't touch skill bodies. 6c can revisit when adding `op-onboard`.

---

## Pre-launch cleanup (after Phase 8 done, before Phase 7)

Captured 2026-05-27 from a ship-readiness audit. **Not blocking Phase 8 work** — execute after 8e flips to done, as the lead-in to Phase 7. Half a day of work total. Re-audit after each item.

**Doc lies (highest priority — these break first-touch trust):**

1. **README skill count: "14 op-* skills" → "18".** Two places: the v2 status banner near the top, and the bullet under "What you get." The README's own verify step (§"First session after install" step 4) tells the user to expect 14 — they'll see 18 and assume the install is broken.
2. **README v2 status banner is two phases behind.** Says "Phases 0 through 6c are done … Phase 6.5 is next." 6.5 + 8a + 8b + 8c are all done. Update to current state or change the phrasing to "v2 reconstruction nearing completion — see RECONSTRUCTION.md for live state."
3. **`INDEX.md` header still says "skeleton — most files don't exist yet."** They do. Replace with the actual status (all written, phases 1–5 populated).
4. **Root v1/v2 duplication unresolved.** Eighteen `01-…` through `18-…` files at the repo root vs `chapters/<topic>/<NNx>-…`. README calls v1 authoritative "until every phase atomizes it" — phases 1–5 atomized them and are done. Decide: delete, `git mv` into `archive/`, or stamp `> DEPRECATED — see chapters/<topic>/<NNx>-…` at the top of each. Pick one, don't leave both routable.

**Code/infra:**

5. **Two skills exceed the self-imposed 55-line cap:** `op-curate` (60), `op-suggest` (58). Trim, or raise the cap to 65 and add a one-line note in RECONSTRUCTION's architecture section explaining curation/capture skills are slightly longer because they encode workflow flow. Don't ignore — own the decision.
6. **`jq` is a hard dependency of the env-leak hook but a soft prereq of the installer.** Today: installer warns, hook breaks silently on first `git add .env` if `jq` is absent — the exact failure mode the hook exists to prevent. Fix: either fail-fast in `install.sh` when `--skip-hook` is not set and `jq` is missing, or have the hook itself shell-out a fallback grep on `$CLAUDE_TOOL_INPUT` and degrade safely.
7. **7 broken markdown links in `RECONSTRUCTION.md`** — bare `13b-trigger-descriptions.md`-style refs missing the `chapters/persistence/` prefix. Internal doc, low impact, but this is the file Claude is told to read first; sloppy refs erode trust. Patch them as part of any other RECONSTRUCTION edit.
8. **No `CONTRIBUTING.md`** despite the target folder structure listing one and the README having a Contributing section. Decide: write it, or delete the README mention.

**Validation before Phase 7 launches:**

9. **Clean-room install on a fresh VM/container.** Today's `--dry-run` passes on this machine, but this machine already has `~/.claude/`. Verify on a host with no prior state: clone → `./install.sh` → restart Claude Code → run both README verification queries → run `/onboard` → confirm profile file is created. Capture every divergence between README and reality, fold back into items 1–4.
10. **End-to-end personalization loop dry-run.** This is Phase 8e's scope and is the gate from 8 to 7: trigger `/suggest` during real work → capture entry → `/curate` → apply → entry moves to archive section. Then `/add-skill` → bucket INDEX updates → `op-bucket-router` matches and loads only the new file. If 8e ships this, item 10 is already done — keep it here as a checklist reminder.

---

## Critical context for cold-read sessions

- The plan file is canonical. This RECONSTRUCTION.md is the running state of executing that plan.
- The 4 existing `op-manual-*` skills are loaded in every Claude Code session today. The user already uses them. Don't break their triggers when renaming or expanding.
- "Auto mode" is active for the user — bias toward execution, ask only when genuinely blocked.
- Today's date: 2026-05-27. Always use absolute dates when updating progress.
