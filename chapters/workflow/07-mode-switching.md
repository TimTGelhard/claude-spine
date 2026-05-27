# 07 — Mode-switching: the advanced collaboration pattern

Four collaboration modes — executor, reviewer, explainer, planner. Most users default to executor. The 2x is adding planner. The 4x is adding reviewer for everything that matters.

The advanced pattern is **shifting modes within a single session.**

## Choosing the right mode

When you're about to ask Claude for help, pause for 5 seconds and pick:

| Situation | Mode |
|-----------|------|
| Bug in code I wrote, obvious cause | Executor |
| Bug in code I wrote, not obvious | Explainer first (understand), then executor (fix) |
| Bug in code Claude wrote, I don't really get | Explainer, then maybe rewrite |
| New feature, clear shape | Executor |
| New feature, multiple ways to do it | Planner first, then executor |
| Code I might ship, written this session | Reviewer (fresh context) |
| Coming back to an old project | Explainer (orientation) |
| Architectural question | Planner |
| Just want code fast, low-stakes | Executor |
| Touching auth / payments / schema | Planner → Executor → Reviewer (all three) |

Most people stop at executor. The 2x is adding planner. The 4x is adding reviewer for everything that matters.

## Mode-shifting within a session

### Build → review

After building a non-trivial feature in executor mode, switch to reviewer (fresh context):

> Spawn a subagent to review the diff for the auth changes in this session.

The subagent has no attachment to the work and can be honest.

### Explain → execute

Before modifying unfamiliar code:

> First, explain what `lib/server/pdf-generator.ts` does. After I confirm I understand, *then* we'll modify it.

Don't let yourself skip the explanation step. The 5 minutes you spend understanding prevents the 2 hours of debugging downstream.

### Plan → execute

For any feature touching auth, payments, or DB schema:

> Plan this first. Give me options. After I pick, we'll build.

Hard rule for high-stakes work: plan before execute, always.

### Execute → explain

You shipped something fast in executor mode. Before the session ends:

> Now walk me through what we just built. What's load-bearing, what's flexible, what's a known compromise?

This is the antidote to "I shipped Claude-built code I don't understand." Five minutes per session; massive long-term payback.

## Cadence by session length

A well-shaped 90-minute build session might look like:

```
0-5 min:    Orient (explainer for the project: where are we?)
5-15 min:   Plan (planner: what are we building, what are options?)
15-75 min:  Build (executor: do the thing)
75-85 min:  Verify (executor with verification framing)
85-90 min:  Review (reviewer: subagent audit of the diff)
            Wrap (explainer of what we built, before commit)
```

You don't always do all five. But noticing which mode you're in is the discipline.

## How the same task looks in each mode

The same area of code, four prompts:

- **Executor:** "Add a status filter to the quote list."
- **Planner:** "I want to filter quotes by status. URL params, client state, server query — tradeoffs?"
- **Reviewer:** "Review this status filter implementation. Edge cases?"
- **Explainer:** "How does this status filter actually work? What happens on initial page load?"

Same code area. Four different conversations, four different outputs, four different values.

## Anti-patterns

- **All-executor sessions.** You move fast and ship debt.
- **Planning forever.** Plans don't ship features. Set a planning time-box.
- **Reviewing in the building session.** Biased. Use a fresh context or subagent.
- **Explainer mode without verification.** Claude can confidently misexplain — cross-check with the actual code.
- **Skipping reviewer mode on "small" changes.** Small changes to security-critical code are the highest-risk class.

## TL;DR

- Four modes, switch deliberately.
- High-stakes work (auth, payments, schema) = planner → executor → reviewer.
- Mode-shifting within a session is the advanced pattern. Five minutes of explainer or planner saves hours of executor rework.
