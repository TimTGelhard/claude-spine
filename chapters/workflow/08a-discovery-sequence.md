# 08a — Brownfield discovery sequence

Before the first meaningful change in an unfamiliar codebase, run this sequence. Allow 30–60 min for a small codebase, 1–3 hours for a serious one.

## When you're in brownfield mode

- Returning to your own project after >2 months away.
- Inheriting a codebase you didn't build.
- Extending a client site months after launch.
- Modifying a Claude-built project where you've forgotten what's in there.
- Working on any code where, asked "what does this file do," you couldn't answer in one sentence.

If any of these apply, brownfield rules. Greenfield's risk is over-engineering; brownfield's risk is **breaking working code through ignorant changes**. Different discipline.

## Phase 1 — Topology (15–30 min)

Goal: a one-page mental map of the codebase.

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

## Phase 2 — Convention extraction (15–30 min)

Goal: write or update `CLAUDE.md` so future sessions don't fight the existing conventions.

What to extract:
- **Where does code live?** (`lib/`? `utils/`? `helpers/`?)
- **Naming?** (`actionCreateX` vs `createXAction` vs `submitX`?)
- **Errors thrown how?** (`throw new Error` with format? Custom error classes?)
- **Forms** — react-hook-form? Server actions? Manual fetch?
- **DB access** — direct client? A wrapper? An ORM?
- **State management** — context? Zustand? URL params?
- **Styling** — Tailwind? CSS modules? styled-components?

For each: find 2–3 examples in the codebase, infer the convention, write it down.

**Prompt to use:**
> Look at how forms are handled in `app/`. Read 3 examples (`app/quotes/new/page.tsx`, `app/customers/new/page.tsx`, `app/settings/page.tsx`). What's the consistent pattern? Document the convention for CLAUDE.md.

Don't *change* anything yet. Just understand.

## Phase 3 — Data flow (15–30 min)

Goal: trace one critical path end-to-end. Pick the most important user flow.

Example — "creating a quote":
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

## Phase 4 — Smoke baseline (15 min)

Before changing anything, **confirm the baseline works.**

- Walk the critical flows in `SMOKE_TESTS.md` (or your own list).
- Note any flows that don't work as expected — that's pre-existing breakage, not yours.
- If something is already broken: decide if you fix it before your work, after, or never. Don't silently inherit it as "your bug."

Critical: anything that fails *after* your work that was failing *before* your work isn't a regression. Without a baseline, you'll get blamed (by yourself).

## TL;DR

- Four phases: topology, conventions, data flow, smoke baseline.
- 1–3 hours before any real change. Cheaper than the alternative.
- Outputs are durable: `ARCHITECTURE.md`, `CLAUDE.md`, smoke baseline notes.
