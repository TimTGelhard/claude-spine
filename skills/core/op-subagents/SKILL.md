---
name: op-subagents
description: Use when deciding whether to delegate to a subagent (Agent tool) vs do work inline, writing a subagent prompt, picking an agent type (general-purpose / Explore / Plan / custom), running parallel or background agents, designing a custom subagent in ~/.claude/agents/, or evaluating whether an orchestrator-with-specialists pattern fits the task. Routes to chapter 16 (subagents) of claude-spine.
---

# op-subagents — when to delegate

The biggest underused lever for keeping main-conversation context clean. Routes here pick the file that matches the decision in front of you.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading with the Read tool. `install.sh` ensures `~/.claude-spine` resolves to your spine clone.

## Index

| Question / situation | Atomic file |
|---|---|
| Should I delegate this or do it inline? How to brief a subagent? | `~/.claude-spine/chapters/subagents/16a-when-to-delegate.md` |
| Which agent type — general-purpose / Explore / Plan / custom? When write a custom subagent? Orchestrator trap? | `~/.claude-spine/chapters/subagents/16b-agent-types.md` |
| Parallel agents in one turn, background subagents, anti-patterns | `~/.claude-spine/chapters/subagents/16c-parallel-and-background.md` |
| How many parallel subagents is OK on this user's plan? | `~/.claude-spine/chapters/personalization/19f-subscription-aware.md` |

## How to use

1. "Should I delegate this?" → 16a.
2. "Which type?" → 16b.
3. "Can I run these in parallel / background?" → 16c.
4. If the user is asking about the `Agent` *tool mechanics* (call shape, options) rather than the decision → `op-tools` 15e covers that.

## Common triggers

- "Should I subagent this?" → 16a.
- "Write me a subagent prompt for X." → 16a (good prompt rules).
- "Should I build an orchestrator with 7 specialists?" → 16b (orchestrator trap — almost always no for solo work).
- "Can I run these audits in parallel?" → 16c, then 19f for the per-plan fan-out budget.
- "Why doesn't my subagent know about Y?" → 16a (no context = brief like it has none).

Before recommending parallel fan-out of 2+ agents, **read 19f and the user's `Plan:` field**. Free / Pro burn through quota fast on fan-out; Max plans absorb it. Default to the Pro row if the profile is missing.

## Sibling skills

- `Agent` tool mechanics (calling shape, options) → `op-tools` 15e.
- Skill-creator for writing custom subagent frontmatter → use the `/skill-creator` slash command.
- Recovery when a subagent returned junk → `op-recovery` (chapter 17).
