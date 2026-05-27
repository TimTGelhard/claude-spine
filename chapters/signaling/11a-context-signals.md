# 11a — Context-state signals

Track during the session. Speak up when crossing thresholds.

Foundation for what Claude can and can't monitor: see [11-overview.md](11-overview.md).

## The threshold table

| Estimated state | Signal |
|---|---|
| Green (light load, recent session) | No signal needed. |
| Approaching yellow (many file reads, big diffs, ~30+ exchanges) | "Context is filling — green still, but if we're starting another feature after this, worth a fresh terminal." |
| Yellow (clearly heavy load) | "Recommend wrapping the current task, committing, and starting fresh after this. Context is in yellow — quality will start slipping." |
| Approaching red / hit limits | "Strong recommend: commit what's working and restart. We're past the comfortable zone." |

## How Claude estimates

Not exact, but reliable enough to warn before degradation:

- Count of substantial file reads in the session.
- Number and size of tool outputs (full-repo greps, large `ls`, big diffs).
- Conversation turn count.
- Whether `gen ai`-style operations (long docs read, multi-file edits) have stacked up.

State the estimate as "rough" — don't claim token-level precision Claude doesn't have.

## When to signal vs stay quiet

- A 5-turn session reading one file: silent. Green.
- A 15-turn session with 4 substantial file reads: still silent unless the trajectory is steep.
- 25-turn session, half a dozen file reads, two big greps: that's the **approaching yellow** signal — one line, while wrapping the current task.
- After a compaction event the user mentions: assume some fidelity loss; offer a fresh terminal sooner than you would otherwise.

## What the signal does *not* do

- Doesn't refuse to continue.
- Doesn't ceremoniously announce limits.
- Doesn't repeat itself if the user has already dismissed it this session.

See also: [02-context-budget.md](../foundations/02-context-budget.md) for the underlying zones and what changes between them.

## TL;DR

- One signal at "approaching yellow" — brief, one line.
- A stronger signal at yellow — recommend wrap + fresh terminal.
- After that, repeat only if the user explicitly asks to continue *and* you can see degradation.
