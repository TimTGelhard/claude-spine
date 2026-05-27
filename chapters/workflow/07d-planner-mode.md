# 07d — Planner mode

You describe a problem; Claude proposes 2–3 ways to solve it with honest tradeoffs.

## When it's right

- Architectural decisions (schema, route shape, state management approach).
- Non-trivial features (>3 files, multiple concerns).
- Anything where "Claude picks wrong" costs hours of rework.
- When *you're* not sure — outsource the option-generation.

## Prompting pattern

```
I need to design the quote-acceptance flow. Customer gets an email
link, opens on their phone (not logged in), can accept or reject.

Don't build yet. Give me 2-3 genuinely different options with
honest tradeoffs:
- Single-use token in URL.
- Magic link that auto-creates a customer auth session.
- Stateless signed-URL approach.

For each: how it works, what it commits us to, the downside I
should worry about. Pick the one you'd recommend at the end
and say why.
```

## Plan mode (the tool) vs planner mode (the conversation)

Two related things:

- **Planner mode** is a *conversation shape* — Claude proposes options, you push back, you converge.
- **Plan mode** is a *tool state* — Claude proposes the full plan, you approve via `ExitPlanMode`, then it executes.

Use plan mode when the work is large enough to benefit from explicit approval before edits start. See [04b-plan-and-fast-mode.md](../foundations/04b-plan-and-fast-mode.md).

For pure design conversations (no code to write yet), stay in planner mode without invoking plan mode.

## The `Plan` subagent

For architectural questions you want answered with full context-isolation, spawn the `Plan` subagent. It returns a structured plan with critical files identified and tradeoffs surfaced. See [16b-agent-types.md](../subagents/16b-agent-types.md).

## Failure modes

- **Asking "what should I do?" without describing constraints.** Useless options. State the goal, the constraints, and what's out of bounds.
- **Accepting the first option without pushing back.** Defeats the point of planning. Make Claude defend the recommendation.
- **Planning forever, never building.** Planning is a tool, not a destination. Time-box the planning conversation.

## Anti-pattern: fake planner mode

The bad version of this:

```
Should we do A or B?
```

Claude says "A," you say "OK do it." That's executor with a thin pretext. Real planner mode forces 2–3 options *with the downsides named*, then makes Claude pick and justify.

## TL;DR

- Use planner before any non-trivial build. Friction up front saves rework after.
- 2–3 genuinely different options, honest tradeoffs, a recommendation with reasoning.
- Plan mode (the tool) when the work is big enough to want explicit approval before edits.
