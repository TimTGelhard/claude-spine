---
name: op-prompting
description: Use when writing or improving a prompt, deciding how to phrase a request to Claude Code, structuring a non-trivial task (CONTEXT/TASK/CONSTRAINTS/EXAMPLES/OUTPUT), iterating after a wrong first output, or picking a high-leverage prompt pattern (orientation, challenge-me, small-fix, what's-broken, explain-it-to-me). Routes to chapter 09 of the Claude Code Operator's Manual.
---

# op-prompting — getting good output the first time

The lever with the highest ROI for output quality. The manual has three atomic files; read ONLY the one that matches the current question.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading with the Read tool. `install.sh` ensures `~/.claude-spine` resolves to your spine clone.

## Index

| Question / situation | Atomic file |
|---|---|
| What are the core rules? Why do my prompts fail? | `~/.claude-spine/chapters/prompting/09a-five-principles.md` |
| How do I structure a non-trivial prompt? When add plan mode? Iterating after a wrong output? | `~/.claude-spine/chapters/prompting/09b-prompt-structure.md` |
| Show me good vs bad on a real task. Which prompt patterns are worth memorizing? | `~/.claude-spine/chapters/prompting/09c-examples-and-anti-examples.md` |

## How to use

1. Pick ONE file — the one that matches what the user is actually deciding.
2. Read it. Apply.
3. Don't paraphrase the file back; act on it.
4. If the user is asking about screenshots, mockups, or diagrams → switch to `op-visuals`.

## Common triggers

- "How should I word this?" → 09a (principles), often enough on its own.
- "Help me write a prompt for X." → 09b (structure).
- "Show me a good vs bad prompt." → 09c.
- "What's the orientation prompt again?" → 09c.
- "I told Claude to do X and it did Y — what did I get wrong?" → 09a + 09c.
- "Should I use plan mode for this?" → 09b (plan-mode section) + `op-foundations` 04b.

## Sibling skills

- Visuals — when to paste a screenshot, ASCII diagrams, mockups → `op-visuals`.
- Proactive signaling — when *Claude* should interrupt the user → `op-signaling`.
- Model + plan/fast mode tradeoffs → `op-foundations`.
