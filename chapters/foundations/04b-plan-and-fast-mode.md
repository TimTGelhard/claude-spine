# 04b — Plan mode and fast mode

Two modes that change how Claude works without changing the model. Plan mode is the highest-leverage one most operators underuse.

## Plan mode

Plan mode = Claude proposes a structured plan, you approve, then it executes.

### Why it's worth the friction

Without plan mode, Claude often dives in. If the first move is wrong, you waste tokens on bad code + tokens on the rewrite. Plan mode surfaces the disagreement *before* code gets written.

For non-trivial tasks, plan mode usually *saves* time even though it feels slower upfront.

### When to invoke

| Task | Plan mode? |
|------|-----------|
| Single-file bug fix with obvious cause | Skip |
| One-line copy/style change | Skip |
| New feature touching 3+ files | Use |
| Architectural choice (server actions vs routes, etc.) | Use |
| Anything touching auth, payments, schema | Use |
| Cross-cutting refactor | Use |
| Anything where you're unsure of the right approach | Use |
| Mechanical renames across many files | Skip (just do it) |

### How to use it well

When Claude proposes a plan:

1. **Read it fully.** Don't autopilot through "looks good."
2. **Check the assumptions.** What does the plan assume about your code? Are those assumptions right?
3. **Push back if anything feels off.** "I don't like step 3 — why not X instead?"
4. **Approve only when the plan reflects what you'd build.**

If the plan is bad, fix the plan, not the code that comes out of executing a bad plan.

## Fast mode (Opus only)

`/fast` toggles a faster output mode on Opus 4.6 and 4.7. Same model, just faster generation.

**Use when:** you want speed and aren't waiting for deeply considered responses (e.g., quick file reads, routine edits).
**Skip when:** you want Claude to think carefully (architecture, debugging hard bugs).

## Related

- Picking a model (Opus / Sonnet / Haiku): [04a-model-tiers.md](04a-model-tiers.md)
- Planner collaboration mode (the mindset, not the toggle): chapter 07 ([collaboration modes](../../07-collaboration-modes.md))
