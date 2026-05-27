# 08c — Teaching Claude an unfamiliar codebase

When you bring Claude into a brownfield session, it knows nothing more than you. Give it the same orientation you'd give yourself — see [08a-discovery-sequence.md](08a-discovery-sequence.md).

## The orientation prompt

```
This is an existing codebase I'm coming back to. Before doing anything:

1. Read docs/ARCHITECTURE.md, docs/PROGRESS.md, CLAUDE.md.
2. Run git log --oneline -30, summarize what's been active.
3. Read these key files: <list>.
4. Tell me in 5 bullets what this project is, where it is,
   what conventions you observe, and what looks risky or out of date.

Don't propose changes yet.
```

The `SESSION_STARTER.md` template's Prompt E covers this. Use it. Don't skip.

After orientation, if there's no `ARCHITECTURE.md` or `CLAUDE.md`, your *first* session should be writing them — not building features. **Convention extraction is the work.**

## Returning to your own old project — warning signs

Things to expect when re-entering your own old code:

- **"Why did I do this?"** You had a reason. Don't immediately undo. Read commits, check `DECISIONS.md`, ask Claude to hypothesize before assuming it's wrong.
- **Dependencies have updated.** `npm outdated` will show drift. Update *deliberately* (one or two at a time, verify each), not in bulk.
- **Conventions in your global CLAUDE.md may have evolved.** The old project may not match your current style — that's fine, don't refactor the whole thing.
- **Forgotten env vars / secrets.** Compare `.env.example` to your local `.env.local`. Missing keys = the project won't run until you find them.
- **Migrations applied to remote but not the latest in your branch.** Run the equivalent of `supabase migration list --linked` to confirm parity.
- **The deploy is dead** — host project archived, DB project paused for inactivity. Check before you change anything.

The first session back is mostly discovery + getting the project running again. Treat it that way. Don't try to ship a feature in the first session.

## Inheriting someone else's code

Higher stakes. Things to look for early:

- **Hardcoded secrets in the git history.** `git log -p | grep -i 'sk_\|key.*='`. If found: rotate them. The history is forever.
- **Outdated dependencies with known CVEs.** `npm audit` early.
- **RLS disabled** on tables with user data (or the equivalent for whatever DB you have). Critical-priority fix.
- **No `.env.example`** but a working `.env.local` somewhere. The example is what new devs (you, now) need.
- **`master` / `main` directly committed-to**, no PR history. The team didn't have a review process. Expect surprises.
- **No tests.** Plan a smoke-test-first approach: walk flows manually, write down what they should do.
- **Code style chaos** — multiple paradigms in one codebase. Don't unify everything. Pick one for *new* code, leave existing alone.

Inheriting a codebase = inheriting its tech debt. You don't have to pay it all down day one. Prioritize: **security first, working second, clean third.**

## Why this matters

Claude in a brownfield session without orientation will:
- Suggest patterns that don't match the codebase's conventions.
- Propose changes that violate constraints encoded in the schema or RLS.
- Refactor code that looks "wrong" but is load-bearing.

The orientation prompt is 5 minutes. The damage from skipping it is hours-to-days.

## TL;DR

- Always orient Claude with the discovery sequence before changes.
- Returning to your own code is a brownfield situation — treat it that way.
- Inheriting someone else's: security first, working second, clean third.
