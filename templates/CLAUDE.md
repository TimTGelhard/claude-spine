# CLAUDE.md — <PROJECT NAME>

> Project-level instructions. Lives at project root (or `.claude/CLAUDE.md`).
> Loaded into Claude's context every session. Keep tight — 50-150 lines max.
> Global rules from `~/.claude/CLAUDE.md` still apply. This file only adds project-specific stuff.
>
> _Example uses a Next.js + Supabase quote-management app as the concrete domain. Swap stack, project layout, and domain for yours — the section headings and the discipline are stack-agnostic._

## What this is

One sentence: what we're building and for whom.

Example: "Quote-management tool for small-business contractors. Solo founder build, MVP stage."

## Stack

- Next.js 16 (App Router), TypeScript strict mode
- Supabase (Postgres + Auth + Storage)
- Tailwind + shadcn/ui
- Resend for email
- Stripe for subscriptions (server-side only)
- Deploy: Vercel (web), Supabase Cloud (DB)

## Project layout

- `app/` — App Router routes
- `app/(public)/` — unauthenticated pages
- `app/(app)/` — authenticated pages (layout enforces auth)
- `components/` — shared UI
- `lib/` — utilities
- `lib/server/` — server-only (do NOT import from client components)
- `supabase/migrations/` — DB migrations, forward-only
- `docs/` — `ARCHITECTURE.md`, `DECISIONS.md`, `PROGRESS.md`, etc.

## Conventions

- **Money**: always integer cents in DB. Display via `Intl.NumberFormat` with the project's `currency` + `locale`.
- **Time**: UTC in DB, formatted in the user's locale/timezone in UI.
- **Server actions**: file `app/<route>/actions.ts`, named `action<Verb><Noun>`.
- **API routes**: only for webhooks and external callbacks. Use server actions for UI.
- **Forms**: zod schema for every input. `react-hook-form` with `zodResolver`.
- **Errors**: `throw new Error('descriptive message with relevant ID/path')`. Never empty catches.
- **Migrations**: filename `YYYYMMDDHHMMSS_descriptive_name.sql`. Always include RLS policies in the same migration as the table.

## What lives where

| Need | Use |
|------|-----|
| Mutate from a form | Server action in `actions.ts` |
| Read for a page | Server component, direct DB call |
| Webhook from external service | API route in `app/api/webhooks/<service>/route.ts` |
| Shared UI component | `components/` |
| Server-only utility | `lib/server/` |
| Client-safe utility | `lib/` |

## Domain glossary

- **Quote**: price offer to a customer, before acceptance. Status: draft → sent → accepted/rejected.
- **Job**: an accepted quote that's now active work.
- **Customer**: tracked by phone number (low email adoption in target market).
- (Add domain terms specific to your project.)

## Read before doing anything

When starting a new session, read in this order:
1. This file (`CLAUDE.md`)
2. `docs/ARCHITECTURE.md`
3. `docs/PROGRESS.md`
4. `package.json`
5. Then the files relevant to the current task.

## Smoke test list

See `docs/SMOKE_TESTS.md`. Before declaring any feature done, walk the relevant flows there.

## Active gotchas

(Update as you find them. Delete when resolved.)

- Supabase email confirmation links break locally if `NEXT_PUBLIC_SITE_URL` isn't set — check `.env.local` first if signup fails.
- The dashboard layout query is N+1 by design for v1 — flagged in `DECISIONS.md` to fix at scale.

## When to ask me (not assume)

Ask before:
- Adding a new top-level dependency.
- Changing the data model (new table, dropped column, changed FK).
- Touching auth, RLS, or anything in `lib/server/db-admin.ts`.
- Anything visible to a customer (UX, copy, page structure).
- A refactor that wasn't requested.

Don't ask, just do (and tell me in one line):
- Internal helpers, types, file moves within `lib/`.
- Bug fixes with an obvious cause.
- Adding a missing zod schema where one should already exist.
- Formatting + lint fixes inside files I asked you to edit.

## Security minimum (this project specifically)

Global CLAUDE.md security rules apply. In addition for this project:

- Customer phone numbers are PII — never logged to Sentry/PostHog, never returned in API responses to non-owners.
- Quote PDFs may contain customer addresses — Supabase Storage bucket is RLS-protected per profile.
- The public quote-acceptance flow uses a single-use token. Never expose the internal quote ID in public URLs.

---

Updated: YYYY-MM-DD
