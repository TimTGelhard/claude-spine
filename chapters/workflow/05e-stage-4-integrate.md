# 05e — Stage 4: Integrate

Run an integration session every 3–5 features. Don't let features pile up un-integrated.

## What an integration session does

- Walk the full user journey, not just the most recent feature.
- Test the boundaries between features — does login → dashboard → settings actually flow?
- Re-run the smoke tests in `SMOKE_TESTS.md`.
- Catch regressions early.

A feature can pass its own smoke test and still break the seam where it meets another feature. That's what this stage is for.

## What to do with regressions

If you find regressions, fix them in a **dedicated session** — don't bundle with the next feature. One bug per change. The fix is cleaner, the diff is smaller, the next feature doesn't inherit the noise.

Note the regression in `PROGRESS.md` before fixing — it's a useful trail when patterns repeat.

## Why this stage matters

Feature-by-feature development is fast but locally optimized. Each session sees one slice of the app. Integration is the only time anyone (including Claude) looks at the *whole thing* working.

Skipping this means discovering broken seams at Stage 5 or Stage 6 — when the cost of fixing them is highest.

## Cadence

Rule of thumb: every 3–5 features, or any time you've made a change that affects shared state (auth, routing, layout, the database).

For a 20-feature MVP, expect 4–6 integration sessions across the project.

## TL;DR

- Every 3–5 features, walk the full app, not just the latest slice.
- Regressions get their own session — don't bundle.
- This stage is cheap; the bugs it catches are expensive later.
