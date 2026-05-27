# 16c — Parallel and background subagents

## Parallel subagents

When you have multiple *independent* tasks, fire them in parallel. In one assistant turn, multiple `Agent` tool calls run concurrently.

Use case: end-of-feature audit.

```
Agent 1: Code review the new auth flow (general-purpose)
Agent 2: Check RLS policies still pass two-session test (Explore)
Agent 3: Search for any TODOs/FIXMEs added this session (Explore)
```

All three return in one turn. Saves wall-clock time *and* keeps main context clean.

**Don't parallelize dependent tasks.** If agent 2's input depends on agent 1's output, do them sequentially.

## Background subagents

The `run_in_background: true` option lets you fire-and-forget. Useful when:

- The task takes minutes (running a full test suite via subagent).
- You want to continue working while it runs.

You get notified when it completes. **Don't poll.** Just keep working.

## When to parallelize vs do it inline

| Situation | Parallel? |
|---|---|
| Three independent audits at end of feature | Yes — three agents in one turn |
| Two unrelated searches | Yes — but `grep` may beat agents for one-shots |
| Sequential steps in a workflow | No — write a single agent prompt |
| Agent 2 needs agent 1's output | No — chain them |
| One-shot 10-second task | No — just do it inline |

## Anti-patterns

- **"Just spawn a subagent to do the whole feature."** Subagents are bad at multi-decision work — you can't course-correct. They're for bounded tasks.
- **Subagent doing what TaskCreate could do.** Tracking progress within your own session isn't subagent work.
- **Re-reading the subagent's findings yourself anyway.** If you don't trust the summary, the delegation didn't save you context. Trust the summary or don't delegate.
- **Spawning a subagent inside another subagent.** It works, but it's almost always a sign you should restructure.
- **Sleep-polling a background subagent.** You'll be notified — keep working.

## Plan-aware fan-out budget

Before proposing 2+ parallel agents, read the user's `~/.claude/claude-spine-profile.md → Subscription → Plan:` and apply the row in [`19f-subscription-aware.md`](../personalization/19f-subscription-aware.md) (lever 3 — parallel subagents). Free / Pro plans burn quota fast on fan-out; Max plans absorb it. The table:

- **Free:** avoid parallel fan-out; one subagent at a time.
- **Pro:** up to 2 parallel; flag at 3+.
- **Max (5×):** up to 4 parallel; flag at 5+.
- **Max (20×):** no soft cap; fan-out is the default for breadth-first work.

Default to the Pro row if the profile is missing. `Cost sensitivity = Very careful` shifts one tier cheaper. Don't gate — the user can override; the table just sets the right default.

## TL;DR

- Independent tasks → parallel agents in one turn.
- Long-running tasks → background, get notified on completion.
- Don't poll. Don't nest unnecessarily. Don't re-do the agent's work.
- If the summary isn't trustworthy, the brief was wrong — fix the brief, don't second-guess the result.
- Check the user's plan before fanning out 2+ agents — see [`19f-subscription-aware.md`](../personalization/19f-subscription-aware.md).
