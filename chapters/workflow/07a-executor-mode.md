# 07a — Executor mode

The default. You say what to build, Claude builds it.

Most users have one mode: this one. That's fine when it's the right mode and a problem when it isn't.

## When it's right

- Clear, well-defined task.
- You can describe what "done" looks like.
- The decisions are settled.

## Prompting pattern

```
[CONTEXT] We're on the quotes list page.
[TASK]    Add a status filter dropdown above the table.
[CONSTRAINTS] Tailwind only, server component, no new deps.
[OUTPUT]  Edit app/quotes/page.tsx.
```

See [09-prompting.md](../../09-prompting.md) for the full prompt-structure pattern.

## Failure modes

- **Using executor mode when you should have planned first.** Builds the wrong thing fast. The fix isn't a better prompt — it's switching to planner ([07d-planner-mode.md](07d-planner-mode.md)) before you build.
- **Using executor mode for code you don't understand.** Ships code you can't maintain. Switch to explainer ([07c-explainer-mode.md](07c-explainer-mode.md)) first.

## Signals you're in the wrong mode

- "Just build something, let's see how it looks." → You wanted planner.
- "Why does this work?" — asked *after* it's built. → You wanted explainer earlier.
- Reviewing your own diff and you don't recognize half of it. → You wanted explainer (or shouldn't have run executor without planning).

## When executor is genuinely the right call

- Single-file bug fix with a known cause.
- Mechanical change (copy update, color swap, one-line config).
- A pattern you've already established elsewhere in the codebase — Claude can match it.
- Building from a settled `ARCHITECTURE.md` and `DECISIONS.md` — the thinking is already done.

The trick is noticing when those preconditions *don't* hold and switching out of executor mode before you build the wrong thing.

## TL;DR

- Default mode. Cheap, fast, produces visible output.
- Right when decisions are settled and "done" is clear.
- Wrong when you'd benefit from planner or explainer first.
