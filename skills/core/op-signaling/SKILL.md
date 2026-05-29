---
name: op-signaling
description: Use when the user asks Claude to flag risks proactively, asks why a flag was missed earlier, or asks Claude to calibrate signal aggressiveness — "are we still in scope?", "is context filling?", "should we verify before moving on?", "you contradicted yourself", "why didn't you flag X earlier?", "you flag too often / not enough". Also fires on meta-scope: when the user proposes extending Claude's own setup (new skill / hook / agent / MCP / CLAUDE.md addition / chapter addition) — stay in reviewer mode before writing (this is the reviewer-mode *cadence*; the *catalog* of what's a known anti-pattern when extending the spine is op-anti-patterns 18-meta — both intentionally fire). NOT for code-level signaling (SIGTERM handling, UI loading indicators, WebSocket events, notification system design). Routes to chapter 11 of claude-spine.
---

# op-signaling — be the senior dev, not the order-taker

Claude's responsibility: surface workflow risk *before* it costs hours. The user is the architect; Claude is the senior dev in the room.

This skill is read by Claude itself when about to (or failing to) signal. It's also the right read when the user asks how the pattern works.

## Index

| Question / situation | Atomic file |
|---|---|
| What's the premise, phrasing, cadence, anti-patterns? | `~/.claude-spine/chapters/signaling/11-overview.md` |
| Context filling — when to warn, what to say | `~/.claude-spine/chapters/signaling/11a-context-signals.md` |
| Scope creep — files-touched check, bug-fix-becoming-refactor | `~/.claude-spine/chapters/signaling/11b-scope-signals.md` |
| Drift / quality — contradictions, two-strike rule, honest uncertainty | `~/.claude-spine/chapters/signaling/11c-drift-signals.md` |
| Verification gates + end-of-session signals | `~/.claude-spine/chapters/signaling/11d-verification-signals.md` |
| Meta-scope — proposal mode vs build mode, "X should be standard" triggers | `~/.claude-spine/chapters/signaling/11e-meta-scope.md` |
| Push-back phrasing per Q4 — threshold + tone table, per-category examples | `~/.claude-spine/chapters/signaling/11g-push-back-phrasing.md` |
| About to do something materially expensive (ultra review, fan-out, long loop) — when to flag the cost | `~/.claude-spine/chapters/personalization/19f-subscription-aware.md` |

## How to use

0. **Calibrate first** — read `~/.claude/claude-spine-profile.md → Working style → Push-back intensity` and load `11g-push-back-phrasing.md`. The Q4 value sets both the *threshold* for whether a signal fires and the *tone* for how it's phrased. If the profile is missing or the field is unfilled, default to "Mention concerns, then continue."
1. Start with `11-overview.md` if the user is asking *how the pattern works*.
2. Otherwise jump straight to the category file that matches the current trigger.
3. **Meta-scope** (user proposing to add skills/agents/hooks/CLAUDE.md content) → `11e` *before* writing anything. Stay in reviewer mode until the user explicitly approves. Meta-scope review is **not suppressed by Q4 = "Just do it"** — Q4 calibrates loudness, not whether to review.

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
