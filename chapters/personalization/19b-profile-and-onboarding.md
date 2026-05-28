# 19b — Profile and onboarding

The profile file is what makes the spine personal *to you*. It's not the loop — that's [19c](19c-suggestion-loop.md) and [19d](19d-curation-session.md). It's the static calibration: who you are, how you want to be talked to, what you're working on. Written once on first run, refreshed when something changes.

## Where the profile lives

`~/.claude/claude-spine-profile.md` — **outside** the spine repo, in your home `.claude/` directory. This is deliberate:

- Survives reinstalls and `git pull`s of the spine.
- Won't get accidentally committed back upstream.
- Lives next to the rest of your Claude Code config — same place as your global `CLAUDE.md` stub.

The global stub (installed by `install.sh`) points Claude at the profile every session. Same load semantics as global CLAUDE.md — small, always-on.

## What the profile captures

Nine fixed sections, machine-parseable structure (don't rename headings):

| Section | What goes here |
|---|---|
| **Subscription** | Claude plan, typical daily usage, cost sensitivity |
| **Developer profile** | Experience level, years coding, comfort areas, lean-in areas |
| **Stack preferences** | Primary stack (product-shape family), secondary, what to avoid |
| **Environment** | OS, VCS host (GitHub / GitLab / Bitbucket / etc.), plans-dir layout, currency hint |
| **Project context** | Typical project type, artifact shape (app / service / library / data), team size, user scale, org shape |
| **Working style** | Push-back intensity, answer length, reasoning depth, active proactive-signal preferences, typical session shape |
| **Output format** | Code presentation (diffs vs full files), comments / emoji policy |
| **Risk + safety** | Command-execution tolerance (ask vs run) |
| **Spine defaults** | User-overridable thresholds + cue phrases for bucket nudges, stale review, planning, and the writeback hook |

Plus an optional **Notes** section for free-text the user added.

Strict structure so future tooling can read the file. Hand-editing is fine — it's markdown — but keep the headings as-is. Full template at `~/.claude-spine/skills/core/op-onboard/profile-template.md`.

## Two-tier interview

The whole point of the hybrid model is to not scare new users with a 28-question wall while still letting committed users get a fully-loaded profile from day 1.

**Essentials (10 questions, default first-run):**

1. Claude subscription
2. Experience level
3. Primary stack
4. Push-back intensity
5. Answer length (terse / standard / verbose)
6. Reasoning depth (just the answer / show the path / teach me the why)
7. Typical project type
8. Operating system (macOS / Linux / WSL / Windows native / Other)
9. VCS host (GitHub / GitLab / Bitbucket / None / Other)
10. Artifact shape (app / service or CLI / library / data or ML / Other)

Captured up front, written immediately. The deep section headings are still in the file with `(unfilled — run /onboard --deep to capture)` under each, so you can see what's missing.

**Deep (18 more questions, opt-in):**

Daily Claude usage and cost sensitivity, comfort/lean-in areas, secondary stack and avoid list, team/scale context, active signal preferences, output format details, risk tolerance, plus the new Section G/H pass (typical session shape, plans-dir location, bucket-loop opt-in, team/org shape, currency hint), and an optional free-text notes follow-up. Branches off the essentials — won't repeat questions you already answered.

**Hook tuning (2 opt-in prompts at the end of deep, writes to settings.json — not the profile):**

After the deep questions are saved, `op-onboard` offers two PostToolUse hooks that ship default-off:

- **Auto-typecheck after edits.** Runs `tsc --noEmit` on `.ts`/`.tsx` and `python -m py_compile` on `.py` after each edit. Errors surface in the next turn; the hook never blocks the edit.
- **Auto-format after edits.** Runs Prettier / Black / gofmt / rustfmt on edited files when the project has that formatter configured. Silent when not.

Both are opt-in only via `/onboard --deep`; default-off otherwise. Each adds one PostToolUse entry to `~/.claude/settings.json` under matcher `Edit|Write|MultiEdit`. To remove, hand-edit `settings.json`. See chapter [14b](../persistence/14b-hook-recipes.md) for the underlying hook recipes and `op-onboard`'s `## Hook tuning (deep mode only)` for the exact writeback flow.

## How to run it

| Trigger | Behavior |
|---|---|
| Profile file missing | `op-welcome` emits a one-block greeting pointing the user at `/onboard`. `op-onboard` does **not** auto-launch the interview. |
| `/onboard` (no profile) | Runs essentials; offers deep at the end |
| `/onboard` (profile present) | Re-runs essentials only; shows current values, asks which to change |
| `/onboard --deep` | Runs the 18 deep questions (after essentials if profile is missing), then 2 opt-in hook prompts |
| "Change my push-back to spar with me" | Direct edit to the matching section; no interview |
| Hand-editing the file | Always fine — plain markdown, strict structure |

The interview itself is one question at a time via `AskUserQuestion`. Each question has 2–4 pre-defined options plus auto-"Other" for free-text. No prose dumps, no wall-of-text.

## When to re-run

Re-run `/onboard` when something about *you* shifts:

- Your push-back, answer-length, or reasoning-depth preferences feel wrong in practice (you keep correcting Claude in the same direction).
- You moved primary stacks (Next.js → Rails, say).
- You moved domains (apps → ML; freelance → in-house).
- Your project type shifted (MVPs → maintaining production at scale).
- You changed Claude subscription (Pro → Max 20×, say) — `/onboard` re-proposes the matching `settings.json` tune.

Don't re-run for one-session noise. The profile is meant to last across all of your projects long-term — that's why the upfront cost of the deep interview is justified.

## What the profile doesn't do

- **Doesn't replace the bucket.** Profile is *who you are*. Bucket is *what you've added* (skills, chapters, conventions). Different layers, see [19a](19a-overview.md).
- **Doesn't evolve via the suggestion loop.** `op-suggest` and `op-curate` never modify the profile. Profile changes flow through `/onboard` only. (Open question — see PERSONALIZATION.md — whether observed working-style drift should ever surface as a profile-update suggestion. Current answer: no.)
- **Doesn't capture project-specific context.** Project conventions go in `.claude/CLAUDE.md` per project, or in `bucket/chapters/` if they're patterns spanning multiple projects. Profile is universal-to-you, not project-specific.
- **Doesn't capture secrets.** No client names, addresses, keys, tokens. Working-style only.

## Override hierarchy

Your global CLAUDE.md stub references the profile. Your project CLAUDE.md can still override. The hierarchy (most → least specific):

1. Project `.claude/CLAUDE.md`
2. Global stub + profile (`~/.claude/CLAUDE.md` + `~/.claude/claude-spine-profile.md`)
3. Atomic chapters in the spine (loaded on-demand by core skills)

More specific wins. Security rules apply at every level — the profile cannot weaken them.

## TL;DR

- Profile lives at `~/.claude/claude-spine-profile.md`, outside the spine, survives reinstalls.
- Seven fixed sections, machine-parseable; hand-editing fine, don't rename headings.
- Essentials first run (10 Qs), deep opt-in (18 more + 2 opt-in hook prompts that touch settings.json, not the profile), re-runnable via `/onboard` and `/onboard --deep`.
- `op-welcome` owns the first-run greeting; `op-onboard` runs the interview only on explicit invocation.
- Re-run when something about *you* shifts long-term. Don't re-run for session-level noise.
- Profile is who-you-are; the bucket is what-you've-added. The suggestion loop doesn't touch the profile.
