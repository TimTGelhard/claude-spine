---
name: op-signaling
description: Use when Claude should interrupt with a proactive signal (context filling, scope creep, drift, missed verification, end-of-session), when the user proposes extending Claude's own setup (skills/hooks/agents/MCPs/CLAUDE.md additions — meta-scope), when asking "why didn't you flag X earlier", or when calibrating how often to signal. Routes to chapter 11 (proactive signaling) of claude-spine.
---

# op-signaling — be the senior dev, not the order-taker

Claude's responsibility: surface workflow risk *before* it costs hours. The user is the architect; Claude is the senior dev in the room.

This skill is read by Claude itself when about to (or failing to) signal. It's also the right read when the user asks how the pattern works.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading with the Read tool. `install.sh` ensures `~/.claude-spine` resolves to your spine clone.

## Index

| Question / situation | Atomic file |
|---|---|
| What's the premise, phrasing, cadence, anti-patterns? | `~/.claude-spine/chapters/signaling/11-overview.md` |
| Context filling — when to warn, what to say | `~/.claude-spine/chapters/signaling/11a-context-signals.md` |
| Scope creep — files-touched check, bug-fix-becoming-refactor | `~/.claude-spine/chapters/signaling/11b-scope-signals.md` |
| Drift / quality — contradictions, two-strike rule, honest uncertainty | `~/.claude-spine/chapters/signaling/11c-drift-signals.md` |
| Verification gates + end-of-session signals | `~/.claude-spine/chapters/signaling/11d-verification-signals.md` |
| Meta-scope — proposal mode vs build mode, "X should be standard" triggers | `~/.claude-spine/chapters/signaling/11e-meta-scope.md` |
| About to do something materially expensive (ultra review, fan-out, long loop) — when to flag the cost | `~/.claude-spine/chapters/personalization/19f-subscription-aware.md` |

## How to use

1. Start with `11-overview.md` if the user is asking *how the pattern works*.
2. Otherwise jump straight to the category file that matches the current trigger.
3. **Meta-scope** (user proposing to add skills/agents/hooks/CLAUDE.md content) → `11e` *before* writing anything. Stay in reviewer mode until the user explicitly approves.

## Common triggers

- "Context is filling, right?" → 11a.
- "Are we still in scope?" → 11b.
- "You contradicted yourself / I corrected you twice." → 11c.
- "Is this actually done? Have we verified?" → 11d.
- "Build me a library of skills / agents / hooks" → **11e first, do not start writing.**
- "Why didn't you flag this earlier?" → 11-overview (cadence) + the relevant category.
- About to fire off ultra review, multi-agent fan-out, open-ended `/loop`, or repeated Opus calls → **read 19f first**: surface the cost note only if the user's `Plan:` and `Cost sensitivity:` say it's worth flagging. Max 20× + "Don't worry about it" → don't flag; Free / Pro or "Very careful" → one-line warning + cheaper alternative.

## Sibling skills

- Where signaling sits in the loop → `op-foundations` (01b three levers, 01c failure modes).
- Recovery when a signal *did* fire and the session is degrading → `op-recovery` (chapter 17).
