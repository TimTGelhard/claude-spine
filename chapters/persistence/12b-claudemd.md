# 12b — CLAUDE.md: the always-loaded baseline

Anything in `CLAUDE.md` (global or project) is loaded into context at session start. It costs tokens every session, so be tight.

## Global (`~/.claude/CLAUDE.md`)

Covers things that apply across all projects: tone, decision-making style, code output rules, security rules, stack defaults, verification discipline.

**Rule of thumb:** if a rule applies to >50% of your projects, it belongs in global. Otherwise, project-level.

## Project-level (`<project>/CLAUDE.md` or `<project>/.claude/CLAUDE.md`)

Where stack-specific and project-specific stuff lives. Template:

```markdown
# <Project Name>

## What this is
One paragraph. What we're building, for whom.

## Stack
- Next.js 16 (App Router), TypeScript strict
- Supabase (Postgres + Auth + Storage)
- Tailwind + shadcn/ui
- Deploy: Vercel

## Layout
- `app/` — routes (App Router)
- `components/` — shared components
- `lib/` — utilities (anything in `lib/server/` is server-only)
- `supabase/migrations/` — DB migrations, forward-only

## Conventions specific to this project
- Money stored as integer cents in DB. Display via the project's locale formatter.
- All times UTC in DB, formatted in the user's locale in UI.
- Server actions named `action<Verb><Noun>`. Located in `app/<route>/actions.ts`.

## Smoke test list (the 5 flows that must work)
1. Anonymous user lands on /
2. Sign up + email confirm → land on /dashboard
3. Create a quote → appears in list
4. Edit quote → changes persist
5. Sign out → redirected, can't access /dashboard

## Domain knowledge
- "Quote" = a price offer, before customer accepts. Becomes "Job" once accepted.
- Customers tracked by phone number (target market has low email adoption).
```

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
