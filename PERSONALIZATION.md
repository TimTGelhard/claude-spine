# Personalization + Self-Evolution Plan

**Status:** planning — not started. Execution begins in Phase 8 after Phases 3–6.5 land.

**If you're a Claude session reading this cold:** read `RECONSTRUCTION.md` first for the v2 reconstruction state, then this file. This document plans the *personalization and self-evolution loop* that sits on top of the v2 architecture.

---

## Vision

`claude-spine` ships as a static toolbox. After install, it becomes a **personal, evolving** companion:

- **First run** calibrates Claude to *who you are* (existing Phase 6 — `op-onboard`).
- **Every session** Claude watches for friction and high-signal moments, capturing them as **pending suggestions** in a queue.
- **Periodic curation sessions** turn approved suggestions into new bucket skills or personal chapters.
- **As your work shifts** (apps → ML → websites), the bucket re-shapes itself; the core spine doesn't.

The user feels the toolkit grow with them. The maintainer (us) can still ship upstream upgrades cleanly because the core is never touched per-user.

---

## Architecture — three layers

| Layer | What it holds | Mutability | Owner |
|---|---|---|---|
| **Core spine** (`chapters/`, `skills/core/`) | Universal patterns, atomic chapters, core skills | **Read-only** per user. Pulled from upstream. | Repo maintainers |
| **Profile** (`~/.claude/claude-spine-profile.md`) | Who the user is — experience, stack, working style, tone preferences | Updated by `op-onboard` only | User (via onboarding) |
| **Bucket** (`bucket/`) | Personal skills, personal chapters, pending suggestions, bucket INDEX | **Append-mostly**, curated via dedicated sessions | User (with Claude proposing) |

Upgrade path: `git pull` updates core spine. Bucket and profile are untouched. No merge conflicts, ever.

---

## Folder structure (final)

Adjusts the existing Phase 6.5 plan: bucket promoted to top-level instead of nested under `skills/`. Cleaner semantics — the bucket holds more than skills now.

```
claude-spine/
├── chapters/                       # CORE — read-only
│   ├── foundations/
│   ├── workflow/
│   ├── ...
│   └── personalization/            # NEW — explains the loop to users
│       ├── 19a-overview.md
│       ├── 19b-profile-and-onboarding.md
│       ├── 19c-suggestion-loop.md
│       ├── 19d-curation-session.md
│       └── 19e-extending-the-bucket.md
├── skills/
│   └── core/                       # CORE — read-only, includes new skills below
├── bucket/                         # PERSONAL — was skills/bucket/
│   ├── INDEX.md                    # auto-maintained — routes Claude to the right bucket file
│   ├── SUGGESTIONS.md              # pending proposals from Claude (status-tracked)
│   ├── CHANGELOG.md                # what got added/modified, when
│   ├── skills/                     # personal skills (was skills/bucket/)
│   └── chapters/                   # personal/auto-gen chapters
├── templates/
└── global/
```

Profile lives outside the repo at `~/.claude/claude-spine-profile.md` so it persists across reinstalls and isn't accidentally committed.

---

## The loop

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                   │
│   normal session                  curation session                │
│   ───────────────                 ──────────────────              │
│                                                                   │
│   user works on a feature         user runs /curate               │
│        │                              │                           │
│        ▼                              ▼                           │
│   Claude observes friction       Claude reads SUGGESTIONS.md      │
│   / explicit user signal              │                           │
│        │                              ▼                           │
│        ▼                          for each pending:               │
│   high-threshold check                │                           │
│   passes?                             ▼                           │
│        │                          read affected bucket files +    │
│        ▼                          INDEX (prevent duplication)     │
│   op-suggest logs entry               │                           │
│   to bucket/SUGGESTIONS.md            ▼                           │
│        │                          propose diff to user            │
│        ▼                              │                           │
│   ─ user keeps working ─              ▼                           │
│                                   user approves?                  │
│                                       │                           │
│                                       ▼                           │
│                                   apply, update INDEX,            │
│                                   append CHANGELOG,               │
│                                   mark suggestion done            │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

### Capture (during normal work)

**Trigger conditions for `op-suggest` (high threshold — speculative additions are banned by chapter 13/18):**

- User explicitly says: "we should add this to the manual" / "remember this" / "next time…"
- Same friction observed 2+ times in this session (Claude corrected on the same pattern twice)
- End-of-session reflection: user closes with "what did we learn here?" or natural stopping point
- User runs `/suggest` slash command manually

**Never trigger on:** speculation ("it'd be cool if…"), one-off frictions, mid-task ideation, anything Claude noticed without user confirmation.

**Entry format in `SUGGESTIONS.md`:**

```markdown
## [2026-MM-DD] short title
- **Type:** new-skill | new-chapter | profile-update | observation
- **Trigger:** [what made me propose this — quote the user or describe the repeated friction]
- **Proposed change:** [concrete description; if it's a chapter or skill, where it would live]
- **Status:** pending
```

