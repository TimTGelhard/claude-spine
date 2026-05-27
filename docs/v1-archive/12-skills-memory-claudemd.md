> **DEPRECATED** — v2 atomic version: [`chapters/persistence/`](../../chapters/persistence/). Full v1→v2 map: [`V1-CHAPTERS-DEPRECATED.md`](../../V1-CHAPTERS-DEPRECATED.md). Body kept for cross-reference.

# 12 — Skills, memory, and CLAUDE.md: the three persistence layers

Claude Code has three different mechanisms for "remembering things between sessions." They look similar but behave very differently. Using the wrong one is a common mistake.

## At a glance

| Layer | Lives in | Loaded | Best for |
|-------|----------|--------|----------|
| **CLAUDE.md** | Project root + global `~/.claude/CLAUDE.md` | Every session, automatically, into context | Stable instructions: stack, conventions, rules |
| **Skills** | `~/.claude/skills/` or `.claude/skills/` | Lazily, when description matches the task | Specialized capabilities ("review code", "deploy to Vercel") |
| **Memory** | `~/.claude/projects/<dir>/memory/` + `MEMORY.md` | Lazily, when relevant | Things learned about *you* and *the project state* across sessions |

## CLAUDE.md — the always-loaded baseline

Anything in `CLAUDE.md` (global or project) is loaded into context at session start. It costs tokens every session, so be tight.

### Global (`~/.claude/CLAUDE.md`) — you already have a great one
Your existing file covers: tone, decision-making style, code output rules, security rules, stack defaults, verification discipline. Keep it. Don't bloat it.

**Rule of thumb:** if a rule applies to >50% of your projects, it belongs in global. Otherwise, project-level.

### Project-level (`<project>/CLAUDE.md` or `<project>/.claude/CLAUDE.md`)
This is where stack-specific and project-specific stuff lives. Template:

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
- Customers are tracked by phone number (target market has low email adoption).
```

### What does NOT go in CLAUDE.md
- Anything you can derive from `package.json`, the file structure, or recent git log.
- Long lists of all files in the project (waste of tokens).
- Things that change every week (use `PROGRESS.md` for that).
- Personal preferences that don't affect *this* project.

### How big should CLAUDE.md be?
- Global: yours is ~250 lines. Fine.
- Project: aim for 50-150 lines. Over 200 and it's competing too hard with the actual work.

## Skills — specialized capabilities

Skills are markdown files with frontmatter that Claude Code loads *lazily* — only when their description matches the current task. You can have many; they don't bloat context unless triggered.

### When to write a custom skill
- A repeated multi-step workflow you do across projects ("deploy to Vercel," "run my smoke test list").
- A non-obvious procedure (specific way you set up Supabase locally, specific way you check WCAG contrast).
- A reference document you want Claude to consult on-demand (your design system rules).

### When NOT to write a skill
- One-off tasks. Just type the prompt.
- Project-specific stuff — put in project CLAUDE.md.
- Things already covered by built-in skills (check the list before duplicating).

### Skill file shape

```markdown
---
name: client-site-deploy
description: Deploy a static client website to the production VPS. Use when deploying any project under the client-site stack, or when the user mentions VPS deployment for a landing site.
---

# Deploy to VPS

1. Run `npm run build`
2. Lighthouse mobile check, must score 90+
3. SCP `dist/` to `staging.<domain>:/var/www/...`
4. Visual check: open the staging URL, walk smoke list
5. Promote to production: rename `staging` → `live`, archive previous
6. Update `PROGRESS.md` with deploy timestamp
```

The `description` field is what Claude matches against. Be specific — vague descriptions trigger when you don't want them, narrow descriptions don't trigger when you do.

### Where to put skills
- `~/.claude/skills/` — global, available in every project.
- `<project>/.claude/skills/` — project-specific.

Use global for cross-project workflows, project for project-specific procedures.

## Memory — what's learned about you and your state

Memory is the layer for things Claude figures out over time. Unlike CLAUDE.md (you write it) and skills (you write them), memory is mostly written by Claude based on what happens in conversations.

There are four types (your global system describes them in detail):

- **user** — facts about you, your role, your preferences.
- **feedback** — corrections and confirmations of how you want work done.
- **project** — current state of ongoing initiatives.
- **reference** — pointers to external resources (Linear projects, Slack channels, dashboards).

### How memory is loaded
`MEMORY.md` is always loaded (it's the index, capped at ~200 lines). Individual memory files are loaded on-demand when relevant.

### Your job vs Claude's job
- **Claude writes memory** when you teach it something durable ("don't mock the DB in tests"), correct it, or share something durable about how you work.
- **You can ask it to remember things explicitly** ("remember that I prefer the comma decimal format for prices") — it'll save it.
- **You should review memory occasionally** — `~/.claude/projects/<dir>/memory/MEMORY.md` is a normal file. Open it. Prune stale stuff. Memories silently age out of accuracy.

### Memory anti-patterns
- Don't ask Claude to memorize project structure — `tree` gives that.
- Don't memorize specific functions or code — that decays in days.
- Don't memorize "current state" stuff that should be in `PROGRESS.md`.

## How they compose in a real session

1. Session starts. Claude reads global + project `CLAUDE.md`. ~5-10K tokens used.
2. `MEMORY.md` index loaded. ~1-2K tokens.
3. You ask for something. Claude maybe loads a skill if it matches. ~3-5K tokens.
4. Claude maybe loads a specific memory if relevant. ~500 tokens.
5. Conversation proceeds with all of the above active.

Total before you've done any real work: ~15-20K tokens of "remembered context." This is fine — that's why we use them.

But if your CLAUDE.md is 800 lines and you have 20 skills always triggering, you start sessions in yellow zone. Trim.

## Decision tree: where does this thing go?

> I want Claude to know X.

- Is X stable across all projects? → Global `CLAUDE.md`.
- Is X stable for this project only? → Project `CLAUDE.md`.
- Is X a multi-step procedure I do repeatedly? → Skill.
- Is X about me as a person / my preferences? → Memory (user / feedback).
- Is X about current project state, deadlines, decisions? → `PROGRESS.md` / `DECISIONS.md` in the project (NOT memory — files in the project are more durable and reviewable).
- Is X about an external system? → Memory (reference) — but only if you'll actually use it.

## TL;DR

- `CLAUDE.md` = always loaded, stable rules. Cheap until it's bloated.
- Skills = lazy, specialized. Have many; they don't cost you until used.
- Memory = automatic and lazy. Review it occasionally; prune stale.
- Project state (progress, decisions) goes in markdown files in the project, not memory.
