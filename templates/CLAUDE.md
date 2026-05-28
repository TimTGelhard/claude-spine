# CLAUDE.md — <PROJECT NAME>

> Project-level instructions. Lives at project root (or `.claude/CLAUDE.md`).
> Loaded into Claude's context every session. Keep tight — 50-150 lines max.
> Global rules from `~/.claude/CLAUDE.md` still apply. This file only adds project-specific stuff.
>
> _Stack-agnostic shape. For a fully-filled web-SaaS example (Next.js + Supabase + Stripe), see `templates/examples/web-saas-next-supabase/CLAUDE.md`. Replace `<placeholder>` markers with your real values._

## What this is

One sentence: what we're building and for whom.

## Stack

- `<language + framework, version pinned>`
- `<datastore + version, or "none">`
- `<UI / build toolchain, if any>`
- `<other major libraries that future sessions will need to know about>`
- Deploy: `<hosting target>`

(Anything the project depends on enough that Claude should never silently swap it.)

## Project layout

- `<top-level dir 1>/` — `<what lives here>`
- `<top-level dir 2>/` — `<what lives here>`
- `<top-level dir N>/` — `<what lives here>`
- Any path-coded constraints (e.g., "anything in `lib/server/` is server-only", "`internal/` packages are not re-exported", "code under `apps/<app>/` is one bounded context per app")

## Conventions

- **Units / formats**: e.g., money as integer cents, times in UTC, IDs as UUIDv7. Anything Claude would otherwise re-derive every session.
- **Naming**: function shapes, file shapes, test file naming.
- **Errors**: how this project signals + handles errors (typed errors vs exceptions vs `Result`, retry policy, log-vs-throw).
- **Migrations / schema changes**: file naming convention, forward-only vs reversible, where rollback recipes live.

## What lives where

| Need | Use |
|------|-----|
| `<common need 1>` | `<the canonical place for it>` |
| `<common need 2>` | `<the canonical place for it>` |
| `<common need 3>` | `<the canonical place for it>` |

(A small "where does X go" table prevents the same question recurring every session.)

## Domain glossary

- **`<term-of-art 1>`**: what it means in this codebase (often differs from the dictionary meaning or the term's meaning at a previous job).
- **`<term-of-art 2>`**: …
- Invariants the code assumes but doesn't enforce.

## Read before doing anything

When starting a new session, read in this order:
1. This file (`CLAUDE.md`)
2. `docs/ARCHITECTURE.md`
3. `docs/PROGRESS.md`
4. `<the project's manifest — package.json / pyproject.toml / go.mod / Cargo.toml / Gemfile / pom.xml / etc.>`
5. Then the files relevant to the current task.

## Smoke test list

See `docs/SMOKE_TESTS.md`. Before declaring any feature done, walk the relevant flows there.

## Active gotchas

(Update as you find them. Delete when resolved.)

- `<active gotcha 1 — surprising behavior the code doesn't surface, a workaround for a third-party bug, etc.>`
- `<active gotcha 2>`

## When to ask me (not assume)

Ask before:
- Adding a new top-level dependency.
- Changing the data model (new table / collection, dropped column / field, changed FK / reference).
- Touching auth / authorization / anything with elevated privileges.
- Anything visible to a customer / user (UX, copy, page / output structure).
- A refactor that wasn't requested.

Don't ask, just do (and tell me in one line):
- Internal helpers, types, file moves within a single module.
- Bug fixes with an obvious cause.
- Adding missing validation where one should already exist.
- Formatting + lint fixes inside files I asked you to edit.

## Security minimum (this project specifically)

Global CLAUDE.md security rules apply. In addition for this project:

- `<PII / sensitive data category 1>`: where it lives, what NOT to log or expose, special-handling rules.
- `<credential / secret category>`: which env vars are server-only, which deploy targets they live in.
- `<auth-sensitive flow>`: any extra check Claude should run before touching this area.

---

Updated: YYYY-MM-DD