### Curation (`/curate` session)

1. Claude reads `bucket/SUGGESTIONS.md` (only `status: pending` entries).
2. For each entry, Claude **must** read:
   - The relevant existing bucket files (skills or chapters that overlap)
   - `bucket/INDEX.md` (to check for overlap with existing entries)
3. Claude proposes a diff or a new file to the user — one at a time.
4. User approves / rejects / edits.
5. On approve: Claude writes the file, updates `bucket/INDEX.md`, appends to `bucket/CHANGELOG.md`, marks the suggestion `status: applied`.
6. On reject: marks `status: rejected`. Stays in file for audit; not re-proposed.

**Hard rules baked into the curation skill:**
- Never modify `chapters/` or `skills/core/`. Hard refusal if asked.
- Never write a new bucket file without reading the existing INDEX first.
- Never apply more than one change without explicit user approval per change.
- Profile updates are out of scope — those go through `/onboard --deep`.

---

## Skill inventory

**New skills added in Phase 8:**

| Skill | Purpose | Triggers |
|---|---|---|
| `op-suggest` | Captures high-signal suggestions to `bucket/SUGGESTIONS.md` | User says "we should add this," repeated friction (2+), end-of-session reflection, `/suggest` slash command |
| `op-curate` | Runs the curation session — reads queue, proposes diffs, applies on approval | `/curate` slash command; or Claude proposes when 5+ pending entries exist |

**Existing skills that need light integration:**

| Skill | Change |
|---|---|
| `op-bucket-router` (Phase 6.5) | Already routes to `bucket/skills/INDEX.md`. Extend to also route to `bucket/chapters/INDEX.md` (or unified `bucket/INDEX.md` covering both). |
| `op-add-skill` (Phase 6.5) | Already auto-maintains the bucket INDEX. Curation uses the same INDEX-maintenance code path. |
| `op-onboard` (Phase 6) | Handles profile creation + re-run via `/onboard`. No change to scope — profile evolution stays separate from the suggestion loop. |

---

## Multi-session execution plan

This is too much for one session. Five execution sessions after this planning session.

### Session A — chapter content + folder structure (Phase 8a)

