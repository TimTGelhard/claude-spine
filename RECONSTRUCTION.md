# Reconstruction State — v2 build history

**Architecturally frozen 2026-05-27 (v2 architecture shipped); pre-launch cleanup tracked below.** This file is the build history for the v2 reconstruction. The current-state entry points are [`README.md`](README.md) (what the project is) and [`FIXES.md`](FIXES.md) (open fix queue + pre-launch checklist); release-narrative lives in [`CHANGELOG.md`](CHANGELOG.md). Read this file only if you need the *why* behind a frozen architectural decision or the phase-by-phase audit trail. The post-freeze "Pre-launch cleanup" section near the end records housekeeping that landed after the architectural freeze. (The original pre-launch tracker `LAUNCH.md` was archived 2026-05-28 to [`docs/archive/LAUNCH-pre-1.0.md`](docs/archive/LAUNCH-pre-1.0.md) once its remaining items collapsed into the FIXES "Pre-launch checklist" section.)

---

## What v2 was

The manual was reconstructed from a private 18-chapter operating guide into a **public Claude Code toolbox** that anyone in the world can install. Three problems solved:

1. **Granularity** — v1 chapters clustered multiple concepts (one was 290 lines, several >200). v2 breaks them into ~80 atomic files (<150 lines each), one concept per file, organized by topic folder.
2. **Public-readiness** — founder-specific language (solo founder, Solvero, Dutch tradespeople, Next.js+Supabase opinions) was neutralized. Stack opinions live in an explicit `global/opinionated/` variant; defaults are `global/neutral/`.
3. **Sophisticated routing** — instead of Claude loading whole chapters, a layer of skills + an index router picks the right atomic file for the task. Claude reads only what it needs.

Plus two novel mechanics that shipped in Phase 8:
- **Personalization** — first-run interview (`op-onboard` skill) calibrates Claude to user experience level, stack, push-back intensity, verbosity. Writes `~/.claude/claude-spine-profile.md`.
- **Personal skill library (the "bucket")** — `bucket/` ships empty. Each user builds their own library over time via `op-add-skill`. Not a sharing mechanism — purely personal. A core skill `op-bucket-router` reads `bucket/INDEX.md` (auto-maintained), picks the right bucket skills for the current task, loads only those. Core skills age slowly (discipline); bucket skills can age fast (stacks/projects) without rotting the spine.

---

## Where things stand

Phases 0–8e + the pre-launch cleanup pass all shipped 2026-05-27 — see "Progress by phase" below for the table; the per-phase decision audit trail (Phases 2–6b) is archived at [`docs/archive/RECONSTRUCTION-phases-2026-05.md`](docs/archive/RECONSTRUCTION-phases-2026-05.md). Phase 7 (demo + public launch) was deferred to a dedicated tracker — originally `LAUNCH.md`, archived 2026-05-28 to [`docs/archive/LAUNCH-pre-1.0.md`](docs/archive/LAUNCH-pre-1.0.md) with the remaining items folded into [`FIXES.md`](FIXES.md) under "Pre-launch checklist." Post-Phase-8 follow-on work (L9b cleanup, the L10 ambient-workflow refactor + L10.1 legacy-command removal, the onboarding subscription-awareness expansion) shipped after the Phase 8 freeze and is recorded in [`CHANGELOG.md`](CHANGELOG.md) under `[0.10.0]` and `[0.11.0]`; the L10 planning doc is archived at [`docs/archive/PLAN-AMBIENT-WORKFLOW-2026-05.md`](docs/archive/PLAN-AMBIENT-WORKFLOW-2026-05.md).

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
- **Skill body cap:** 65 lines (revised 2026-05-27, pre-launch cleanup). Originally 40, raised to 55 in Phase 6c, raised to 65 during pre-launch cleanup to give workflow-encoding skills (`op-suggest`, `op-curate`) the room their apply-step sequences need. Pure-index skills still land at 34–50; workflow-encoding skills land at 55–60. None of the 18 core skills have crossed into content territory — the cap exists to keep skills as *routers*, not content. When a router (not a workflow encoder) needs more than the cap, the extra material is operational data and should move to an adjacent file in the skill folder (`op-onboard` is the reference pattern: SKILL.md routes to `questions-essential.md` / `questions-deep.md` / `profile-template.md`, all loaded on-demand).
- **Atomic file sizing:** sized to the concept, not a number. The original v2 pass had a 150-line ceiling as a *heuristic* to force decomposition on real seams; in practice most chapters landed in the 40–145 range because most concepts are genuinely concise. The discipline is "one concept per file, lean but complete, every line earns its keep" — not "stay under N lines." If a concept genuinely needs 200 lines to be complete, write 200. If you're tempted to truncate to fit a number, the truncation is the bug. If you're tempted to pad to feel substantial, the padding is the bug. The decomposition rule above tells you when to split; the size of any one file is whatever the concept needs.
- **Naming (locked 2026-05-27):** the public name is **`claude-spine`**. Tagline: "The spine of every Claude Code project." Local folder, GitHub repo, all internal references rename together in Phase 6. Current folder `claude-op-manual` and remote `claude-code-operators-manual` are both pre-rename names — don't update them yet.
- **Onboarding mechanic (re-locked 2026-05-27):** both mechanisms — `op-onboard` auto-fires when no profile file exists; `/onboard` slash command re-runs / edits the profile. **Decision (Phase 6c):** hybrid surface — **6 essentials up front** (~2 min), opt-in `--deep` for ~11 more grouped follow-ups. The "25-question wall" originally feared in this section was the right thing to fear; the deep pass is therefore opt-in. Captured dimensions (designed in Phase 6):
  - **Developer profile** — years of experience, self-assessed level, comfort areas
  - **Stack preferences** — primary, secondary, "avoid," version pinning where it matters
  - **Project context** — typical project types, solo vs team, production user scale, time pressure
  - **Working style** — verbosity, push-back intensity, mentor vs peer tone, signal preferences (context-filling, scope-creep, drift, verification gaps)
  - **Output format** — diffs vs full files, commenting density, emoji policy, diagram style
  - **Risk + safety** — production-app strictness, version-control hygiene, command-execution tolerance

  Profile written to `~/.claude/claude-spine-profile.md` (the original draft used `~/.claude/op-manual-profile.md`; renamed during Phase 6c with the project rename to `claude-spine`). Global CLAUDE.md references it; Claude reads it every session.
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

