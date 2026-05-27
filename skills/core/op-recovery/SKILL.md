---
name: op-recovery
description: Use when workflow quality is dropping mid-session, Claude is contradicting itself, hallucinating file paths or API names, drifting from earlier constraints, when each fix introduces a new bug, when the user says "are you sure", "you said the opposite earlier", "this isn't working", "you're going in circles", "I don't recognize this code", when a deploy broke production, a migration failed mid-flight, secrets leaked, or auth/RLS may be exposing user data. Routes to chapter 17 (recovery playbook) of claude-spine.
---

# op-recovery — diagnose, then act

When the session is going wrong, the manual has a triage table and a set of moves. Diagnose the failure first, then apply the matching move. Don't skip the diagnosis — wrong move on right symptom is still the wrong move.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading with the Read tool. `install.sh` ensures `~/.claude-spine` resolves to your spine clone.

## Index

| Question / situation | Atomic file |
|---|---|
| Triage: what's actually going wrong? Symptom → likely failure → first move | `~/.claude-spine/chapters/recovery/17a-failure-triage.md` |
| The 7 recovery moves (restart, verify, shrink scope, read diff, roll back, refactor, browser-verify) + update-the-system + when-to-walk-away | `~/.claude-spine/chapters/recovery/17b-recovery-moves.md` |
| High-stakes recoveries: leaked secret, mid-flight migration on prod, auth/RLS data leak, "scared to touch the codebase" | `~/.claude-spine/chapters/recovery/17c-high-stakes-cases.md` |

## How to use

1. **Always start with 17a** unless the situation is clearly one of the high-stakes cases in 17c.
2. From 17a's triage table, pick the matching first move, then jump to 17b for the full move.
3. **For secrets / prod migration / RLS leak / lost comprehension → 17c immediately.** These have a different order-of-operations from the generic moves.

## High-priority triggers

- User says "are you sure?" twice → drift, restart with constraint stated upfront (17b Move A).
- User says "you said the opposite earlier" → drift confirmed, fresh terminal (17b Move A).
- Claude can't find a file/function it just referenced → hallucination check (17b Move B: verify before claiming).
- Each fix introduces a new bug → scope problem (17b Move C: shrink and commit).
- "Tests pass" but feature broken → manual verification (17b Move G for UI, or Move D for non-UI).
- Deploy broke prod / migration mid-flight → 17c immediately. Roll back first, investigate after.
- User says "I don't recognize this code" → 17b Move D (read the diff) or 17c "scared to touch the codebase."

## Anti-pattern: don't just signal, ACT

If the recovery move is "fresh terminal," say so and stop typing in this one. If it's "verify before claiming," do the verification before answering. Don't read the chapter and proceed with the broken behavior anyway.

## Sibling skills

- About to add a new dep / abstraction / pattern / skill speculatively → `op-anti-patterns` (chapter 18).
- Should be signaling something proactively (context filling, scope creep) but isn't → `op-signaling` (chapter 11).
- After recovery, update `PROGRESS.md` / `DECISIONS.md` / `SMOKE_TESTS.md` so the failure can't recur → `op-persistence` (chapter 12).
