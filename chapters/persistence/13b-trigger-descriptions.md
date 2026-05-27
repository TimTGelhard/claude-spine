# 13b — Trigger descriptions: making skills fire

The `description` field is what Claude matches against to decide whether to load the skill. This is the part everyone gets wrong.

## Bad vs good descriptions

**Bad:**

- "Helps with deployment." → too vague, fires on every deploy of anything.
- "My custom deploy script." → describes the artifact, not the trigger.
- "Use this." → useless.

**Good:**

- "Deploy a static client website to the production VPS. Use when deploying any client-site project, or when the user says 'go live' on a client site."
- "Run a security audit of a Supabase project — RLS policies, leaked secrets, service_role usage. Use after schema changes or before a production deploy."
- "Generate a locale-aware invoice PDF following the user's regional VAT requirements. Use when creating or modifying invoice generation code."

## The rule

**Write the description so Claude can decide whether to use this skill from the description alone.** Include:

- What it does.
- What triggers (keywords, situations, file types) should cause it to fire.
- What it's NOT for (when triggers might be ambiguous).

Test it: if you read the description in isolation, would *you* know when to invoke it? If no, rewrite.

## Common mistakes

- **Too generic** → fires on everything, becomes noise. ("Helps with deployment.")
- **Too narrow** → never fires when needed. ("Use only when deploying the Solvero marketing page on a Tuesday.")
- **Describes the artifact, not the trigger** → "this is a helper for X" doesn't tell Claude when to load it.
- **No examples of triggering phrases** → Claude can't pattern-match against user intent.

## Make triggers explicit

Mention specific keywords in the description:

> "Use when the user says 'deploy', 'ship', 'go live', or 'production release'."

More reliable than abstract phrasing like "use when relevant to deployment."

## When a skill isn't firing

1. **Test the trigger.** Read the description in isolation. Would *you* match it to your prompt? If unclear, tighten.
2. **Use the skill-creator's eval feature.** It can benchmark a skill's trigger accuracy against test prompts.
3. **Add explicit keywords.** If the user says "ship" but your description only mentions "deploy," the match might miss.

## Why this matters for libraries

If you're maintaining a *library* of skills (like the manual you're reading right now), trigger quality is the difference between a useful router and a noisy disaster. Each skill needs to fire exactly when relevant — and stay silent otherwise. See [13d](13d-skill-anti-patterns.md) for the design discipline that makes a skill library age well.

## TL;DR

- The description is the trigger. Treat it as the most important field.
- Specific situations + keywords + counter-examples = good description.
- Test in isolation: would you know when to fire it from the description alone?
- Use the `skill-creator` eval to benchmark when in doubt.
