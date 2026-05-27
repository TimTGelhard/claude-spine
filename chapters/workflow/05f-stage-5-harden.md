# 05f — Stage 5: Harden

The stage everyone skips. It's where the bugs that kill the launch live.

Time: 1–3 sessions at the end of the project, one per cross-cutting concern.

## The completeness checklist

Walk this checklist for each major surface in the app:

- Empty / loading / error states present for every async surface?
- Dark mode (if relevant)?
- i18n — no hardcoded strings if the app isn't English-only?
- Time zones / locales — UTC in DB, locale in UI?
- Mobile keyboard doesn't obscure inputs?
- Slow network doesn't break the screen (skeleton states, retry on transient errors)?
- Accessibility — alt text, focus states, screen reader hints?
- Lighthouse / Web Vitals if web?
- RLS verified from two sessions (owner + non-owner) if auth?

For each: **open a dedicated session focused on that one cross-cutting concern.** Mixing them is how things get missed.

## Slash commands earn their keep here

This is the stage where Anthropic-tested review commands shine:

- `/code-review` — diff correctness review of recent changes.
- `/security-review` — independent security audit. Run this if auth, payments, or PII has been touched.
- `/verify` — end-to-end verification: drives the running app, walks the flow, confirms it actually works.
- `/ultrareview` — heavyweight multi-agent review before merging a significant branch / PR. **User-triggered only** — Claude can't launch this one. Pass `<PR#>` for a GitHub PR or no arg for the local branch.

These beat ad-hoc manual review at this stage. Use them. See [15-tool-palette.md](../../15-tool-palette.md) for the full tier list.

## Why this stage is the one everyone skips

It's invisible work. The user can't see "I added a loading state to the dashboard." But missing-state bugs are the most common production issues — far more common than logic bugs.

The math: a missing empty-state ships unnoticed in 30% of demoable apps and gets reported by 100% of real users. The fix at Stage 5 is 15 minutes. The fix in production is a hotfix + customer apology.

## Anti-patterns

- **Calling Stage 4 "Stage 5."** Integration is about seams, hardening is about cross-cutting states. Different work.
- **Skipping straight to Stage 6.** The bugs you'd have caught here will hit production instead.
- **One mega-session for all of hardening.** Loading states, dark mode, a11y, perf — these are different concerns. Different sessions.

## TL;DR

- 1–3 dedicated sessions, end of project.
- Walk the completeness checklist per cross-cutting concern.
- `/code-review`, `/security-review`, `/verify`, `/ultrareview` belong here.
- Don't skip — missing-state bugs are the most common production issues.
