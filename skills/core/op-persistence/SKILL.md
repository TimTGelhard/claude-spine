---
name: op-persistence
description: Use when deciding *where* a behavior or rule should persist across sessions — CLAUDE.md vs custom skill vs memory vs project doc vs hook. Fires on phrases like "should this go in a skill or CLAUDE.md?", "where do I save this rule?", "I keep telling Claude X every session — where should it live?", or when authoring a CLAUDE.md, drafting a skill or its trigger description, fixing a skill that isn't firing, or auditing a stale skill library. NOT for code-level persistence (localStorage, Redis, database schemas, session state). Routes to chapters 12 and 13 of claude-spine; body branches into the sub-tasks once routed.
---

# op-persistence — CLAUDE.md, skills, and memory

The three layers that persist between sessions. Routes here pick exactly one file — load only what you need.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading with the Read tool. `install.sh` ensures `~/.claude-spine` resolves to your spine clone.

## Index

| Question / situation | Atomic file |
|---|---|
| Where does this thing go — CLAUDE.md / skill / memory / project doc? | `~/.claude-spine/chapters/persistence/12a-three-layers-overview.md` |
| Writing or editing CLAUDE.md (global or project)? | `~/.claude-spine/chapters/persistence/12b-claudemd.md` |
| Memory — what to save, what NOT to save, how Claude writes it | `~/.claude-spine/chapters/persistence/12c-memory.md` |
| What a skill is, mechanically — file shape, where to put it | `~/.claude-spine/chapters/persistence/13a-skill-anatomy.md` |
| Making a skill fire reliably — trigger description rules | `~/.claude-spine/chapters/persistence/13b-trigger-descriptions.md` |
| Picking a skill pattern — workflow / reference / persona | `~/.claude-spine/chapters/persistence/13c-skill-design-patterns.md` |
| Skill anti-patterns, library design (revised thesis), audit discipline | `~/.claude-spine/chapters/persistence/13d-skill-anti-patterns.md` |

## How to use

1. Pick the file that matches the *question*, not the topic. "Where should I put X?" → 12a. "How do I word the description?" → 13b.
2. Don't load multiple files unless the user is asking a cross-cutting question.
3. If the user wants automatic behavior (always run X after Y) → that's hooks, not persistence → switch to `op-hooks`.
4. If the user's question is about a project doc (PROGRESS.md, DECISIONS.md, etc.) → copy a template from `~/.claude-spine/templates/` (PROGRESS.md, DECISIONS.md, FEATURES.md, ARCHITECTURE.md, PROJECT_BRIEF.md, SMOKE_TESTS.md, DEPLOY.md, SESSION_STARTER.md, CLAUDE.md) into the project's `docs/`.

## Common triggers

- "Should this go in CLAUDE.md or a skill?" → 12a.
- "Write me a project CLAUDE.md." → 12b.
- "Save this as a skill." → 13a + 13b (or use `/skill-creator`).
- "My skill isn't firing." → 13b.
- "How should I audit my skills folder?" → 13d.
- "Is shipping a library of skills a bad idea?" → 13d (revised thesis).

## Sibling skills

- Automatic event-driven behavior → `op-hooks` (settings.json + hooks).
- Project docs (PROGRESS.md, DECISIONS.md, etc.) → copy from `~/.claude-spine/templates/`.
- When skills should fire as part of proactive workflow signals → `op-signaling`.
