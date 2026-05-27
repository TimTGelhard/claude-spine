# 05b — Stage 1: Prep

**A fresh terminal. No feature code in this session.** Pure scaffolding.

Time: 1–2 hours with Claude.

## Tasks in order

1. Create the project directory, init git, push empty repo.
2. Set up the stack — pick from your defaults (see [03c-project-fit.md](../foundations/03c-project-fit.md)).
3. Write project-level `.claude/CLAUDE.md`. See [12-skills-memory-claudemd.md](../../12-skills-memory-claudemd.md).
4. Copy templates from the manual's `templates/` folder into the project's `docs/`:
   - `PROJECT_BRIEF.md` (from Stage 0)
   - `ARCHITECTURE.md` (fill in stack, sketch the data model — Stage 2 fills the rest)
   - `PROGRESS.md` (initial state: empty)
   - `DECISIONS.md` (empty but committed)
   - `SMOKE_TESTS.md` (the 3–5 critical flows, before you build them)
5. Lock dependencies (`package.json` + lockfile committed).
6. `.env.example` with every key you'll need, as placeholders.
7. First DB migration (auth + base tables if applicable). RLS from day 1.
8. Smoke test the empty app — does it run?

## What to ask Claude vs decide yourself

- **Ask Claude:** "what's the cleanest schema for this?" "should this be one table or two?" "what's the idiomatic Next.js 16 pattern for this?"
- **Decide yourself:** brand, color, copy, UX choices, what the product *feels* like.

This is the mode-switching pattern from [07-mode-switching.md](07-mode-switching.md) — planner mode for technical questions, executor for the scaffolding.

## Exit condition

A working "hello world" deploy. Commit, push, deploy to preview. **Before any feature exists.**

If the deploy doesn't work in Stage 1, it won't work in Stage 6 either — and Stage 6 is the wrong time to discover that.

## Common failure modes

- **Building a feature in this session "while we're at it."** Your context is now half-full of stack setup when you start the feature. Split.
- **Skipping the templates as "I'll write them when I have something to write about."** You won't. Empty templates committed now are cheap; reconstructing them later is not.
- **Skipping the first deploy because "it's just hello world."** The first deploy always breaks. Better now than at Stage 6.

## TL;DR

- 1–2 hours, fresh terminal, no feature code.
- End with: project initialized, docs committed, migrations applied, hello-world deployed.
- Don't combine with Stage 0 or Stage 2.
