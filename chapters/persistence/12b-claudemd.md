# 12b — CLAUDE.md: the always-loaded baseline

Anything in `CLAUDE.md` (global or project) is loaded into context at session start. It costs tokens every session, so be tight.

## Global (`~/.claude/CLAUDE.md`)

Covers things that apply across all projects: tone, decision-making style, code output rules, security rules, stack defaults, verification discipline.

**Rule of thumb:** if a rule applies to >50% of your projects, it belongs in global. Otherwise, project-level.

## Project-level (`<project>/CLAUDE.md` or `<project>/.claude/CLAUDE.md`)

Where stack-specific and project-specific stuff lives. The *shape* below is the lesson — every project-level CLAUDE.md has these six sections regardless of stack:

```markdown
# <Project Name>

## What this is
One paragraph. What we're building, for whom.

## Stack
- <language + framework + versions pinned>
- <datastore>
- <UI / build toolchain, if relevant>
- Deploy: <target>

## Layout
- <top-level dir 1> — <what lives here>
- <top-level dir 2> — <what lives here>
- (anything path-coded — e.g., "anything in `lib/server/` is server-only")

## Conventions specific to this project
- <unit conventions — money as cents, times in UTC, etc.>
- <naming conventions — function shapes, file shapes>
- <anything Claude would otherwise re-derive every session>

## Smoke test list (the 3-5 flows / commands / contracts that must work)
1. <the most-important happy path>
2. <the next-most-important>
…

## Domain knowledge
- <terms-of-art — what "Job" means, what "Trace" means in your codebase>
- <invariants the code assumes but doesn't enforce>
```

### Three worked examples

The same shape, three project types:

**Web SaaS (Next.js + Supabase)**

```markdown
## Stack
- Next.js 16 (App Router), TypeScript strict
- Supabase (Postgres + Auth + Storage)
- Tailwind + shadcn/ui
- Deploy: Vercel

## Layout
- `app/` — routes (App Router)
- `components/` — shared components
- `lib/server/` — server-only utilities
- `supabase/migrations/` — DB migrations, forward-only

## Conventions
- Money as integer cents in DB; format on display.
- Server actions named `action<Verb><Noun>` in `app/<route>/actions.ts`.

## Smoke tests
1. Anonymous → /; 2. Sign up + confirm → /dashboard; 3. Create a quote → appears in list; 4. Edit persists; 5. Sign out blocks /dashboard.
```

**Python web API (Django REST)**

```markdown
## Stack
- Python 3.12, Django 5 + DRF, mypy strict
- Postgres 16
- Deploy: Docker → Fly.io

## Layout
- `apps/<app>/` — one Django app per bounded context (`models.py`, `views.py`, `serializers.py`, `urls.py`)
- `apps/<app>/migrations/` — forward-only
- `core/` — shared (auth, middleware, settings)
- `tests/` — `pytest` mirroring `apps/`

## Conventions
- ViewSets over function views; permission classes explicit per endpoint (no global allow).
- Migrations land in their own PR; never bundle schema + behavior.

## Smoke tests
1. `pytest apps/` is green; 2. `manage.py migrate` clean on a fresh DB; 3. Auth endpoints return correct 401/403 for unauth/forbidden; 4. OpenAPI schema generates without warnings.
```

**Go CLI tool**

```markdown
## Stack
- Go 1.23, no external runtime deps; `cobra` for commands
- Single static binary, distributed via `go install` + GitHub Releases

## Layout
- `cmd/<bin>/main.go` — entrypoint
- `internal/<pkg>/` — non-exported packages, one per cohesive concern
- `pkg/` — only if a public API surface exists (rare for CLIs)
- `testdata/` — fixture files

## Conventions
- Errors returned with `%w` wrapping, never logged-and-swallowed mid-call.
- Public commands documented in their cobra `Long` field — this is the user-facing reference.

## Smoke tests
1. `go test ./...` green; 2. `go build ./cmd/<bin>` produces a binary; 3. `<bin> --help` exits 0 and prints all subcommands; 4. The two highest-leverage subcommands run on `testdata/` and match golden output.
```

The point isn't which stack — it's that *every* CLAUDE.md needs Stack, Layout, Conventions, Smoke tests, Domain knowledge. Pick the example closest to your project as a starting point.

## What does NOT go in CLAUDE.md

- Anything you can derive from `package.json`, the file structure, or recent git log.
- Long lists of all files in the project (waste of tokens).
- Things that change every week (use `PROGRESS.md` for that).
- Personal preferences that don't affect *this* project — those are memory.
- Automatic behaviors like "always typecheck after edits" — those are hooks ([14b](14b-hook-recipes.md)), not instructions.

## How big should CLAUDE.md be?

- Global: 200–300 lines is reasonable.
- Project: aim for 50–150 lines. Over 200 and it's competing too hard with the actual work.

## Override hierarchy

More specific wins:

1. Project-level `.claude/CLAUDE.md`
2. Workspace-level `.claude/CLAUDE.md` (e.g. `/Dev/`)
3. Global `~/.claude/CLAUDE.md`

Exception: security rules apply at every level and don't get loosened by project files.

## TL;DR

- Global = cross-project rules. ~200–300 lines.
- Project = stack, conventions, smoke list, domain knowledge. 50–150 lines.
- Don't bloat. Tokens spent here are tokens not spent on the work.
