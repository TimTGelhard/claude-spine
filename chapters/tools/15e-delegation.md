# 15e — Delegation: the Agent tool

The `Agent` tool spins up a fresh Claude with its own context and tool access, runs your prompt, returns a single summary message. This file covers the *tool itself*. For the deeper "when delegation wins / loses" decision, see [16a](../subagents/16a-when-to-delegate.md).

## Agent types you have

| Type | What for |
|---|---|
| `general-purpose` | Default. Multi-step research and tasks. Has all tools. |
| `Explore` | Read-only search. Fast file-finding, grep, "where is X." |
| `Plan` | Architectural planning. Returns a step-by-step plan. |
| `code-reviewer` (if available) | Independent code review. |

For most work, `Explore` for "where is X" and `general-purpose` for "do this for me" cover 90%+.

## Anatomy of an Agent call

- `subagent_type` — which agent (above).
- `description` — short label (3–5 words) for telemetry.
- `prompt` — the full brief. Self-contained.
- `run_in_background` — fire and forget; you'll be notified on completion.

## Writing the prompt

A subagent has no context. Your prompt must contain:

1. **What it's doing** — the goal.
2. **Why it matters** — so it can make judgment calls.
3. **What it should report back** — and how long.
4. **Any constraints** — what NOT to do (e.g., "report only, don't edit").

**Bad:**

> Find auth bugs

**Good:**

> Audit `app/api/**` for auth issues. Context: Next.js + Supabase MVP. Look for: (1) routes that don't check session, (2) service_role used outside `*.server.ts`, (3) routes accepting user input without zod validation. Report findings as a punch list with file:line. Under 300 words. Don't edit anything.

## Parallel delegation

Multiple `Agent` calls in one assistant turn run concurrently. Use for independent tasks:

- Agent 1: Code review the new auth flow.
- Agent 2: Check RLS policies pass two-session test.
- Agent 3: Search for TODOs added this session.

All three return in one turn. Saves wall-clock *and* keeps main context clean.

**Don't parallelize dependent tasks.** If agent 2 needs agent 1's output, run sequentially.

## Background delegation

`run_in_background: true` lets you fire-and-forget for tasks taking minutes (full test suite via subagent, big log analysis). You get notified when it completes. **Don't poll.**

## TL;DR

- Pick the type: `Explore` (search), `general-purpose` (do), `Plan` (architect).
- Brief like the agent has no context — because it doesn't.
- Parallel independent agents = single turn, multiple wins.
- Background for minute-long tasks; don't poll.
- When to delegate vs do it yourself → [16a](../subagents/16a-when-to-delegate.md).
