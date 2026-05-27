> **DEPRECATED** — v2 location: [`chapters/workflow/06-feature-sizing.md`](../../chapters/workflow/06-feature-sizing.md). Full v1→v2 map: [`V1-CHAPTERS-DEPRECATED.md`](../../V1-CHAPTERS-DEPRECATED.md). Body kept for cross-reference.

# 06 — Feature sizing: how much fits in one session

The core rule: **one session = one feature.** Not one app, not five small features, not "the whole dashboard." Pick a slice, do it, ship it, start fresh.

## What "one feature" means

A feature is a vertical slice that touches all layers (UI → API → DB) and delivers user-visible value or completes a clear technical objective.

Examples of a single feature:
- "User can sign up with email + Google."
- "Quotes page lists quotes, supports filtering by status, paginated."
- "Webhook receives Stripe events and updates `subscriptions` table."
- "Build the public landing page (hero, features, pricing, footer)."

Examples of *more than* one feature (split these):
- "Build auth + onboarding + dashboard." → 3 sessions, minimum.
- "Add Stripe billing." → split into: webhook handling, checkout flow, customer portal, plan management. Each is a feature.
- "Build the whole admin panel." → split per resource (users page, orders page, settings page).

## Concrete capacity (rules of thumb)

Per session, in green/yellow zone, Claude Code can comfortably:

| Scope | Comfortable | Stretch | Too much |
|-------|-------------|---------|----------|
| **Files created/modified** | 5-10 | 10-20 | 20+ |
| **Components touched** | 3-6 | 6-12 | 12+ |
| **DB migrations** | 1-2 | 2-3 | 4+ |
| **API routes added** | 2-4 | 4-8 | 8+ |
| **Lines of net new code** | 200-800 | 800-1500 | 1500+ |
| **Distinct decisions to make** | 1-3 | 3-5 | 5+ |

These aren't hard limits — they're where quality starts slipping. The "too much" column doesn't mean impossible, it means you're paying for it in correctness bugs and re-work later.

The hardest constraint is usually **decisions**, not files. Claude can edit 30 files mechanically. It cannot make 8 architecturally-significant decisions in one session without contradicting itself.

## Sizing by project type

### Client landing site (plain HTML stack)
- Plain HTML + Tailwind + minimal JS, 1-5 pages.
- Fits comfortably in **2-3 sessions**:
  - Session 1: structure, hero, features, content
  - Session 2: forms, JSON-LD, Lighthouse pass, accessibility
  - Session 3: deploy, polish, client review tweaks
- Don't try to do all of this in one terminal even though it would fit token-wise — you want fresh attention for the deploy/polish pass.

### MVP app (Next.js + Supabase)
- Auth + 3-5 resources + 2-3 integrations = ~15-25 features.
- Plan for **15-25 sessions** to get to a working MVP.
- Per session: one feature, one DB migration if needed, one smoke test pass.

### Native mobile (Expo)
- Add ~30% to session count for iOS+Android verification.
- Don't bundle "the feature + the iOS testing + the Android testing" in one session — split.

### Refactor / migration
- Mechanical, well-defined refactors: 15-30 files per session if the change is the same pattern repeated.
- Conceptual refactors (renaming an abstraction, changing a data model): 3-8 files per session, fresh terminal often.

## The signal you've sized too big

Watch for these mid-session:
- Claude proposes a fix, you ask "wait, what about X?" and Claude says "good catch, here's the corrected version" — and *that one has a different bug*.
- Claude starts referencing a file path that doesn't exist.
- Claude suggests something you ruled out 20 messages ago.
- Tests that passed earlier in the session now fail and Claude doesn't notice.
- You're correcting Claude's understanding of the goal repeatedly.

When you see two of these in 5 minutes: **stop, commit what's working, start fresh.**

## How to break a too-big feature

If the feature genuinely doesn't fit, decompose by layer or by capability:

**By layer** (good when the feature is shaped like a single workflow):
1. DB migration + types
2. API/server logic
3. UI / form
4. Edge cases (empty/error/loading states)
5. Smoke test pass

**By capability** (good when the feature has independent sub-flows):
1. Read-only list view
2. Create flow
3. Edit + delete flow
4. Filtering / search
5. Permissions / RLS

Either way: each chunk should end in a working, committed state. Don't leave half-features hanging across sessions.

## Pacing inside a session

For a normal feature session, expect this rhythm:

1. **Orient** (5-10 min): Claude reads CLAUDE.md, PROGRESS.md, relevant existing files.
2. **Plan** (5 min): Claude proposes the approach, you push back, you agree.
3. **Build** (30-90 min): the actual work.
4. **Verify** (10-20 min): manual smoke, the 3-5 critical flows, security check on auth-touching changes.
5. **Commit + update PROGRESS.md** (5 min).

If step 3 is taking >2 hours and you're still going, you're probably oversized. Check signals above.

## What you should NOT try to do in one session

Hard "no" list — these always degrade in quality and should always be split:

- Auth + a feature that uses auth (do auth first, verify it, then build on top).
- DB schema design + the UI that consumes it (let the schema settle first).
- A net-new feature + a refactor of adjacent code (one bug per change rule).
- A bug fix + the feature you were "about to add anyway."
- Building + writing docs/tests for unrelated code.

## TL;DR

- One session = one feature, full stop.
- ~5-10 files, ~3-6 components, 1-3 decisions is the sweet spot.
- Watch for the "Claude contradicts itself" signal — that's the hard limit.
- Plan project = sessions, not just total features.
