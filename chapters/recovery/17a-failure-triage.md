# 17a — Failure-mode triage

The chapter you re-read at 2am when nothing is working. **Diagnose before fixing.**

Most stuck-with-Claude situations are one of these. The wrong move on the right diagnosis is still the wrong move — match symptom to cause first.

## Triage table

| Symptom | Likely failure | First move |
|---------|---------------|------------|
| Same bug returns after "fix" | Drift — Claude forgot earlier constraint | Restart session, re-state |
| Claude proposes obviously wrong file paths | Hallucination | Verify each path; consider restart |
| Output gets generic / shallow | Dilution — context too full | Trim context or restart |
| Each fix introduces a new bug | Scope too big OR you don't understand the code | Pause; read what's there |
| "Tests pass" but feature broken | Wrong tests / no real verification | Manual smoke test now |
| Migration fails halfway | DB in mixed state | DON'T re-run blindly; inspect |
| Deploy succeeded, site broken | Env vars / DNS / runtime mismatch | Roll back first, investigate after |
| Claude won't stop "fixing" | You're letting it run unsupervised | Take back the wheel |
| You don't recognize the code | You shipped what you didn't understand | Stop. Read. Refactor or revert |

## How to read the table

Each row maps a **visible symptom** to a **failure mode** to a **first move**. The first move is not the full fix — it's the thing you do right now so the next step is informed.

- The failure-mode names (drift, dilution, hallucination, scope, verification, ops, supervision, comprehension) line up with the three failure modes in [01c-failure-modes.md](../foundations/01c-failure-modes.md), plus the operational ones (migration, deploy) and the human-side ones (supervision, comprehension).
- The first move is always cheap: restart, verify, inspect, roll back, pause. Recovery moves are the *next* step and live in [17b-recovery-moves.md](17b-recovery-moves.md).
- High-stakes situations (secrets leaked, RLS broken, migration mid-flight on prod) get their own playbook in [17c-high-stakes-cases.md](17c-high-stakes-cases.md). If your symptom is in 17c, jump there before applying a generic move.

## Two diagnoses, one symptom

Some symptoms have more than one cause. "Each fix introduces a new bug" can be scope (too many changes at once) or comprehension (you don't understand the code anymore). The first move — *pause; read what's there* — works for both. Once you've read, the right next move declares itself.

When in doubt between two diagnoses, the cheaper move wins. Restarting a session is free. Reverting a deploy is free. Rewriting a feature from scratch is not.

## Anti-pattern: skipping the diagnosis

The temptation when stuck is to keep typing. Each prompt adds context, each fix adds risk. The triage step takes 30 seconds and prevents the next hour of wrong moves.

If the symptom isn't in the table, the failure is probably one of the three core modes — see [01c-failure-modes.md](../foundations/01c-failure-modes.md) — and the move is restart or verify before doing anything else.
