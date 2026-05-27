> **DEPRECATED** — v2 atomic version: [`chapters/workflow/`](../../chapters/workflow/). Full v1→v2 map: [`V1-CHAPTERS-DEPRECATED.md`](../../V1-CHAPTERS-DEPRECATED.md). Body kept for cross-reference.

# 07 — Collaboration modes: how you use Claude matters as much as what you ask

Most users have one mode: **executor** — "do this for me." That mode has its place, but it's one of four. Switching deliberately between them is the 4x most users never realize they have.

## The four modes

| Mode | One-liner | When |
|------|-----------|------|
| **Executor** | "Do this thing." | When you know what to build and want it built. |
| **Reviewer** | "Audit this. Find problems." | After building, before shipping. Independent perspective. |
| **Explainer** | "Teach me this. Why does this work?" | When you're about to touch code you don't understand. |
| **Planner** | "Help me design this. What are the options?" | Before building anything non-trivial. |

You probably default to **executor** because it produces visible output fast. But the highest-leverage moves often come from the other three.

## Executor mode

The default. You say what to build, Claude builds it.

**When it's right:**
- Clear, well-defined task.
- You can describe what "done" looks like.
- The decisions are settled.

**Prompting pattern:**
```
[CONTEXT] We're on the quotes list page.
[TASK] Add a status filter dropdown above the table.
[CONSTRAINTS] Tailwind only, server component, no new deps.
[OUTPUT] Edit app/quotes/page.tsx.
```

**Failure modes:**
- Using executor mode when you should have planned first → builds the wrong thing.
- Using executor mode for code you don't understand → ships code you can't maintain.

**Signal you're in the wrong mode:**
- "Just build something, let's see how it looks" → you wanted planner.
- "Why does this work?" — but you're asking *after* it's built → you wanted explainer earlier.

## Reviewer mode

You give Claude something built (yours, Claude's, or someone else's) and ask for an independent audit.

**When it's right:**
- Before shipping a meaningful change.
- After Claude built something — especially with code you didn't read carefully.
- After inheriting a codebase.
- Periodically, on the parts of your code you're least sure about.

**Critical:** use a *fresh* context for review. A Claude that just wrote the code is biased toward defending it. Open a new terminal, paste the code, ask for a review. Or spawn a subagent for the audit — independent context = honest critique.

**Prompting pattern:**
```
Review this server action: <paste or file path>.

Look specifically for:
- Auth/RLS issues (does this trust client input it shouldn't?).
- Error handling — what happens on each failure path?
- Race conditions if two of these fire concurrently.
- Things that compile but won't survive prod load.

Give me a punch list. Be direct — name what's wrong, not what could maybe be improved.
```

**The `code-review` skill exists for this.** Use it (`/code-review`). It scopes itself to a diff.

**Failure modes:**
- Reviewing in the same session that wrote the code → biased "looks good to me."
- Vague reviews ("how does this look?") → vague feedback.
- Skipping review for "small" changes → small changes break prod most often.

## Explainer mode

You point Claude at code (yours, library, framework) and ask for understanding.

**When it's right:**
- About to modify code you didn't write or don't remember.
- Learning a new library/framework you're using.
- Debugging — understanding the actual behavior before guessing fixes.
- Onboarding back into an old project.

**Prompting pattern:**
```
Walk me through `app/api/webhooks/stripe/route.ts` like I'm new to the project.

For each section:
- What does it do?
- What does it depend on (other files, env vars, Stripe state)?
- What invariants does it assume?
- What would break it?

Be specific. I'd rather you say "I don't know" than guess.
```

**Or, for a concept:**
```
Explain Supabase RLS like I understand Postgres but not the Supabase-specific layer.
What's the actual security model? Where does it fail open? Where does it fail closed?
Give me a worked example with a misconfigured policy.
```

**The trick:** ask for *invariants and failure modes*, not just "what it does." That's where understanding lives. "What it does" you can read.

**Failure modes:**
- Treating Claude's explanation as ground truth without verifying → it can confidently misexplain.
- Skipping explainer mode and jumping to "fix it" → fixing without understanding is gambling.

## Planner mode

