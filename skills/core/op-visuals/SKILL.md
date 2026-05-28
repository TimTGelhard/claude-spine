---
name: op-visuals
description: Use when deciding whether to paste a screenshot vs text, sharing a UI bug or design reference with Claude, writing ASCII or Mermaid diagrams in project docs, sketching a UI mockup before a build session, or handling mobile / cross-platform visual comparisons. Routes to chapter 10 (visuals) of claude-spine.
---

# op-visuals — screenshots, mockups, diagrams

Claude Code is multimodal. The discipline is knowing when an image replaces a paragraph and when text is strictly better.

## File

| Question / situation | Atomic file |
|---|---|
| Should I screenshot this or paste text? How do I describe a UI bug? Mockups, ASCII vs Mermaid, mobile screenshots, before/after pairs. | `~/.claude-spine/chapters/prompting/10-visuals.md` |

## How to use

1. Read the single file. It's short enough to read in full.
2. Apply the rule: if it's text-copyable, paste text; otherwise an image with a one-line description.

## Common triggers

- "Should I screenshot the error?" → text > screenshot for errors. (See "When words beat visuals.")
- "I want to match this design." → screenshot + one-line description.
- "Help me sketch a layout before building." → ASCII mockup section.
- "Diagram for ARCHITECTURE.md?" → ASCII for Claude-readable, Mermaid for GitHub-readable.
- "It looks different on Android." → side-by-side iOS+Android screenshots.

## Sibling skills

- Prompt structure + when to add a visual reference → `op-prompting`.
- Project docs where diagrams typically live → `op-workflow` (Stage 2 — architect).
