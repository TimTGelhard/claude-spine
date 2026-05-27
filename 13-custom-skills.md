> **DEPRECATED** — v2 atomic version: [`chapters/persistence/`](chapters/persistence/). Full v1→v2 map: [`V1-CHAPTERS-DEPRECATED.md`](V1-CHAPTERS-DEPRECATED.md). Body kept for cross-reference.

# 13 — Custom skills: writing your own

Chapter 12 covered what skills are and when to use them. This chapter is the *deep* version: how to actually write good ones.

Most users never write custom skills. The ones who do get a force multiplier — repeatable workflows triggered automatically when relevant, without bloating context.

## What a skill actually is, mechanically

A skill is a markdown file with frontmatter, stored in:

- `~/.claude/skills/<skill-name>/SKILL.md` — global, available in every project.
- `<project>/.claude/skills/<skill-name>/SKILL.md` — project-only.

Claude Code scans for skills at session start, reads the frontmatter (especially the `description`), and *lazily loads* the full body only when the description matches what the user is asking about.

```markdown
---
name: client-site-deploy
description: Deploy a static client website to the production VPS. Use when deploying any project under the client-site stack, or when the user mentions VPS deployment or going live with a client site.
---

# Deploy to VPS

[multi-step procedure here]
```

That's the whole anatomy. The magic is the description — it's the trigger.

## The description is the trigger

This is the part everyone gets wrong. The `description` field is what Claude matches against to decide whether to load the skill.

**Bad descriptions:**
- "Helps with deployment." — too vague, fires on every deploy of anything.
- "My custom deploy script." — describes the artifact, not the trigger.
- "Use this." — useless.

**Good descriptions:**
- "Deploy a static client website to the production VPS. Use when deploying any client-site project, or when the user says 'go live' on a client site."
- "Run a security audit of a Supabase project — RLS policies, leaked secrets, service_role usage. Use after schema changes or before a production deploy."
- "Generate a locale-aware invoice PDF following the user's regional VAT requirements. Use when creating or modifying invoice generation code."

The rule: **write the description so Claude can decide whether to use this skill from the description alone.** Include:
- What it does.
- What triggers (keywords, situations, file types) should cause it to fire.
- What it's NOT for (when triggers might be ambiguous).

Test it: if you read the description in isolation, would you know when to invoke it? If no, rewrite.

## When a skill is the right answer

| Situation | Skill? |
|-----------|--------|
| Multi-step procedure you do across projects | ✅ Yes |
| Project-specific procedure | Maybe — could be project-level CLAUDE.md instead |
| One-off task | ❌ No |
| Information that should be in context every session | ❌ No — that's CLAUDE.md |
| Behavior you want by default (style preferences, etc.) | ❌ No — that's CLAUDE.md |
| Step-by-step you'd otherwise paste into every relevant session | ✅ Yes |
| Reference doc you want consulted on demand | ✅ Yes |
| A persona or mode of work | Maybe — if it's a coherent stance |

**Strongest signal it's a skill:** you've pasted the same instructions into Claude 3+ times for similar tasks. That's a skill waiting to be written.

## Skill design patterns

Three patterns cover most useful skills.

### Pattern A — Workflow skill

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
7. **Report**: bullet-list pass/fail for each. If all pass, give a one-line go-ahead.

Don't deploy. Just audit.
```

Use case: you ask "ready to deploy?" — skill loads, runs the audit, reports.

### Pattern B — Reference skill

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
- `Intl.DateTimeFormat('nl-NL', { dateStyle: 'long' })`

## Phone
- Format: `+31 6 12 34 56 78` (mobile) or `+31 20 123 45 67` (landline)
- Validate: starts with `+31` or `06`, 10-11 digits total.

## Postcode
- Format: `1234 AB` (4 digits, space, 2 capitals)
- Validate regex: `/^\d{4}\s?[A-Z]{2}$/i`

## BTW / VAT
- High: 21% (most goods/services)
- Low: 9% (food, books, transport)
- VAT-free: medical, education
- Invoice must show BTW number, KvK number, separated subtotals
```

Use case: you ask for an invoice generator — skill fires, Claude has the formatting rules in context.

### Pattern C — Persona / mode skill

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
- **Rank by severity.** Security > correctness > performance > maintainability. Don't bury a SQL injection under a naming nitpick.
- **Test your claims.** If you say "this is broken," include the input that breaks it. If you can't construct one, soften to "might be broken."
- **Cap the output.** 5-10 findings max. If there are more, surface the worst and say there are others.
- **Don't praise.** Code review is for finding problems, not validating the author.

