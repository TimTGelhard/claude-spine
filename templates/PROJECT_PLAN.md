# Project Plan — <PROJECT NAME>

> The master plan. Ordered list of sections, dependencies, and status.
> Updated rarely — only when scope changes at the project level.
> See `docs/plans/<section>.md` for the detailed breakdown of each section into sessions.

## Project goal

<One paragraph. What you're building, for whom, why now. Same as the brief's executive summary.>

## Constraints

- **Stack**: <e.g., Next.js 16 + Supabase + Vercel>
- **Timeline**: <if there's a deadline, name it; else "no deadline">
- **Team**: <solo / N devs>
- **Non-negotiables**: <e.g., RLS from day 1, no client-side privileged keys, Lighthouse 90+ mobile>

## Sections (ordered)

| # | Section | Goal (one line) | Depends on | Status |
|---|---|---|---|---|
| 1 | foundation | Project scaffolding + first deploy | — | planned |
| 2 | auth | Email + Google login, RLS baseline | 1 | planned |
| 3 | <resource-1> | CRUD for <resource> | 2 | planned |
| 4 | <resource-2> | CRUD for <resource> | 2 | planned |
| 5 | <integration> | e.g., Stripe billing | 3 or 4 | planned |
| 6 | landing | Public landing page + SEO | — | planned |
| 7 | hardening | States, perf, a11y, security review | 1-6 | planned |
| 8 | ship | Pre-deploy review + production cutover | 7 | planned |

Statuses: `planned` / `in-progress` / `done` / `blocked`.

## Order rationale

<1-2 sentences. Example: "Auth precedes resources because RLS depends on user identity. Landing has no code dependencies on the app and can run in parallel with resource sections.">

## Open questions

Decisions needed before specific sections kick off. Move to `DECISIONS.md` when resolved.

- <e.g., "Self-host auth or use Supabase Auth? — needed before section 2">
- <e.g., "Stripe Checkout vs Elements? — needed before section 5">

## Risks

Known unknowns that could change the plan.

- <e.g., "If Supabase RLS perf is a problem at scale, fall back to row-level filtering in API layer. Verify in section 3.">
- <e.g., "Stripe KYC approval may delay section 5 by N days.">

---

## Status log (append-only)

Plan-level changes only. Per-session changes live in section files and `PROGRESS.md`.

### YYYY-MM-DD
- Plan created. Sections 1-8 outlined.

### YYYY-MM-DD
- Added section 9 (notifications) — discovered during section 3 build.
