# 11d — Verification gates and end-of-session signals

Two related categories. Both fire when work is "done by the code" but not yet "done by reality."

Foundation: [11-overview.md](11-overview.md). Why verification matters: [01b-three-levers.md](../foundations/01b-three-levers.md) (the verification lever). Stage-5 hardening: [05f-stage-5-harden.md](../workflow/05f-stage-5-harden.md).

## Verification-gate triggers

| Trigger | Signal |
|---|---|
| Code change touches auth, RLS, or any user-data boundary | "Auth-touching change. Recommend two-session RLS check before commit — won't claim done until that's run." |
| UI change without running in browser | "Built but not run. Want me to start the dev server and walk it, or are you doing it?" |
| API/server logic without hitting it | "Route compiled, but not exercised. Recommend curl or UI flow before declaring done." |
| Migration without applying | "Migration written but not applied locally. Apply and verify schema before commit." |
| Cross-platform change (iOS+Android, light+dark) | "Need to verify on both <platforms>. Which do you have at hand?" |

The rule under all of these: **"it compiled" is not "it works."**

## End-of-session triggers

| Trigger | Signal |
|---|---|
| Natural unit of work completed | "Natural stopping point. Before continuing, recommend: commit + update PROGRESS.md." |
| Decision made that future sessions need | "This is a non-obvious choice. Worth adding to DECISIONS.md so next session knows the rationale." |
| New feature discovered mid-build | "Just discovered <thing>. Adding to FEATURES.md, not building this session." |
| Session has gone >90 min on one feature | "We've been on this for a while without verification. Recommend running the smoke list now to catch drift early." |

These signals are how a feature *closes*. A session without an end-of-session signal usually leaves orphaned context for next session to discover.

## What "done" looks like

A feature is genuinely done when:

1. The code is written.
2. The code has been **run** in the relevant environment.
3. The golden path works end-to-end.
4. At least one failure mode has been exercised (empty input, network down, unauthorized user).
5. The relevant project docs (PROGRESS, DECISIONS, FEATURES) reflect the change.

If any of those is missing, the verification signal should fire before you declare done.

## TL;DR

- Five verification triggers — none of them are "did it compile."
- Four end-of-session triggers — they close the loop on what next session needs.
- "Done" is a five-step check, not a successful build.