## Phase-by-phase build notes — archived

Per-phase decisions and audit trail (Phases 2–6b, written 2026-05-27 during the v2 reconstruction) archived 2026-05-28 to [`docs/archive/RECONSTRUCTION-phases-2026-05.md`](docs/archive/RECONSTRUCTION-phases-2026-05.md). Read there for the *why* behind a specific phase's decisions.

---

## Pre-launch cleanup (after Phase 8 done, before Phase 7)

Captured 2026-05-27 from a ship-readiness audit. **Status as of 2026-05-27 cleanup pass:** items 1–8 landed in one commit; items 9 + 10 are validation, not edits.

**Doc lies (highest priority — these break first-touch trust):**

1. ✅ **README skill count: "14 op-* skills" → "18".** Done 2026-05-27. Five mentions swept (banner, "What you get" bullet, "First session" verify step, "How it works" section, folder-tree comment).
2. ✅ **README v2 status banner rewritten.** Done 2026-05-27. Now reads "v2 reconstruction nearing completion — pre-launch cleanup in flight; Phase 7 next."
3. ✅ **`INDEX.md` header updated.** Done 2026-05-27. Status line now reflects every atomic file written + personalization rows shipped.
4. ✅ **Root v1/v2 duplication resolved.** Done 2026-05-27. **Decision: deprecation header.** Each of the 18 root `NN-*.md` files now carries a `> DEPRECATED — v1 single-file chapter` block at the top pointing at `chapters/<topic>/`. Body preserved for cross-reference. Rejected: `git mv archive/` (breaks any external link), `git rm` (lossy at path level). README + INDEX swept to match.

**Code/infra:**

5. ✅ **Skill cap raised to 65 (was 55).** Done 2026-05-27. Architecture section updated with rationale: workflow-encoding skills (`op-suggest`, `op-curate`) land at 55–60 because the apply-step sequence IS the routing — nothing to extract to an adjacent file. Pure-index skills still 34–50.
6. ✅ **`install.sh` jq fail-fast.** Done 2026-05-27. Preflight check exits non-zero if `jq` is missing and `--skip-hook` is not set. Redundant in-hook WARNING removed. Tested with `--dry-run`.
7. ✅ **"Broken links in RECONSTRUCTION.md" — confirmed non-existent.** On inspection, the 3 bare-style refs are *intentional descriptive examples inside backticks* (lines 369, 469, 477) showing the cross-link convention; they render as code, not navigation. The "7" count was an audit miscount. No edits needed.
8. ✅ **`CONTRIBUTING.md` written.** Done 2026-05-27. ~45 lines: what's welcome / unlikely / how to propose / commit style. README's Contributing section points at it.

**Validation before Phase 7 launches:**

9. ⏳ **Clean-room install on a fresh VM/container.** Still open. Today's `--dry-run` passes on this machine, but this machine already has `~/.claude/`. Verify on a host with no prior state: clone → `./install.sh` → restart Claude Code → run both README verification queries → run `/onboard` → confirm profile file is created. Capture every divergence between README and reality. This is Phase 7's pre-launch gate, not an edit.
10. ✅ **End-to-end personalization loop dry-run.** Done in Phase 8e (on-paper). See Phase 8e notes for the seam-walk result + the empty-state placeholder fix.

---

## Post-Phase-8 planning docs — archived

- **L10 ambient workflow refactor** (`op-spine-active` + Stop-hook writeback + `/done`): planning doc archived to [`docs/archive/PLAN-AMBIENT-WORKFLOW-2026-05.md`](docs/archive/PLAN-AMBIENT-WORKFLOW-2026-05.md). Shipped as the L10 + L10.1 entries in `CHANGELOG.md` `[0.10.0]`. The live mechanics live in `skills/core/op-spine-active/`, `global/hooks/spine-writeback.sh`, `global/commands/done.md`, and `chapters/workflow/05j-cold-start-protocol.md`.
- **First internal janitor pass** (pre-launch sweep, 2026-05-27): archived to [`docs/archive/JANITOR-2026-05.md`](docs/archive/JANITOR-2026-05.md). Current drift catalog moved to [`FIXES.md`](FIXES.md) at repo root.

---

## Critical context for cold-read sessions

- The plan file is canonical. This RECONSTRUCTION.md is the running state of executing that plan.
- The 4 existing `op-manual-*` skills are loaded in every Claude Code session today. The user already uses them. Don't break their triggers when renaming or expanding.
- "Auto mode" is active for the user — bias toward execution, ask only when genuinely blocked.
- Today's date: 2026-05-27. Always use absolute dates when updating progress.
