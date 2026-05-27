# Progress — <PROJECT NAME>

> Live status. Update at the end of every session.
> Claude reads this at the start of every new session.
>
> _Example features (quote creation, PDF export, Stripe) come from a Next.js + Supabase quote-management app. Replace with your features — the structure (working / in-progress / next / blockers / log) is domain-agnostic._

## Current state

**Phase**: <Stage 0 Decide | Stage 1 Prep | Stage 2 Architect | Stage 3 Build | Stage 4 Integrate | Stage 5 Harden | Stage 6 Ship>

**Last updated**: YYYY-MM-DD

## What's working

Features that are built, verified, and committed. The smoke list passes for each.

- [x] Project scaffolding + first deploy
- [x] Database schema v1 applied
- [x] Email + Google login
- [ ] Quote creation
- [ ] Quote list
- [ ] Quote PDF export
- [ ] Stripe subscriptions

## In progress

Whatever the current session is building. One item at a time.

- [ ] Quote list page — pagination + filter by status

## Up next

The 2-3 features after the current one. Ordered.

1. Quote PDF export
2. Send quote to customer (email)
3. Mark quote accepted/rejected

## Blocked

Things stuck waiting for something external.

- [ ] Stripe live keys — waiting on KYC approval (submitted YYYY-MM-DD)

## Known bugs / debt

- Quote amount formatting doesn't handle very large numbers correctly.
- Dashboard sort order resets on refresh.

(Track these here OR in GitHub issues — pick one, don't fragment.)

## Decisions made this session

(Move to `DECISIONS.md` when finalized. Live notes here.)

- Considered using server actions vs API routes for mutations. Going with server actions for forms, API routes only for webhooks.

## Notes for next session

What "future me" or future Claude needs to know to pick up.

- The PDF generator is built but not wired to a route yet. File: `lib/server/pdf.ts`.
- Need to verify RLS policy on `quotes` from a non-owner session — write that into smoke tests.

## Next-session prompt

Copy-paste this into the next Claude Code session to resume cleanly:

```
Read CLAUDE.md, docs/ARCHITECTURE.md, docs/PROGRESS.md, docs/FEATURES.md.

Last session I built: <fill in>.
This session goal: <fill in — usually the top ⬜ item in FEATURES.md>.

Out of scope today: <fill in — explicit non-goals to keep scope tight>.

Confirm you understand before we plan. Don't write code yet.
```

Keep this block updated at session-end. It's the bridge to next session — the most valuable 60 seconds of any session.

---

## Session log (optional, prune as it grows)

### YYYY-MM-DD
- Built quote creation form.
- Discovered: zod schema needed `.coerce.number()` for the amount input.
- Committed: <commit hash>.

### YYYY-MM-DD
- Set up Supabase, RLS on all tables, deployed empty app to Vercel.
- Smoke: empty app loads, login redirect works.
