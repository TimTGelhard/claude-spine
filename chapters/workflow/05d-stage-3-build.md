# 05d — Stage 3: Build

The bulk of the project. **One feature per session, fresh terminal each time.** See [06-feature-sizing.md](06-feature-sizing.md) for how to size "one feature."

## Per-session ritual

1. **Orient** — "Read CLAUDE.md, ARCHITECTURE.md, PROGRESS.md, and these files: [list]. Tell me what we're doing this session."
2. **Confirm scope** — "We're building X. Not building Y or Z. Agree?"
3. **Plan** — Claude proposes the approach (plan mode for non-trivial features). You approve or push back.
4. **Build** — actual edits, in small commits where possible.
5. **Verify** — run the app, walk the smoke list for this feature, hit the API for real.
6. **Update `PROGRESS.md`** — what's done, what's next, what's blocked.
7. **Commit + push.**

If at any point Claude contradicts itself or you've corrected the same misunderstanding twice → restart the session. See [02-context-budget.md](../foundations/02-context-budget.md).

## Plan mode vs straight-to-code

Use plan mode when:
- The feature touches >5 files or >2 layers.
- There's a security boundary involved (auth, payments, PII).
- You're not sure of the right approach.

Skip plan mode for:
- Single-file bug fixes.
- Mechanical tweaks (copy, color, one-line fix).

See [04b-plan-and-fast-mode.md](../foundations/04b-plan-and-fast-mode.md).

## Claude's signaling responsibilities

The user shouldn't have to be the one tracking these — that's Claude's job as the senior dev in the room. Signal proactively at these checkpoints:

- **Mid-session if context fills** → flag the yellow-zone crossing, recommend wrapping after the current task.
- **When scope creeps** (8+ files, 4+ decisions, or the ask grew) → flag and offer to split.
- **When drift appears** (re-suggesting ruled-out ideas, repeated misunderstanding) → flag and recommend restart.
- **Before declaring done** → name the missing verification (run the app, walk the smoke list, two-session RLS for auth changes).
- **At natural stopping points** → prompt to commit + update `PROGRESS.md` / `DECISIONS.md` / `FEATURES.md`.

These are recommendations, not refusals — the user can always say "continue anyway." But proactive signaling is the difference between a senior dev and an order-taker. Full detail in [11-proactive-signaling.md](../../11-proactive-signaling.md).

## End-of-session updates

Don't close the terminal without:
- `PROGRESS.md` reflecting what shipped, what's next, what's blocked.
- `DECISIONS.md` updated if you made an architectural call.
- `FEATURES.md` updated if a new feature became visible.

Persistence > re-derivation next session.

## Common failure modes

- **Skipping orientation.** Claude builds on assumptions you didn't catch.
- **Skipping the verify step.** "It compiled" is not "it works." See [01b-three-levers.md](../foundations/01b-three-levers.md), Lever 3.
- **Bundling a refactor with the feature.** One bug per change. Note the cleanup, do it in a separate session.
- **Not updating PROGRESS.md.** Next session starts cold and re-derives state.

## TL;DR

- One session = one feature, fresh terminal.
- Orient → confirm scope → plan → build → verify → commit → update docs.
- Claude signals proactively at the five checkpoints — context, scope, drift, verification, stopping points.