You describe a problem; Claude proposes 2-3 ways to solve it with tradeoffs.

**When it's right:**
- Architectural decisions (schema, route shape, state management approach).
- Non-trivial features (>3 files, multiple concerns).
- Anything where "Claude picks wrong" costs hours of rework.
- When *you're* not sure — outsource the option-generation.

**Prompting pattern:**
```
I need to design the quote-acceptance flow. Customer gets an email link, opens
on their phone (not logged in), can accept or reject.

Don't build yet. Give me 2-3 genuinely different options with honest tradeoffs:
- Single-use token in URL.
- Magic link that auto-creates a customer auth session.
- Stateless signed-URL approach.

For each: how it works, what it commits us to, the downside I should worry about.
Pick the one you'd recommend at the end and say why.
```

**Use plan mode (the tool) for this** when the work is large enough — Claude proposes, you approve, then it executes. Friction up front saves rework after.

**The `Plan` subagent** is built for this. Spawn it for architectural questions; it returns structured plans.

**Failure modes:**
- Asking "what should I do?" without describing constraints → useless options.
- Accepting the first option without pushing back → defeats the point of planning.
- Planning forever, never building → planning is a tool, not a destination.

## Mode-shifting patterns

The advanced move is **shifting modes within a session.**

### The build → review shift
After building a non-trivial feature in executor mode, switch to reviewer (fresh context):
> Spawn a subagent to review the diff for the auth changes in this session.

The subagent has no attachment to the work and can be honest.

### The explain → execute shift
Before modifying unfamiliar code:
> First, explain what `lib/server/pdf-generator.ts` does. After I confirm I understand, *then* we'll modify it.

Don't let yourself skip the explanation step. The 5 minutes you spend understanding prevents the 2 hours of debugging downstream.

### The plan → execute shift
For any feature touching auth, payments, or DB schema:
> Plan this first. Give me options. After I pick, we'll build.

Hard rule for high-stakes work: plan before execute, always.

### The execute → explain shift
You shipped something fast in executor mode. Before the session ends:
> Now walk me through what we just built. What's load-bearing, what's flexible, what's a known compromise?

This is the antidote to "I shipped Claude-built code I don't understand." Five minutes per session; massive long-term payback.

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
| Touching auth/payments/schema | Planner → Executor → Reviewer (all three) |

Most people stop at executor. The 2x is adding planner. The 4x is adding reviewer for everything that matters.

## Mode-shifting cadence by session length

A well-shaped 90-minute session might look like:

```
0-5 min:    Orient (explainer for the project: where are we?)
5-15 min:   Plan (planner: what are we building, what are options?)
15-75 min:  Build (executor: do the thing)
75-85 min:  Verify (executor with verification framing)
85-90 min:  Review (reviewer: subagent audit of the diff)
           Wrap (explainer of what we built, before commit)
```

You don't always do all five. But noticing which mode you're in is the discipline.

## Mode-shifting anti-patterns

- **All-executor sessions.** You move fast and ship debt.
- **Planning forever.** Plans don't ship features. Set a planning time-box.
- **Reviewing in the building session.** Biased. Use a fresh context or subagent.
- **Explainer mode without verification.** Claude can confidently misexplain. Cross-check with the actual code.
- **Skipping reviewer mode on "small" changes.** Small changes to security-critical code are the highest-risk class.

## How the modes affect prompting

The same task, four modes:

**Executor:** "Add a status filter to the quote list."
**Planner:** "I want to filter quotes by status. What are the options — URL params, client state, server-side query? Tradeoffs?"
**Reviewer:** "Review this status filter implementation. Edge cases?"
**Explainer:** "How does this status filter actually work? What happens on initial page load?"

Same code area. Four different conversations, four different outputs, four different values.

## TL;DR

- Four modes: executor, reviewer, explainer, planner. Most users default to executor.
- Switch modes deliberately based on what you actually need.
- Reviewer mode wants *fresh context* — use a subagent or new terminal.
- Explainer mode before modifying unfamiliar code. Five minutes saves hours.
- Planner mode before any non-trivial build. Friction up front saves rework.
- Mode-shifting within a session is the advanced pattern. Plan → execute → review for anything that matters.
