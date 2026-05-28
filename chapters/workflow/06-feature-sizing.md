# 06 — Feature sizing: how much fits in one session

The core rule: **one session = one cohesive goal.** Not one app, not five small features, not "the whole dashboard." Pick a slice, do it, ship it, start fresh. "Feature" is the right word for product-build sessions; substitute as fits — for libraries it's "one subsystem", for CLIs "one command + its flags", for ML "one experiment", for refactors "one cleanup goal", for debugging "one investigation".

## What "one feature / cohesive goal" means

A vertical slice that touches the layers it needs (UI → API → DB for a web feature; parser → AST → emitter for a compiler change; data → train → eval for an ML iteration) and delivers user-visible value or completes a clear technical objective.

Single features (web example):
- "User can sign up with email + Google."
- "Quotes page lists quotes, supports filtering by status, paginated."
- "Webhook receives external events and updates a state table."
- "Build the public landing page (hero, features, pricing, footer)."

Single subsystems / commands / experiments (non-web examples):
- "Add `<cli> diff --json` — flag, JSON encoder, golden test, README row."
- "Library: implement `Encoder.WithSchema()` — public method + two error paths + docs."
- "Refactor: extract the retry logic into one module; no behavior change."
- "ML: try AdamW vs current optimizer on the eval set; report delta."

More than one — split these:
- "Build auth + onboarding + dashboard." → 3 sessions, minimum.
- "Add a payment integration." → split into: webhook handling, checkout flow, customer portal, plan management. Each is a session.
- "Build the whole admin panel." → split per resource (users page, orders page, settings page).
- "Refactor the entire networking layer." → split per call-site cluster; one PR each.

## Concrete capacity (rules of thumb)

Per session, in green/yellow zone, Claude Code can comfortably handle:

| Scope | Comfortable | Stretch | Too much |
|-------|-------------|---------|----------|
| **Files created/modified** | 5–10 | 10–20 | 20+ |
| **Components / modules touched** | 3–6 | 6–12 | 12+ |
| **Schema / migration changes** | 1–2 | 2–3 | 4+ |
| **API surfaces added** (routes / commands / public methods) | 2–4 | 4–8 | 8+ |
| **Lines of net new code** | 200–800 | 800–1500 | 1500+ |
| **Distinct decisions to make** | 1–3 | 3–5 | 5+ |

These aren't hard limits — they're where quality starts slipping. "Too much" doesn't mean impossible; it means you're paying for it in correctness bugs and re-work later. The rows are most directly calibrated for web-CRUD work; for libraries / CLIs / ML / firmware / data-pipelines, the *shape* of the limit holds (a small number of files + a small number of decisions per session) but the row labels translate — "API routes" becomes "public functions" or "subcommands" or "training-script changes" or "DAG nodes".

The hardest constraint is usually **decisions**, not files. Claude can edit 30 files mechanically. It cannot make 8 architecturally-significant decisions in one session without contradicting itself.

## Sizing by project type

**Client landing site (plain HTML stack)** — 1–5 pages. Fits in 2–3 sessions:
- Session 1: structure, hero, features, content
- Session 2: forms, JSON-LD, Lighthouse pass, accessibility
- Session 3: deploy, polish, client review tweaks

**MVP app (e.g. Next.js + a managed DB)** — auth + 3–5 resources + 2–3 integrations ≈ 15–25 features. Plan for **15–25 sessions** to working MVP.

**Native mobile** — add ~30% to session count for iOS + Android verification. Don't bundle "the feature + iOS testing + Android testing" — split.

**Refactor / migration** — mechanical, well-defined: 15–30 files per session. Conceptual (renaming an abstraction, changing a data model): 3–8 files, fresh terminal often.

## The signal you've sized too big

Watch for these mid-session:

- Claude proposes a fix, you ask "wait, what about X?" and Claude says "good catch, here's the corrected version" — and *that one has a different bug*.
- Claude starts referencing a file path that doesn't exist.
- Claude suggests something you ruled out 20 messages ago.
- Tests that passed earlier in the session now fail and Claude doesn't notice.
- You're correcting Claude's understanding of the goal repeatedly.

Two of these in 5 minutes: **stop, commit what's working, start fresh.** This is drift — see [01c-failure-modes.md](../foundations/01c-failure-modes.md).

## How to break a too-big feature

Decompose by layer or by capability:

**By layer** (good for a single workflow):
1. DB migration + types
2. API/server logic
3. UI / form
4. Edge cases (empty/error/loading states)
5. Smoke test pass

**By capability** (good for independent sub-flows):
1. Read-only list view
2. Create flow
3. Edit + delete flow
4. Filtering / search
5. Permissions / RLS

Either way: each chunk should end in a working, committed state. Don't leave half-features hanging across sessions.

## Pacing inside a session

A normal feature session rhythm:

1. **Orient** (5–10 min): read `CLAUDE.md`, `PROGRESS.md`, relevant files.
2. **Plan** (5 min): Claude proposes, you push back, you agree.
3. **Build** (30–90 min): the actual work.
4. **Verify** (10–20 min): manual smoke, the 3–5 critical flows, security check on auth-touching changes.
5. **Commit + update `PROGRESS.md`** (5 min).

If step 3 is taking >2 hours and you're still going, you're probably oversized. Check the signals above.

## What you should NOT try to do in one session

Hard "no" list — these always degrade in quality:

- Auth + a feature that uses auth (do auth first, verify it, then build on top).
- DB schema design + the UI that consumes it (let the schema settle first).
- A net-new feature + a refactor of adjacent code (one bug per change rule).
- A bug fix + the feature you were "about to add anyway."
- Building + writing docs/tests for unrelated code.

## TL;DR

- One session = one cohesive goal (a feature for product work, a subsystem for libraries, a command for CLIs, an experiment for ML, an investigation for debugging).
- ~5–10 files, ~3–6 components/modules, 1–3 decisions is the sweet spot.
- Watch for the "Claude contradicts itself" signal — that's the hard limit.
- Plan project = sessions, not just total features.
