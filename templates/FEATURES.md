# Features — <PROJECT NAME>

> The backlog. What's left to build, sized by sessions, ordered by priority.
> Distinct from `PROGRESS.md` (which is current state).
> Update at the end of each session: tick what's done, add what got discovered.
>
> _Stack-agnostic shape. For a fully-filled example backlog (Next.js + Supabase quote-management SaaS), see `templates/examples/web-saas-next-supabase/FEATURES.md`. "Feature" reads naturally for product backlogs; for libraries / CLIs / ML, substitute "API surface" / "subcommand" / "experiment"._

## How to use

- **One row = one cohesive goal = one session** (target). If a row needs >1 session, split it before starting.
- **Estimate in sessions, not hours.** A "session" = ~2-3 hours of focused work.
- **Priority is ordered** — top of MVP list is next.
- **Move done rows to the bottom** (or strike-through). Don't delete — you'll want the audit trail.

## Legend

- ⬜ Not started
- 🟡 In progress (only one at a time)
- ✅ Done + verified + committed
- 🚫 Cut from scope
- ⏸ Blocked (note why)

---

## MVP (minimum viable v1)

The smallest set that delivers the outcome in `PROJECT_BRIEF.md`.

| Status | Item | Est. sessions | Notes |
|--------|------|---------------|-------|
| ⬜ | `<row 1>` | `<n>` | `<one-line context>` |
| ⬜ | `<row 2>` | `<n>` | `<one-line context>` |
| ⬜ | … | … | … |

**MVP total**: ~`<sum>` sessions.

## v1.1 (post-launch, near-term)

Things you'd love to ship within 60 days of MVP.

| Status | Item | Est. sessions | Notes |
|--------|------|---------------|-------|
| ⬜ | `<row 1>` | `<n>` | `<context>` |

## Later (v2+)

Captured so they're not lost. Not committed.

- `<thing 1>`
- `<thing 2>`

## Cut from scope

Things explicitly rejected. Document why.

- 🚫 `<rejected thing 1>` → `<why rejected>`
- 🚫 `<rejected thing 2>` → `<why>`

---

## Sizing heuristics

A row is "one session" if it can comfortably do all of:
- Touch ~5-10 files / modules.
- Make 1-3 architectural decisions.
- Include verification (smoke list pass / contract test / golden output).
- End in a committed, working state.

If your estimate is "2 sessions," split into two named rows instead. Don't carry half-rows across sessions.

If a row is "0.5 sessions," batch with the next one OR enjoy a short session.

## Discovery log

New items uncovered mid-build. Triage these before committing to add — most "discoveries" are scope creep.

- [ ] `<date>`: `<discovered thing — short note + triage outcome>`

---

Updated: YYYY-MM-DD
