---
name: op-foundations
description: Use when asking how Claude Code actually works under the hood, how the LLM loop and tools combine, what the three levers (context / scope / verification) are, why quality drops mid-session (drift / dilution / hallucination), how the 1M context window degrades before it fills, when to start a fresh terminal, what Claude genuinely can't do, which project types fit, which model (Opus / Sonnet / Haiku) to pick, when plan mode or fast mode is worth it, or how plan budgets and context cost work. To *recover* a session that's already degrading mid-flight (rather than understand why a failure mode happens), that's op-recovery. Routes to the foundations chapters (01–04) of claude-spine.
---

# op-foundations — foundations of Claude Code

The manual has atomic files for each foundational concept. Read ONLY the one that matches the question — don't load the whole folder.

## Index

| Question / situation | Atomic file |
|---|---|
| How does Claude Code actually work? What's the loop? | `~/.claude-spine/chapters/foundations/01a-llm-loop.md` |
| What are the three levers on output quality? | `~/.claude-spine/chapters/foundations/01b-three-levers.md` |
| Why is Claude drifting / hallucinating / losing focus? Which failure mode is this? | `~/.claude-spine/chapters/foundations/01c-failure-modes.md` |
| How does the 1M context window really behave? When do I restart? | `~/.claude-spine/chapters/foundations/02-context-budget.md` |
| What can Claude *not* do, structurally? | `~/.claude-spine/chapters/foundations/03a-hard-limits.md` |
| What does Claude do unreliably (debugging state, perf, multi-process)? | `~/.claude-spine/chapters/foundations/03b-soft-limits.md` |
| Does this project type fit Claude well? Warning signs we've hit a limit? | `~/.claude-spine/chapters/foundations/03c-project-fit.md` |
| Which model — Opus, Sonnet, Haiku — for this task? | `~/.claude-spine/chapters/foundations/04a-model-tiers.md` |
| Is plan mode / fast mode worth using here? | `~/.claude-spine/chapters/foundations/04b-plan-and-fast-mode.md` |
| Plan budget, context cost discipline, when NOT to use Claude Code | `~/.claude-spine/chapters/foundations/04c-budget-and-cost.md` |
| Should this recommendation shift based on the user's Claude subscription? | `~/.claude-spine/chapters/personalization/19f-subscription-aware.md` |

## How to use

1. Pick ONE file from the index — the one that matches the user's question.
2. Read it. Apply its discipline to the current decision.
3. Don't paraphrase the file back; act on it.
4. If the question spans two files (e.g., model choice + context cost), prefer the more specific one and reference the other in one line.

## Common triggers

- "Why is Claude getting confused / forgetting things?" → 01c (failure modes)
- "How big can my session get?" / "should I restart?" → 02
- "Can Claude do X?" (capability check) → 03a or 03b
- "Should I use Opus for this?" → 04a, then check 19f for the plan-conditional recommendation
- "Worth using plan mode?" → 04b
- "I'm burning through my plan budget" → 04c, then 19f for plan-specific guidance

When the recommendation has a cost / quota / model component, **read 19f and branch on the user's `Plan:` and `Cost sensitivity:` fields** before answering. Default to the Pro row if the profile is missing.
