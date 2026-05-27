# 13c — Skill design patterns

Three patterns cover most useful skills.

## Pattern A — Workflow skill

A multi-step procedure with a clear start and end.

```markdown
---
name: pre-deploy-audit
description: Run a pre-deploy audit on a Next.js + Supabase project. Use before pushing to production, when the user mentions "deploy", "ship", "go live", or "production release".
---

# Pre-deploy audit

Run these checks in order. Stop on first failure and report.

1. **Typecheck**: `npm run typecheck`. If errors, halt and list them.
2. **Lint**: `npm run lint`. Halt on errors. Warnings allowed but list them.
3. **Audit**: `npm audit --omit=dev`. Halt on critical/high.
4. **Secret leak**: `grep -rE "sk_(live|test)_|sk-ant-|service_role" .next/static/ 2>/dev/null`. Halt if any matches.
5. **Migrations parity**: `supabase migration list --linked` — verify local matches remote.
6. **Smoke tests**: confirm `docs/SMOKE_TESTS.md` is recently dated and the user has walked it.
7. **Report**: bullet-list pass/fail. If all pass, give a one-line go-ahead.

Don't deploy. Just audit.
```

Use case: you ask "ready to deploy?" — skill loads, runs the audit, reports.

## Pattern B — Reference skill

A lookup or knowledge dump loaded on demand. Concrete example below uses Dutch (`nl-NL`) — write the equivalent for whatever locale your product ships in.

```markdown
---
name: locale-rules-nl
description: Dutch (nl-NL) locale formatting rules for prices, dates, phone numbers, postcodes, BTW/VAT. Use whenever generating Dutch-facing UI, content, or invoices, or when the user mentions Dutch formatting requirements.
---

# Dutch locale formatting

## Currency
- EUR with comma as decimal: `€1.234,56`
- `Intl.NumberFormat('nl-NL', { style: 'currency', currency: 'EUR' })`

## Dates
- Short: `dd-mm-yyyy` (`26-05-2026`)
- Long: `26 mei 2026`

## Phone
- Format: `+31 6 12 34 56 78` (mobile) or `+31 20 123 45 67` (landline)
- Validate: starts with `+31` or `06`, 10-11 digits total.

## Postcode
- Format: `1234 AB` (4 digits, space, 2 capitals)
- Validate regex: `/^\d{4}\s?[A-Z]{2}$/i`
```

Use case: you ask for an invoice generator — skill fires, Claude has the formatting rules in context.

## Pattern C — Persona / mode skill

A coherent stance Claude adopts when the skill fires.

```markdown
---
name: brutal-code-review
description: Run a brutally honest code review focused on real bugs and security issues, not style nitpicks. Use when the user asks for "honest review", "real review", "what's wrong with this", or after writing security-sensitive code.
---

# Brutal code review mode

Adopt this stance for the duration of the review:

- **Find real bugs.** Skip style commentary. Skip "you could maybe consider."
- **Be specific.** "Line 42 — this assumes `user` is non-null but it's optional in the type." Not "double-check null handling."
- **Rank by severity.** Security > correctness > performance > maintainability.
- **Test your claims.** If you say "this is broken," include the input that breaks it.
- **Cap the output.** 5–10 findings max. Surface the worst if there are more.
- **Don't praise.** Code review is for finding problems, not validating the author.

End with: "Highest priority to fix: <one item>. Rest can wait."
```

Use case: you say "give me a brutal review of this auth code" — skill fires, Claude adopts the stance.

## Picking a pattern

| You want… | Pattern |
|---|---|
| Repeatable multi-step procedure | A (workflow) |
| On-demand reference / lookup | B (reference) |
| Coherent stance or mode | C (persona) |

If a skill mixes two patterns, consider splitting. A "deploy audit" workflow and a "deploy reference" lookup are clearer as two skills than one hybrid.

## TL;DR

- Three patterns: workflow, reference, persona.
- One pattern per skill — split mixed ones.
- Each pattern has its own shape; copy the template that matches your need.
