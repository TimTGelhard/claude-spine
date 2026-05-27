---
name: op-anti-patterns
description: Use BEFORE taking actions that match a known anti-pattern — about to add a new dependency, new abstraction, new helper "for future use", new chapter/skill/agent speculatively, "let me also add X while I'm here", "I'll write the docs after MVP works", merging a diff you haven't read, declaring UI done without browser-verifying, skipping a two-session RLS check, or extending the manual / skills / agents / hooks themselves. Also use when the user proposes one of those. Routes to chapter 18 of the Claude Code Operator's Manual.
---

# op-anti-patterns — read before doing the thing

Anti-patterns are the explicit "never do this" reference. When about to do something that pattern-matches one of these categories, read the relevant file first and reconsider.

The single highest-leverage category is **meta** — when the user proposes extending the system itself (skills, agents, hooks, CLAUDE.md, chapters). The manual's rules apply to the manual itself; do not exempt.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading with the Read tool. `install.sh` ensures `~/.claude-spine` resolves to your spine clone.

## Index

| Category / about to... | Atomic file |
|---|---|
| Write a prompt, give feedback, talk across turns | `~/.claude-spine/chapters/anti-patterns/18a-prompting.md` |
| Bundle work into a session, carry a long session forward, "I'll do auth + feature together" | `~/.claude-spine/chapters/anti-patterns/18b-scope.md` |
| Dump the codebase, `cat` files, ignore compaction, store state in conversation | `~/.claude-spine/chapters/anti-patterns/18c-context.md` |
| Spawn a subagent, use `Write` for an edit, poll with `sleep` | `~/.claude-spine/chapters/anti-patterns/18d-tools.md` |
| Declare done without verifying, skip two-session RLS check, merge unread diff | `~/.claude-spine/chapters/anti-patterns/18e-verification.md` |
| Touch env vars, exception handling, error messages, migrations, logging | `~/.claude-spine/chapters/anti-patterns/18f-security.md` |
| Skip stage 0 (Decide), skip stage 5 (Harden), defer docs, one big PR | `~/.claude-spine/chapters/anti-patterns/18g-workflow.md` |
| Ship code not understood, let CLAUDE.md drift, hoard memory, add deps casually | `~/.claude-spine/chapters/anti-patterns/18h-long-term.md` |
| Extend the manual / skills / agents / hooks / CLAUDE.md itself | `~/.claude-spine/chapters/anti-patterns/18-meta-patterns.md` |

## How to use

1. Match the action to a category, read **just that file** (each <100 lines, self-contained).
2. If the anti-pattern fires, surface it: "[category] anti-pattern: <thing>. Want to reconsider?" Don't silently proceed.
3. If the user still wants it after the challenge, fine — the challenge was the job.

## High-priority triggers (always read before doing)

- New top-level dep → 18h. Bundling fix + refactor → 18b. UI "done" without browser → 18e. Public env-var on sensitive value, or `catch (e) {}` → 18f. Subagent for trivial work, or `Write` for a small edit → 18d.
- About to write a new skill / agent / chapter / hook the user just asked for → **18-meta-patterns first.** Stay in reviewer mode until the user explicitly says "build it."

Reading the file and proceeding anyway defeats the purpose — the point is the 30-second pause.

## Sibling skills

- Recovery when an anti-pattern already fired and the session is degrading → `op-recovery` (chapter 17).
- Writing skills well (the design-pattern half of the same problem) → `op-persistence` (13c, 13d).
- Choosing when to delegate to subagents (avoiding the tool anti-patterns) → `op-subagents` (chapter 16).
- Proactive signaling when in reviewer mode (the meta-scope check) → `op-signaling` (11e meta-scope).
