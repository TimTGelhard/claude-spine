---
name: op-collaboration-modes
description: Use when deciding how to engage Claude for a task — whether to just say "build this" (executor), ask for an independent audit (reviewer), ask Claude to explain unfamiliar code before changing it (explainer), or get 2-3 design options with tradeoffs (planner). Also use when shifting modes mid-session (plan → build → review). Routes to chapter 07 (collaboration modes) of the Claude Code Operator's Manual.
---

# op-collaboration-modes — executor / reviewer / explainer / planner

Four ways to work with Claude. Most users default to executor. The 2x is adding planner; the 4x is adding reviewer for everything that matters.

## Index

| Question / situation | Atomic file |
|---|---|
| When is executor mode the right choice? What's the failure mode? | `/Users/macbook/claude-op-manual/chapters/workflow/07a-executor-mode.md` |
| How do I get an honest review? Why does fresh context matter? | `/Users/macbook/claude-op-manual/chapters/workflow/07b-reviewer-mode.md` |
| About to modify code I don't understand — how do I have Claude teach me? | `/Users/macbook/claude-op-manual/chapters/workflow/07c-explainer-mode.md` |
| Architectural / design question — how do I get options not opinions? | `/Users/macbook/claude-op-manual/chapters/workflow/07d-planner-mode.md` |
| How do I shift modes within a session? Which mode for which situation? | `/Users/macbook/claude-op-manual/chapters/workflow/07-mode-switching.md` |

## How to use

1. If the user is asking for code: check whether the situation actually calls for executor, or whether planner / explainer should come first.
2. If the user just shipped non-trivial work: surface reviewer mode (fresh context, subagent, or `/code-review`).
3. Read the matching atomic file. Apply its discipline.
4. For cross-mode questions ("should I plan first?"), read `07-mode-switching.md`.

## Common triggers

- "Just build X." → check 07a — is the work clear enough? Or does it want planner first?
- "Review this." → 07b (fresh-context rule, `/code-review`).
- "Explain this file / library / pattern." → 07c.
- "How should we design X?" / "What are the options?" → 07d.
- "Should I plan first or just build?" → 07-mode-switching.md.
- "Auth / payments / DB schema" → 07-mode-switching.md (high-stakes work = plan → execute → review, all three).

## Sibling skills

- The 7-stage workflow and feature sizing → `op-workflow`.
- Working with an unfamiliar codebase → `op-brownfield`.
