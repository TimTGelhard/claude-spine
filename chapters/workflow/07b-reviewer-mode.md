# 07b — Reviewer mode

You give Claude something built (yours, Claude's, or someone else's) and ask for an independent audit.

## When it's right

- Before shipping a meaningful change.
- After Claude built something — especially code you didn't read carefully.
- After inheriting a codebase.
- Periodically, on the parts of your code you're least sure about.

## The fresh-context rule

**Critical:** use a *fresh* context for review. A Claude that just wrote the code is biased toward defending it. Two ways to get fresh context:

1. **Open a new terminal**, paste the code or hand over the file path, ask for a review.
2. **Spawn a subagent** for the audit. Independent context = honest critique. See [16a-when-to-delegate.md](../subagents/16a-when-to-delegate.md).

The build-session Claude is the *worst* reviewer of its own work.

## Prompting pattern

```
Review this server action: <paste or file path>.

Look specifically for:
- Auth/RLS issues (does this trust client input it shouldn't?).
- Error handling — what happens on each failure path?
- Race conditions if two of these fire concurrently.
- Things that compile but won't survive prod load.

Give me a punch list. Be direct — name what's wrong,
not what could maybe be improved.
```

## The `/code-review` slash command exists for this

`/code-review` scopes itself to a diff and runs Anthropic-tested review prompts. Use it. Variants:

- `/code-review` — low/medium effort, fewer high-confidence findings.
- `/code-review high` — broader coverage, may include uncertain findings.
- `/code-review ultra` — heavyweight multi-agent cloud review (user-triggered only).
- `/code-review --fix` — apply the findings to the working tree.

See [15i-slash-commands.md](../tools/15i-slash-commands.md).

## Failure modes

- **Reviewing in the same session that wrote the code.** Biased "looks good to me."
- **Vague reviews** ("how does this look?"). Vague feedback. Name the specific risks you want checked.
- **Skipping review for "small" changes.** Small changes break prod most often — they get less scrutiny.

## TL;DR

- Reviewer mode wants fresh context. New terminal or subagent.
- `/code-review` is the slash-command default; reach for it before ad-hoc review.
- Be specific about what you want checked — vague prompts produce vague reviews.