- Create `chapters/personalization/` with the five atomic files (19a–19e).
- Lift `skills/bucket/` → `bucket/` at repo root (only if Phase 6.5 hasn't shipped yet; otherwise migrate).
- Add `bucket/chapters/` and `bucket/SUGGESTIONS.md` + `bucket/CHANGELOG.md` skeleton files.
- Update `INDEX.md` to list the personalization section.
- Update `RECONSTRUCTION.md`: flip Phase 8 to in-progress, atomic-file map.

**Deliverable:** the manual *describes* personalization. No skills yet.

### Session B — capture skill (Phase 8b)

- Write `skills/core/op-suggest/SKILL.md`.
- Lock the high-threshold trigger description (this is the most failure-prone surface — bloat here means noise everywhere).
- Define `SUGGESTIONS.md` entry schema; pin in the skill body.
- Add `/suggest` slash command as a manual entry point.
- Dry-run: simulate three friction patterns + one explicit user "remember this" — verify only the right ones get logged.

**Deliverable:** Claude can capture suggestions cleanly during normal work.

### Session C — curation skill (Phase 8c)

- Write `skills/core/op-curate/SKILL.md`.
- Implement the read-before-write enforcement (skill body lists the exact reads required before any proposal).
- Diff-preview pattern (Claude must show a unified diff before writing).
- INDEX + CHANGELOG maintenance code path.
- Add `/curate` slash command.

**Deliverable:** the full loop is functional — capture during work, curate on demand.

### Session D — integration + edge cases (Phase 8d)

- Wire `op-bucket-router` to discover `bucket/chapters/` (not just skills).
- Decide: unified `bucket/INDEX.md` vs split `bucket/skills/INDEX.md` + `bucket/chapters/INDEX.md`. Open question for the execution session.
- Garbage-collection story: stale bucket entries from abandoned project types. Probably manual via `/curate --review-stale`, not automatic.
- "Project shift" detection: how does Claude know the user moved from apps to ML? Probably explicit `/onboard --deep` rather than auto-detect.

**Deliverable:** full personalization mechanic, integrated.

### Session E — dry-run + launch readiness (Phase 8e)

- End-to-end dry-run: simulate a 10-session arc (mixed app + ML work). Verify SUGGESTIONS.md fills sensibly, curation produces non-duplicate non-bloated entries, the bucket actually helps in later sessions.
- Tune trigger thresholds based on dry-run results.
- Update `RECONSTRUCTION.md` Phase 8 to done.
- Add a section to README explaining personalization for new users.

**Deliverable:** Phase 8 done. Ready for v1 launch (Phase 7).

---

## Locked decisions

- **Overlay-only model.** Core spine is never modified per user. (Confirmed 2026-05-27.)
- **Bucket promoted to top-level `bucket/`** (containing `skills/`, `chapters/`, `SUGGESTIONS.md`, `CHANGELOG.md`, `INDEX.md`). Adjusts Phase 6.5 plan slightly — bucket is no longer just for skills.
- **High threshold for suggestion capture.** Only on explicit user signals or repeated friction. The same speculative-addition rule that governs the core spine (chapter 13/18) applies to the personalization loop *itself*.
- **Curation is a dedicated session**, separate from normal work. Triggered by user or by Claude proposing when N+ pending entries exist.
- **Read-before-write is hard-enforced** in `op-curate`. No file proposed without reading the bucket INDEX + affected files first.
- **Profile evolution is separate from chapter/skill evolution.** Profile updates flow through `op-onboard` / `/onboard --deep`. The suggestion loop never modifies the profile.
- **Append-only by default.** Personal chapters/skills are new files. Modifications to existing bucket entries are allowed but flagged in curation.

---

## Open questions (decide during execution)

- **Unified vs split bucket INDEX.** One `bucket/INDEX.md` covering both skills and chapters, or two separate INDEX files? (Session D.)
- **Trigger threshold tuning.** Is "same friction 2x" too loose? Too tight? Decide after Session E dry-run.
- **Auto-propose curation.** Does Claude proactively suggest running `/curate` when there are N+ pending entries? If yes, what N? (Probably 5; revisit after dry-run.)
- **Stale-entry garbage collection.** Bucket chapters from abandoned project types — manual review via `/curate --review-stale`, auto-archive after X months, or never auto-touch? (Session D.)
- **Project shift detection.** Auto-detect when the user's work changes domains, or require explicit `/onboard --deep`? Probably explicit. (Session D.)
- **SUGGESTIONS.md ordering.** Append-only chronological, or grouped by type? Append-only is simpler and audit-friendly; group during curation. (Session B.)
- **Profile-affecting suggestions.** If Claude observes a working-style drift ("user now prefers terser responses than profile says"), does it log a `profile-update` suggestion? Or is profile only changed via onboarding? (Session B.)

---

## Risks + mitigations

| Risk | Mitigation |
|---|---|
| **Suggestion spam** — Claude logs constantly, SUGGESTIONS.md becomes a noisy graveyard | High-threshold trigger description in `op-suggest`. Reject one-off friction. User pruning during curation. |
| **Bucket bloat** — personal chapters multiply, INDEX gets unwieldy | INDEX cap (Phase 6.5 already plans for it). Stale-entry GC in `/curate --review-stale`. Atomic-file <150 line cap applies to bucket chapters too. |
| **Duplicate entries** — Claude proposes a chapter that overlaps with existing bucket content | Read-before-write enforcement in `op-curate`. Diff preview makes overlap visible to the user. |
| **Core spine drift via stealth modification** — Claude writes to `chapters/` despite the rule | Hard refusal coded into `op-curate` skill body. Optional: settings.json hook to block writes to `chapters/` and `skills/core/` outside of upstream pulls. |
| **Personalization becomes a feature creep target** — users want more loops, more sessions, more skills | The chapter 13/18 anti-patterns apply to the personalization mechanic itself. Phase 8 ships with the loop documented here, no more. Future extensions need their own justification. |
| **Profile/bucket get out of sync** with the user's actual current work | `/onboard --deep` re-runs the interview. Curation surfaces stale-feeling entries. User retains full control to delete or edit anything in `bucket/`. |

---

## Why this is the right shape

- **One spine, many personal layers.** The maintainer can ship upgrades forever. The user never feels constrained.
- **Same routing pattern everywhere.** Core chapters → INDEX. Bucket skills + chapters → bucket INDEX. One mental model for both.
- **Same skill pattern everywhere.** `op-*` skills route, ~40-line bodies, content lives in atomic files. Personalization skills are no exception.
- **The loop respects the manual's own principles.** Reviewer-mode-first (diff preview + approval), no speculative additions (high threshold), one feature per session (curation is its own session type), verification before "done" (read-before-write).
- **Self-evolution is bounded.** The manual doesn't grow infinitely or arbitrarily. It grows through a small number of well-defined hooks, with the user as final approver. The "spine" stays a spine.

---

## When to revisit this plan

- After Session A (Phase 8a) — chapter writing may surface design gaps not visible from this plan.
- After Session E (Phase 8e) — dry-run may show the loop is too noisy, too quiet, or producing wrong outputs. Tune trigger thresholds and the curation flow.
- After v1 launch — real users will reveal behaviors this plan can't predict. Treat v1 personalization as a hypothesis; v2 refines it.
