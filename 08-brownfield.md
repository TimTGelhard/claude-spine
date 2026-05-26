# 08 — Brownfield: inherited code and returning to old projects

Most of this manual is greenfield-shaped — you start clean, fill in templates, build feature-by-feature. But the higher-stakes work is often brownfield: a client site you built last year and need to extend, an MVP you parked for six months, a codebase a previous developer wrote.

The patterns are different. Skipping the brownfield discipline is how you break things you don't understand.

## The fundamental difference

Greenfield:
- You know what's in the codebase (you built it).
- Conventions are explicit (or you can set them).
- Decisions exist because you made them.

Brownfield:
- You don't fully know what's in the codebase.
- Conventions are *implicit* — embedded in the code, not documented.
- Decisions exist for reasons that may no longer be obvious.

**Greenfield's risk is over-engineering.** Brownfield's risk is **breaking working code through ignorant changes.** The discipline shifts accordingly: less "build fast," more "understand first."

## When you're in brownfield mode

- Returning to your own project after >2 months away.
- Inheriting a codebase you didn't build.
- Extending a client site months after launch.
- Modifying a Claude-built project where you've forgotten what's in there.
- Working on any code where, if asked "what does this file do," you couldn't answer in one sentence.

If any of these apply, brownfield rules.

## The brownfield discovery sequence

Before the first meaningful change, run this sequence. Allow 30-60 min for a small codebase, 1-3 hours for a serious one.

### Phase 1 — Topology (15-30 min)

The goal: a one-page mental map of the codebase.

```
Read the project's CLAUDE.md (if any) and docs/ folder.
Read package.json.
Read the migrations folder for the data model.
Run: git log --oneline -30   (or more — get a feel for recent activity)
Run: tree -L 2 -I node_modules
Read the entrypoint(s): app/page.tsx, app/layout.tsx, app/api/**/route.ts
```

For each: note what the file does in one line. Stop when you have a one-page map.

Output: an updated or new `docs/ARCHITECTURE.md`. Even if it's rough.

### Phase 2 — Convention extraction (15-30 min)

Goal: write a CLAUDE.md (or update it) so future sessions don't fight the existing conventions.

What to extract:
- **Where does code live?** (`lib/`? `utils/`? `helpers/`?)
- **Naming?** (`actionCreateX` vs `createXAction` vs `submitX`?)
- **Errors thrown how?** (`throw new Error` with format? Custom error classes?)
- **Forms — react-hook-form? Server actions? Manual fetch?**
- **DB access — direct Supabase client? A wrapper? An ORM?**
- **State management — context? Zustand? Just URL params?**
- **Styling — Tailwind? CSS modules? styled-components?**

For each: find 2-3 examples in the codebase, infer the convention, write it down.

**Prompt to use:**
> Look at how forms are handled in `app/`. Read 3 examples (`app/quotes/new/page.tsx`, `app/customers/new/page.tsx`, `app/settings/page.tsx`). What's the consistent pattern? Document the convention for CLAUDE.md.

Don't *change* anything yet. Just understand.

### Phase 3 — Data flow (15-30 min)

Goal: trace one critical path end-to-end. Pick the most important user flow.

