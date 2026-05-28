# 18b — Session / scope anti-patterns

How you bound a session determines whether the work converges. Each entry: the anti-pattern, why it fails, what to do instead.

## "I'll do auth + a feature using auth in one session"

**Fails because:** you can't tell if a bug is in auth or the feature.
**Instead:** auth first, verify, commit. Feature after.

## Building + writing docs / tests for unrelated code in same session

**Fails because:** divided attention, both halves worse.
**Instead:** one focus per session.

## Bundling a bug fix with a refactor

**Fails because:** if it breaks, you don't know which half caused it.
**Instead:** fix the bug, commit. Refactor in a separate session, commit. One bug per change.

## Trying to do the whole app in one session

**Fails because:** context fills, decisions multiply, drift sets in.
**Instead:** one session = one cohesive goal. For plan-driven feature work, that's typically one feature. For debug / explore / refactor / read-and-explain sessions, substitute "one investigation" / "one hypothesis" / "one cleanup goal" / "one orientation." See [06-feature-sizing.md](../workflow/06-feature-sizing.md).

## Carrying a long session forward "because I'm in flow"

**Fails because:** flow ≠ quality. Long sessions degrade silently.
**Instead:** commit at natural breakpoints. Fresh terminal after. The 1M context window is for going *deep* on one slice, not *wide* across many.

## Skipping the orientation prompt to "save time"

**Fails because:** every bad assumption from missing context costs more time than the orientation would.
**Instead:** 5K–30K tokens of orientation, every session. See [08a-discovery-sequence.md](../workflow/08a-discovery-sequence.md).

## TL;DR

Scope creep is the dominant failure of intermediate users. The fix is mechanical: one cohesive goal per session, one bug per commit, commit at natural breakpoints, fresh terminal after. If the work won't fit, the work needs splitting — not a longer session. Note: "one cohesive goal" is the universal rule; "one feature per session" is its plan-driven feature-build variant — useful, but not the only valid shape.
