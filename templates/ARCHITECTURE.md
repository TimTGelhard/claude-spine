# Architecture — <PROJECT NAME>

> The source of truth Claude reads at the start of every feature session.
> Update this when architecture changes. Don't let it drift.
>
> _Example uses Next.js + Supabase + Stripe + a quote-management domain. Swap for your stack and entities — the section structure (stack, topology, data model, security boundaries, scaling, open questions) is stack-agnostic._

## Stack

- **Frontend**: Next.js 16 (App Router), TypeScript strict
- **UI**: Tailwind CSS + shadcn/ui
- **Backend**: Next.js server actions + API routes
- **DB**: Supabase (Postgres, Auth, Storage)
- **Hosting**: Vercel (frontend + functions), Supabase Cloud (DB)
- **Email**: Resend
- **Payments**: Stripe (server-side only)
- **AI** (if used): Anthropic API via server routes

Versions pinned in `package.json`. Lockfile committed.

## High-level topology

```
┌─────────────────┐
│  Browser        │  Next.js client components
└────────┬────────┘
         │ HTTPS
┌────────▼────────┐
│  Next.js (Vercel)│
│  - Server comps │
│  - Server actions
│  - API routes   │
└────┬───────┬────┘
     │       │
┌────▼──┐ ┌──▼────┐
│Supabase│ │Stripe │
│Postgres│ │       │
│Auth    │ └───────┘
│Storage │
└────────┘
```

(Replace with your actual topology — ASCII or Mermaid.)

## Data model

### Tables

```
users (managed by Supabase Auth)
├── id (uuid, pk)
├── email
└── created_at

profiles
├── id (uuid, pk, fk → users.id)
├── company_name (text)
├── phone (text)
└── created_at

quotes
├── id (uuid, pk)
├── profile_id (uuid, fk → profiles.id)
├── customer_name (text)
├── amount_cents (integer)
├── status (enum: draft|sent|accepted|rejected)
├── created_at
└── updated_at
```

(Replace with your actual schema. Keep it current.)

### Relationships
- `profile_id` is the tenant key. Every row in user-data tables references it.
- RLS: users can only see rows where `profile_id = auth.uid()`.

### Migrations
All migrations in `supabase/migrations/`, named `YYYYMMDDHHMMSS_<descriptive_name>.sql`. Forward-only. Never edit applied migrations.

## Routes

| URL | Purpose | Auth | Server/Client |
|-----|---------|------|---------------|
| `/` | Landing page | public | server |
| `/login` | Email + Google login | public | client |
| `/dashboard` | Quote list | required | server |
| `/dashboard/quotes/new` | Create quote | required | mixed |
| `/dashboard/quotes/[id]` | View/edit quote | required + owner | server |
| `/api/webhooks/stripe` | Stripe webhook | signature | server |
| `/api/quotes/[id]/pdf` | Quote PDF download | required + owner | server |

## Server boundaries

- **Server components**: default for any page that fetches data.
- **Server actions** (`'use server'`): mutations from forms.
- **API routes**: webhooks, third-party callbacks, anything called by something other than our UI.
- **`lib/server/`**: code that imports server-only secrets. Never imported by client components.
- **`lib/db.ts`**: Supabase server client with anon key (for use with user session).
- **`lib/db-admin.ts`**: Supabase server client with service_role. Only used in webhooks and admin tasks.

## Auth model

- Supabase Auth manages session cookies (httpOnly, secure, sameSite=lax).
- Server components call `createServerClient()` which reads the cookie.
- RLS enforces row access — even if a route forgets to check, the DB won't return another user's data.
- Service_role bypasses RLS — used only in trusted server contexts.

### Permission model
- One user = one profile = one company for v1.
- No team/multi-user inside a company in v1.

## External services + integration points

| Service | What for | Boundary | Free-tier limit | Cost beyond |
|---------|----------|----------|-----------------|-------------|
| Resend | Transactional emails | Server-only, `lib/server/email.ts` | 100/day, 3k/mo | $20/mo for 50k |
| Stripe | Subscriptions | Webhook → DB write | unlimited (transaction fees) | 1.4% + €0.25 EU cards |
| Anthropic | (if used) Quote draft gen | Server route only, never client | pay-per-token | model-dependent |
| Supabase Storage | PDF storage | RLS-protected bucket per profile | 1GB | $0.021/GB/mo |
| Vercel | Hosting + functions | — | Hobby: limited | Pro $20/mo per member |
| Supabase | DB + Auth | — | Free: 500MB DB, 50k MAU | Pro $25/mo |

Update this table when adding any new service — including the cost line. Future you will thank you when something needs to be cut.

## Environment variables

Full catalog. Anything sensitive is *server-only* (no `NEXT_PUBLIC_` prefix).

| Key | Where used | Public? | Source |
|-----|------------|---------|--------|
| `NEXT_PUBLIC_SITE_URL` | client + server (URLs in emails) | ✅ public | known |
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase client | ✅ public | Supabase dashboard |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase client (RLS-enforced) | ✅ public | Supabase dashboard |
| `SUPABASE_SERVICE_ROLE_KEY` | `lib/server/db-admin.ts` only | ❌ secret | Supabase dashboard |
| `RESEND_API_KEY` | `lib/server/email.ts` | ❌ secret | Resend dashboard |
| `STRIPE_SECRET_KEY` | `lib/server/stripe.ts` | ❌ secret | Stripe dashboard |
| `STRIPE_WEBHOOK_SECRET` | webhook verification | ❌ secret | Stripe dashboard |
| `ANTHROPIC_API_KEY` | server routes only | ❌ secret | Anthropic console |

Mirror this in `.env.example` with placeholder values. Commit `.env.example`. Never commit `.env.local`.

Fail loud at startup if any required key is missing — see `lib/env.ts` for the zod-validated env schema.

## Observability

What we monitor, where the data goes, what we do when it alerts.

| Concern | Tool | Where | Action on alert |
|---------|------|-------|-----------------|
| Errors (server + client) | Sentry | sentry.io project `<name>` | Investigate within 24h if non-trivial |
| Web vitals | Vercel Analytics | Vercel dashboard | Investigate if p75 LCP > 2.5s |
| DB queries | Supabase logs | Supabase dashboard | Investigate slow queries weekly |
| Uptime | Vercel (built-in) | — | n/a for MVP |

**Do NOT log to Sentry/PostHog**:
- User PII (emails, names, phone numbers).
- Auth tokens, session cookies, env vars.
- Full request bodies.
- Raw LLM prompts/responses.

If a future feature needs to log one of these, talk to me first — there may be a privacy-safe alternative.

## Cache + invalidation

(Fill in if relevant. For simple MVPs, often "none — fetch fresh each request" is the right answer.)

- `/dashboard`: no cache (fresh per request).
- `/` (landing): static, regenerated on deploy.
- Quote PDF: cached in Supabase Storage, regenerated on quote update.

## Deployment

- `main` → Vercel production.
- Branches → Vercel preview deploys.
- Supabase: single project, environments via local `.env` vs Vercel env vars.
- Domain: `<project>.com`, DNS at <registrar>.

## Decisions log

See `DECISIONS.md` for the reasoning behind big choices.

## Open architectural questions

- [ ] Multi-tenant model for v2 (separate DBs vs RLS-per-org)?
- [ ] Email vs WhatsApp for quote delivery?

---

Updated: YYYY-MM-DD by <name>
