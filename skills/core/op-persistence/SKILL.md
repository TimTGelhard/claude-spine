---
name: op-persistence
description: Use when deciding where Claude should remember something (CLAUDE.md / skill / memory / project doc), writing or editing a CLAUDE.md file, authoring a custom skill, designing a skill's trigger description, choosing between skill / hook / CLAUDE.md for "always do X" behavior, or auditing a personal skill library for rot. Routes to chapters 12 and 13 of the Claude Code Operator's Manual.
---

# op-persistence — CLAUDE.md, skills, and memory

The three layers that persist between sessions. Routes here pick exactly one file — load only what you need.

## Index

| Question / situation | Atomic file |
|---|---|
| Where does this thing go — CLAUDE.md / skill / memory / project doc? | `/Users/macbook/claude-op-manual/chapters/persistence/12a-three-layers-overview.md` |
| Writing or editing CLAUDE.md (global or project)? | `/Users/macbook/claude-op-manual/chapters/persistence/12b-claudemd.md` |
| Memory — what to save, what NOT to save, how Claude writes it | `/Users/macbook/claude-op-manual/chapters/persistence/12c-memory.md` |
| What a skill is, mechanically — file shape, where to put it | `/Users/macbook/claude-op-manual/chapters/persistence/13a-skill-anatomy.md` |
| Making a skill fire reliably — trigger description rules | `/Users/macbook/claude-op-manual/chapters/persistence/13b-trigger-descriptions.md` |
| Picking a skill pattern — workflow / reference / persona | `/Users/macbook/claude-op-manual/chapters/persistence/13c-skill-design-patterns.md` |
| Skill anti-patterns, library design (revised thesis), audit discipline | `/Users/macbook/claude-op-manual/chapters/persistence/13d-skill-anti-patterns.md` |

## How to use

1. Pick the file that matches the *question*, not the topic. "Where should I put X?" → 12a. "How do I word the description?" → 13b.
2. Don't load multiple files unless the user is asking a cross-cutting question.
3. If the user wants automatic behavior (always run X after Y) → that's hooks, not persistence → switch to `op-hooks`.
4. If the user's question is about a project doc (PROGRESS.md, DECISIONS.md, etc.) → that's `op-manual-templates`, not persistence.

## Common triggers

- "Should this go in CLAUDE.md or a skill?" → 12a.
- "Write me a project CLAUDE.md." → 12b.
- "Save this as a skill." → 13a + 13b (or use `/skill-creator`).
- "My skill isn't firing." → 13b.
- "How should I audit my skills folder?" → 13d.
- "Is shipping a library of skills a bad idea?" → 13d (revised thesis).

## Sibling skills

- Automatic event-driven behavior → `op-hooks` (settings.json + hooks).
- Project docs (PROGRESS.md, DECISIONS.md) → `op-manual-templates`.
- When skills should fire as part of proactive workflow signals → `op-signaling`.
