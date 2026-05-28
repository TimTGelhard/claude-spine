# Project Plan — <PROJECT NAME>

> The master plan. Ordered list of sections, dependencies, and status.
> Updated rarely — only when scope changes at the project level.
> See `docs/plans/<section>.md` for the detailed breakdown of each section into sessions.

## Project goal

<One paragraph. What you're building, for whom, why now. Same as the brief's executive summary.>

## Constraints

- **Stack**: `<language + framework + datastore + deploy target — example: "Next.js 16 + Supabase + Vercel" or "Python 3.12 + Django + Postgres + Fly.io" or "Go 1.23 + sqlite + single static binary">`
- **Timeline**: `<if there's a deadline, name it; else "no deadline">`
- **Team**: `<solo / N devs / OSS contributors / agency engagement>`
- **Non-negotiables**: `<e.g., "per-row authorization from day 1", "no client-side privileged keys", "Lighthouse 90+ mobile", "single static binary, no runtime deps", "must support cancellation across every async path">`

## Sections (ordered)

| # | Section | Goal (one line) | Depends on | Status |
|---|---|---|---|---|
| 1 | foundation | `<scaffolding + first deploy / first published version / first run>` | — | planned |
| 2 | `<core-capability-1>` | `<one-line goal>` | 1 | planned |
| 3 | `<core-capability-2>` | `<one-line goal>` | 1 or 2 | planned |
| 4 | … | … | … | planned |
| N | hardening | `<edge cases, perf, security review, observability>` | 1-N-1 | planned |
| N+1 | ship | `<pre-deploy review + production cutover / first public release>` | N | planned |

(For section ordering templates by project type — web SaaS, backend service, CLI / library, ML pipeline — see `~/.claude-spine/skills/core/op-prepare/procedure.md` Step 5.)

Statuses: `planned` / `in-progress` / `done` / `blocked`.

## Order rationale

`<1-2 sentences. Example: "Auth precedes resources because per-row authorization depends on user identity. Landing has no code dependencies on the app and can run in parallel with resource sections.">`

## Open questions

Decisions needed before specific sections kick off. Move to `DECISIONS.md` when resolved.

- `<e.g., "Self-host auth or use a managed provider? — needed before section 2">`
- `<e.g., "Which payment provider? — needed before section 5">`

## Risks

Known unknowns that could change the plan.

- `<e.g., "If the chosen datastore's per-row-authorization perf is a problem at scale, fall back to API-layer filtering. Verify in section 3.">`
- `<e.g., "External-provider KYC may delay section 5 by N days.">`

---

## Status log (append-only)

Plan-level changes only. Per-session changes live in section files and `PROGRESS.md`.

### YYYY-MM-DD
- Plan created. Sections 1-8 outlined.

### YYYY-MM-DD
- Added section 9 (notifications) — discovered during section 3 build.