For your tradesperson app, that might be "creating a quote":
1. User clicks "New quote" in `/dashboard`.
2. Routes to `/dashboard/quotes/new`.
3. Form component (where?).
4. Submit → server action (where?).
5. zod validation (which schema?).
6. DB insert (which client? which table?).
7. RLS policy check (which policy?).
8. Redirect (where?).
9. New quote appears in list (where's the read query?).

Now you understand the spine. You can predict where to look when something breaks.

### Phase 4 — Smoke baseline (15 min)

Before changing anything, **confirm the baseline works.**

- Walk the critical flows in `SMOKE_TESTS.md` (or your own list).
- Note any flows that don't work as expected — that's pre-existing breakage, not yours.
- If something is already broken: decide if you fix it before your work, after, or never. Don't silently inherit it as "your bug."

Critical: anything that fails *after* your work that was failing *before* your work isn't a regression. Without a baseline, you'll get blamed (by yourself).

## Patterns for safe first changes

After discovery, ease in. Don't open with a refactor.

### Pattern A — The smallest visible improvement
Pick a tiny, isolated change a user would notice. A copy fix. A spacing tweak. A clearer error message.

Goal: prove the build/deploy loop works *for you* before any real change.

### Pattern B — A test before a refactor
Found a function you want to clean up? Write a test for its current behavior first. Then refactor. The test catches regressions.

Even one assertion is better than zero.

### Pattern C — Comment, don't rewrite
You spot weird code. Tempted to "clean it up." Don't — not yet.

Instead: add a one-line comment with what you *think* it does and a question mark.

```ts
// Why is this filtered twice? Is the first .filter a leftover or load-bearing?
```

Now it's a documented question. Next session (or a quiet moment), come back, find out. Maybe ask Claude to explain. Then fix once you understand.

### Pattern D — Read commits before files
For an unfamiliar file, `git log -p <file>` shows its history. The commit messages tell you *why* it looks the way it does. Often more useful than reading the current code.

## "Teaching" Claude an unfamiliar codebase

When you bring Claude into a brownfield session, it knows nothing more than you. Give it the same orientation:

```
This is an existing codebase I'm coming back to. Before doing anything:
1. Read docs/ARCHITECTURE.md, docs/PROGRESS.md, CLAUDE.md.
2. Run git log --oneline -30, summarize what's been active.
3. Read these key files: <list>.
4. Tell me in 5 bullets what this project is, where it is, what conventions you observe, and what looks risky or out of date.

Don't propose changes yet.
```

The `SESSION_STARTER.md` template's Prompt E covers this. Use it. Don't skip.

After orientation, if there's no `ARCHITECTURE.md` or `CLAUDE.md`, your *first* session should be writing them — not building features. Convention extraction is the work.

## Returning to your own old project — the warning signs

Things to expect when re-entering your own old code:

- **"Why did I do this?"** You had a reason. Don't immediately undo. Read commits, check DECISIONS.md, ask Claude to hypothesize before assuming it's wrong.
- **Dependencies have updated.** `npm outdated` will show drift. Update *deliberately* (one or two at a time, verify each), not in bulk.
- **Conventions in your global CLAUDE.md may have evolved.** The old project may not match your current style — that's fine, don't refactor the whole thing.
- **Forgotten env vars / secrets.** Compare `.env.example` to your local `.env.local`. Missing keys = the project won't run until you find them. The DEPLOY.md should help.
- **Migrations applied to remote but not the latest in your branch.** Run `supabase migration list --linked` to confirm parity.
- **The deploy is dead** — Vercel project archived, Supabase project paused for inactivity. Check before you change anything.

The first session back is mostly discovery + getting the project running again. Treat it that way. Don't try to ship a feature in the first session.

## Inheriting someone else's code

Higher stakes. Things to look for early:

- **Hardcoded secrets in the git history.** `git log -p | grep -i 'sk_\|key.*='`. If found: rotate them. The history is forever.
- **Outdated dependencies with known CVEs.** `npm audit` early.
- **RLS disabled** on tables with user data. Critical-priority fix.
- **No `.env.example`** but a working `.env.local` somewhere. The example is what new devs (you, now) need.
- **`master`/`main` directly committed-to**, no PR history. The team didn't have a review process. Expect surprises.
- **No tests.** Plan a smoke-test-first approach: walk flows manually, write down what they should do.
- **Code style chaos** — multiple paradigms in one codebase. Don't unify everything. Pick one for *new* code, leave existing alone.

Inheriting a codebase = inheriting its tech debt. You don't have to pay it all down day one. Prioritize: security first, working second, clean third.

## When to suggest a rewrite vs continue

Sometimes the right brownfield answer is "this should be rebuilt." Signs:

- Core architecture decisions are wrong for current needs (e.g. monolithic file that should be modular).
- Dependencies are >2 major versions behind, with breaking changes between them.
- No tests + complex business logic = high-risk to change.
- The codebase is small enough that a rewrite is days, not weeks.

But: the rewrite urge is often wrong. Most "this should be rewritten" feelings are because *you don't understand it yet*. Force yourself through Phase 1-4 above before making the call.

If after a full discovery sequence the answer is still "rewrite," that's a real signal. Plan it as a project (greenfield workflow). Don't try to "rewrite incrementally" — that path usually produces a broken mix of old and new.

## Anti-patterns specific to brownfield

- **Refactoring on first contact.** You don't know enough yet.
- **Updating dependencies in bulk.** Each is a separate risk.
- **Removing "dead code" you found.** It might be load-bearing in a non-obvious way. Comment it as suspected dead, leave for a follow-up.
- **Rewriting to your current preferences.** Conventions exist for reasons; matching them keeps the codebase coherent.
- **Skipping the smoke baseline.** Then you can't tell what you broke.
- **Trusting CLAUDE.md without verifying.** Old CLAUDE.md may not reflect current code. Spot-check.

## A real brownfield session, step by step

For a client landing site you built 8 months ago, asked to add a new service page:

1. Open Claude Code, fresh terminal.
2. Use Prompt E from `SESSION_STARTER.md`.
3. Claude reads CLAUDE.md, ARCHITECTURE.md (if it exists), recent commits, key files. Reports back.
4. You verify the site still builds: `npm install && npm run build && npm run dev`.
5. You walk the live site smoke tests — does the existing site work?
6. *Now* discuss the new service page. Match existing patterns. Match existing copy style.
7. Build the page.
8. Smoke tests again — does everything still work?
9. Lighthouse — did you regress perf?
10. Commit, deploy.
11. Update `PROGRESS.md` with what shipped + the date (so future-you knows when this last touched).

If you skipped 1-5 and went straight to building, you'd ship the new page just fine. But you wouldn't notice that you broke the contact form because a dependency drifted. That's the brownfield cost of skipping discovery.

## TL;DR

- Brownfield ≠ greenfield. Different risks, different discipline.
- Discovery first: topology, conventions, data flow, smoke baseline. ~1-3 hours before the first real change.
- Write or update CLAUDE.md / ARCHITECTURE.md *before* features. The work is the documentation.
- Safe first changes: small, visible, easily reversible. Build the trust loop before you refactor.
- Don't rewrite on first contact. Most "this should be rebuilt" is "I don't understand it yet."
- Returning to your own code is a brownfield situation. Treat it that way.