End with: "Highest priority to fix: <one item>. Rest can wait."
```

Use case: you say "give me a brutal review of this auth code" — skill fires, Claude adopts the stance.

## What goes in the body

Two principles:

1. **Be specific.** "Use Tailwind" is weak. "Use Tailwind utilities only; no @apply, no custom CSS classes" is strong.
2. **Order the steps.** If it's a workflow, number them. If it's a checklist, bullet them. If it's reference, group by topic.

The body is loaded when the skill fires, so it competes for context. Keep it tight — 50-200 lines is normal. >300 means it should probably be a project doc instead.

## The skill-creator skill

You have a `skill-creator` skill installed. Use it to write new skills.

> "Create a skill called `pre-deploy-audit` that runs the checks in `docs/DEPLOY.md` and reports pass/fail. Trigger on 'deploy' / 'ship' / 'production' keywords."

The skill-creator:
- Picks the right file location.
- Writes correctly-shaped frontmatter.
- Validates the description against common pitfalls.
- Can also benchmark a skill's trigger accuracy if you ask.

Don't hand-write skills from memory. Frontmatter syntax has gotcha cases (multiline descriptions, allowed-tools format) and the skill-creator stays current.

## Naming and organization

- **Names**: short, kebab-case, scoped if needed. `client-site-deploy` not `deploy`. `locale-rules-nl` not `locale`.
- **Global vs project**: workflow that crosses projects → global. Project-specific → project's `.claude/skills/`.
- **Don't over-scope project skills.** If a skill is project-specific *and* the procedure is small, it might just belong in the project's `CLAUDE.md`.

## When skills fire (and when they don't)

Claude loads a skill when the user's request seems to match the description. If your skill isn't firing when you expect:

1. **Test the trigger.** Read the description. Would *you* match it to your prompt? If unclear, tighten.
2. **Use the skill-creator's eval feature.** It can benchmark a skill's trigger accuracy against test prompts.
3. **Make triggers explicit.** Mention specific keywords in the description: "Use when the user says 'deploy', 'ship', 'go live', or 'production release'."

Common mistakes:
- **Too generic description** → fires on everything, becomes noise.
- **Too narrow description** → never fires when needed.
- **Description describes the artifact, not the trigger** → "this is a helper for X" doesn't tell Claude when to load it.

## Cost and context

Skills are *lazy* — they don't burn context until loaded. So:

- Having 20 skills is fine.
- Having 5 skills that *all* match every prompt = expensive. They all load.

Test by checking: in a typical session, how many skills are firing? If "many," tighten descriptions.

## Maintaining skills

Like CLAUDE.md, skills rot. Audit periodically:

- **Does this still fire when expected?** If not, fix the description.
- **Is the content still accurate?** Library APIs change.
- **Am I using it?** If a skill hasn't fired in 6 months, delete it.

A graveyard of unused skills is overhead. Prune.

## Skills you might consider writing

Typical for solo-founder / agency / MVP work:

- `client-site-deploy` — VPS deploy procedure with Lighthouse + accessibility gates.
- `locale-rules-<your-locale>` — formatting reference (per Pattern B above).
- `pre-deploy-audit` — checklist runner for any project.
- `supabase-rls-check` — automated RLS audit for a project.
- `mvp-launch-checklist` — pre-public-launch gates (auth, delete-account, privacy policy, error monitoring).
- `client-handover` — generate the standard client handover doc (login info, deploy process, ongoing maintenance notes).
- `brutal-code-review` — Pattern C example.

Don't write all of them. Write the one or two that match a procedure you've actually pasted into Claude 3+ times.

## Anti-patterns

- **Writing skills speculatively.** "Maybe I'll need this someday." Write when the procedure has earned itself, not before.
- **Vague descriptions** → skills don't fire or fire wrong.
- **Long unfocused skills.** A skill that does five things probably should be three skills.
- **Skills that compete with CLAUDE.md.** If it should apply every session, it's CLAUDE.md.
- **Skills that compete with hooks.** If it's a deterministic command, it's a hook.

## TL;DR

- Skills = lazy-loaded markdown with a description trigger.
- The description is the most important field. Be specific about what triggers it.
- Three patterns: workflow, reference, persona.
- Use the `skill-creator` skill to write them — don't hand-edit from memory.
- Write skills *after* you've copy-pasted the same prompt 3+ times.
- Audit periodically — delete what doesn't fire, tighten what fires wrong.
