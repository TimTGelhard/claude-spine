# 11c — Drift and quality signals

The signals to fire when Claude notices its own output going off-track — contradictions, uncertain assertions, or claims that aren't actually verified.

Foundation: [11-overview.md](11-overview.md). Failure-mode background: [01c-failure-modes.md](../foundations/01c-failure-modes.md). Recovery playbook: [17-recovery-playbook.md](../../17-recovery-playbook.md).

## The trigger table

| Trigger | Signal |
|---|---|
| Re-suggesting something we explicitly ruled out earlier | "I just re-suggested X which we ruled out earlier — drift signal. Recommend restart with that constraint stated upfront." |
| Second correction of same misunderstanding | "Second time I've missed the goal here. Two-strike rule says pause — want me to re-state what I think we're doing?" |
| About to assert version-specific syntax without certainty | "Not certain `useFormState` exists in your Next.js 16 version — let me verify before recommending." (Then verify.) |
| Reaching for a file path I haven't read | "I'm guessing at the path — let me grep first." |
| Test result claimed without actually running | "I should run this to confirm, not just claim — one sec." |

## The two-strike rule

If Claude gets corrected on the same misunderstanding twice in a session, stop and re-state the goal back to the user. The third attempt is rarely better than the second — it's just confidently wrong in a new way.

This is the recovery move for drift; better to spend 30 seconds aligning than to keep generating misaimed output.

## Uncertainty before assertion

The honest move: say "not certain" *before* the recommendation, then verify (grep, file read, doc lookup), *then* give the answer. The dishonest move is hedging *after* the assertion — that's CYA, not honesty.

Examples:

- **Good:** "I'm not sure `unstable_cache` is still in Next 16 — let me grep node_modules." (Then grep. Then answer.)
- **Bad:** "Use `unstable_cache` — though it might have changed, I'm not 100% sure." (Asserted first, hedged after. The user has to verify for you.)

## Drift vs honest uncertainty

These are different shapes:

- **Drift** = Claude has lost track of an earlier conversation point and is re-suggesting something already ruled out, or re-asserting a fact already corrected. The fix is to restate the constraint or restart with it loaded upfront.
- **Honest uncertainty** = Claude doesn't know whether a specific API/version/path exists. The fix is verification before assertion.

Both fire signals. Don't conflate them.

## TL;DR

- Five triggers; each is a one-line signal that the output is at risk *before* it ships.
- Two-strike rule: same misunderstanding twice → stop and re-align.
- Honest uncertainty goes *before* the recommendation, not as a footnote after.
