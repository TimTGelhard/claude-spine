# Architecture — <PROJECT NAME>

> The source of truth Claude reads at the start of every feature session.
> Update this when architecture changes. Don't let it drift.
>
> _Stack-agnostic shape. For a fully-filled web-SaaS example (Next.js + Supabase + Stripe), see `templates/examples/web-saas-next-supabase/ARCHITECTURE.md`. Replace `<placeholder>` markers with your real values._

## Stack

- **`<surface — frontend / CLI / library API / service / mobile / firmware>`**: `<language + framework + version>`
- **`<UI / build toolchain>`** (if relevant): `<libraries>`
- **`<backend / process model>`**: `<framework + runtime + version>`
- **`<datastore>`**: `<engine + version>` (or "none")
- **`<deploy target>`**: `<hosting + region + tier>`
- **`<auth provider>`**: `<solution + integration boundary>` (or "none")
- **`<external services>`**: payment / email / storage / LLM / queues / etc.

Versions pinned in `<manifest file>`. Lockfile committed.

## High-level topology

```
<ASCII or Mermaid diagram showing the major processes / services + how
data flows between them. Keep it readable — a 10-box diagram beats a
40-box one. See the worked example for a starting layout.>
```

## Data model

### Entities

```
<entity 1>
├── <field> (<type>, <pk/fk/index notes>)
├── ...

<entity 2>
├── ...
```

(Tables for SQL, collections for document DBs, struct definitions for in-memory state. Use whichever shape your stack uses; keep it current.)

### Relationships
- `<key field>` is the tenant / scope key — every row in user-data tables references it.
- Per-row authorization strategy: `<RLS / rules / IAM / app-layer / none-because-single-tenant>`.

### Migrations / schema changes
- Location: `<dir>`, naming: `<convention>`. Forward-only or reversible? Where rollback recipes live.

## Surfaces

(Whichever applies to your project — drop the rows that don't.)

| Surface | Purpose | Auth | Server/Client |
|---|---|---|---|
| `<URL / subcommand / RPC method / topic>` | `<one-line purpose>` | `<public / required / required+owner / signature>` | `<server / client / mixed>` |

## Server / process boundaries

- **`<process type 1>` (e.g., server components, server actions, API routes, background workers, edge functions, CLI subcommands, library exports)**: when to use, when not to.
- **`<process type 2>`**: …
- **`<server-only code path>`**: the directory or naming pattern that holds anything importing secrets. Never imported by client / public-surface code.
- **`<elevated-privilege code path>`**: the directory / module that uses service-role / admin credentials. Only used in trusted contexts.

## Auth model

- `<how sessions / tokens work in this stack>`
- `<how server-side code reads the session>`
- `<how per-row / per-resource access is enforced — and what bypasses it (admin / service role)>`

### Permission model
- `<role / ownership model — single-user, multi-user, tenant, org-based>`
- `<v1 simplifications, if any>`

## External services + integration points

| Service | What for | Boundary | Free-tier limit | Cost beyond |
|---------|----------|----------|-----------------|-------------|
| `<service>` | `<what for>` | `<server-only / webhook-only / etc.>` | `<free-tier limit>` | `<paid cost>` |

Update this table when adding any new service — including the cost line. Future you will thank you when something needs to be cut.

## Environment variables

Full catalog. Anything sensitive is *server-only* (no public-prefix exposure).

| Key | Where used | Public? | Source |
|-----|------------|---------|--------|
| `<KEY>` | `<file / module>` | `<✅ public / ❌ secret>` | `<dashboard / known>` |

Mirror this in `.env.example` with placeholder values. Commit `.env.example`. Never commit real env files.

Fail loud at startup if any required key is missing — validate envs at process boot, not on first use.

## Observability

What we monitor, where the data goes, what we do when it alerts.

| Concern | Tool | Where | Action on alert |
|---------|------|-------|-----------------|
| `<errors / latency / throughput / uptime / DB queries / custom metric>` | `<tool>` | `<URL or dashboard>` | `<what to do>` |

**Do NOT log to observability tools**:
- User PII (emails, names, phone numbers, addresses).
- Auth tokens, session cookies, env vars.
- Full request / response bodies (sample, redact, or hash if needed).
- Raw LLM prompts / responses.

If a future feature needs to log one of these, decide deliberately — there may be a privacy-safe alternative (hashing, sampling, on-prem retention).

## Cache + invalidation

(Fill in if relevant. For simple projects, often "none — fetch fresh each request" is the right answer.)

- `<surface>`: `<cache strategy + invalidation trigger>`

## Deployment

- `<trigger>` → `<environment>`
- `<branching / promotion strategy>`
- `<datastore environment story — shared, per-env, branch-based>`
- Domain: `<URL>`, DNS at `<registrar>`.

## Decisions log

See `DECISIONS.md` for the reasoning behind big choices.

## Open architectural questions

- [ ] `<open question 1>`
- [ ] `<open question 2>`

---

Updated: YYYY-MM-DD by <name>
