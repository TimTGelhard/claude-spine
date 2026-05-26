# Features — <PROJECT NAME>

> The backlog. What's left to build, sized by sessions, ordered by priority.
> Distinct from `PROGRESS.md` (which is current state).
> Update at the end of each session: tick what's done, add what got discovered.

## How to use

- **One row = one feature = one session** (target). If a feature needs >1 session, split it before starting.
- **Estimate in sessions, not hours.** A "session" = ~2-3 hours of focused work.
- **Priority is ordered** — top of MVP list is next.
- **Move done features to the bottom** (or strike-through). Don't delete — you'll want the audit trail.

## Legend

- ⬜ Not started
- 🟡 In progress (only one at a time)
- ✅ Done + verified + committed
- 🚫 Cut from scope
- ⏸ Blocked (note why)

---

## MVP (minimum viable v1)

The smallest set that delivers the outcome in `PROJECT_BRIEF.md`.

| Status | Feature | Est. sessions | Notes |
|--------|---------|---------------|-------|
| ✅ | Project scaffolding + first deploy | 1 | Vercel preview green |
| ✅ | DB schema v1 + RLS | 1 | Migration `20260520_init.sql` |
| 🟡 | Email + Google login | 1 | In progress, see PROGRESS.md |
| ⬜ | Onboarding (set company name + phone) | 1 | After login lands |
| ⬜ | Quote list page | 1 | Pagination + filter |
| ⬜ | Create quote form | 1 | zod schema needed |
| ⬜ | Quote PDF generation | 1.5 | Considering `@react-pdf/renderer` |
| ⬜ | Send quote (email link to customer) | 1 | Resend integration |
| ⬜ | Customer accepts/rejects via public link | 1 | Token-based public route |
| ⬜ | Settings page (company details, logo) | 1 | Logo upload to Supabase Storage |
| ⬜ | Stripe subscription (Starter plan only) | 2 | Webhook + portal |
| ⬜ | Delete account flow | 0.5 | Required for GDPR |

**MVP total**: ~13 sessions.

## v1.1 (post-launch, near-term)

Things you'd love to ship within 60 days of MVP.

| Status | Feature | Est. sessions | Notes |
|--------|---------|---------------|-------|
| ⬜ | WhatsApp delivery (in addition to email) | 2 | WhatsApp Business API |
| ⬜ | Quote templates | 1 | Pre-fill common quotes |
| ⬜ | Customer list view | 1 | Track per-customer history |
| ⬜ | Multi-currency support | 1.5 | If non-EU expansion |

## Later (v2+)

Captured so they're not lost. Not committed.

- Multi-user per company (teams)
- Invoice generation (post-quote acceptance)
- Mobile app (Expo)
- Tax export for accountant (NL-specific)

## Cut from scope

Things explicitly rejected. Document why.

- 🚫 In-app messaging customer↔business → use existing channels (WhatsApp, email).
- 🚫 Multi-language UI in v1 → single locale only.

---

## Sizing heuristics

A feature is "one session" if it can comfortably do all of:
- Touch 5-10 files.
- Make 1-3 architectural decisions.
- Include verification (smoke list pass).
- End in a committed, working state.

If your estimate is "2 sessions," split into two named features instead. Don't carry half-features across sessions.

If a feature is "0.5 sessions," batch with the next one OR enjoy a short session.

## Discovery log

New features uncovered mid-build. Triage these before committing to add — most "discoveries" are scope creep.

- [ ] Found 2026-05-22: users may want to duplicate quotes. Adds to v1.1 if it comes up from 3+ users.

---

Updated: YYYY-MM-DD
