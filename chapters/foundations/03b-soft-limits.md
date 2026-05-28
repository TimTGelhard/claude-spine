# 03b — Soft limits: things Claude can do, but unreliably

Use these capabilities with care. The output looks plausible; the output is sometimes wrong.

## 1. Anything time-sensitive or rate-limited

External API quotas, time-of-day-specific behavior, race conditions. Claude can write code for these but can't *experience* them. Test in the real environment.

## 2. Complex multi-step debugging with state

"This worked yesterday, today it doesn't, here's what I changed" — Claude can guess. But state-dependent bugs (race conditions, cache invalidation, intermittent failures) often need you with a debugger, not Claude with a diff.

## 3. Cross-process / cross-machine interactions

Webhook from a payment provider arriving at your local dev → tunnel (ngrok / Cloudflare Tunnel / smee) → your web framework → your datastore. Claude can build it. Claude can't always tell you *which hop* is failing.

## 4. Performance optimization without measurement

Claude will happily suggest "optimizations." Most are guesses. Without profiling data, the suggestions are random walks. Get data first, then ask.

## 5. Long-running operations

Claude works in turns. It can't watch a slow migration finish — you have to bring back the result.

## How to handle soft limits

The pattern is the same in each case:

1. Let Claude draft the code or the hypothesis.
2. Validate against reality yourself — run it, profile it, watch the logs, query the live system.
3. Bring the data back. Now Claude can reason from facts instead of guessing.

Soft limits aren't a reason to skip Claude. They're a reason to keep the human in the loop on verification.

## Related

- Hard limits (structural, plan around them): [03a-hard-limits.md](03a-hard-limits.md)
- Project-fit and warning signs: [03c-project-fit.md](03c-project-fit.md)
