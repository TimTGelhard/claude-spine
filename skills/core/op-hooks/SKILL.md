---
name: op-hooks
description: Use when wiring an automatic behavior to a Claude Code event (typecheck after edit, block commit on test fail, notify on long completion), editing settings.json (global or project), troubleshooting why a hook didn't fire, deciding between hook / CLAUDE.md / skill for "from now on, when X, do Y", or setting up the starter automation set for a new machine. Routes to chapter 14 of the Claude Code Operator's Manual.
---

# op-hooks — automation via settings.json

Hooks are how the *harness* enforces automatic behavior. Not Claude. Not CLAUDE.md. The harness runs them deterministically on events.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading with the Read tool. `install.sh` ensures `~/.claude-spine` resolves to your spine clone.

## Index

| Question / situation | Atomic file |
|---|---|
| Where do settings live — global / project / local? Cascade rules? | `~/.claude-spine/chapters/persistence/14a-settings-cascade.md` |
| What should I actually hook? Starter set, anti-hooks, verifying | `~/.claude-spine/chapters/persistence/14b-hook-recipes.md` |

## How to use

1. **Always use `update-config` to edit settings.json** — the schema shifts between Claude Code versions; don't memorize.
2. The starter set in 14b pays back in 15 minutes — recommend it when a user has zero hooks.
3. If the user wants "Claude to always do X" → that's CLAUDE.md or a skill, not a hook. Hooks are for *scripted commands*, not reasoning.
4. A hook the user routinely bypasses is worse than no hook. Fix or remove.

## Common triggers

- "From now on, every time I edit a TS file, X." → hook (14b).
- "How do I block commits when typecheck fails?" → 14b (commit gates).
- "Why didn't the hook fire?" → 14a (cascade) + verify with `update-config`.
- "Should this go in global or project settings?" → 14a.
- "Set up basic automation for this machine." → 14b starter set.

## Sibling skills

- "Should this be a hook or CLAUDE.md or a skill?" — decision tree → `op-persistence` 12a, then 14b.
- Reducing permission prompts (allowlist) → `fewer-permission-prompts` skill.
- Keybindings → `keybindings-help` skill.
- Actually editing settings.json → `update-config` skill (not this one — this skill routes the *thinking*, `update-config` does the edit).
