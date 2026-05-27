# 04a — Picking a model: Opus, Sonnet, Haiku

Picking the right model is the difference between paying for the reasoning you need and paying for reasoning you don't.

## The current Claude lineup

| Model | ID | Context | Strengths | Cost class |
|-------|-----|---------|-----------|------------|
| Opus 4.7 | `claude-opus-4-7` | 1M (with `[1m]`) / 200K default | Hardest reasoning, best long-context, best multi-file refactors | Highest |
| Sonnet 4.6 | `claude-sonnet-4-6` | 200K | Workhorse — fast, capable, sufficient for most tasks | Mid |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | 200K | Fast and cheap for narrow, well-specified tasks | Low |

Note: the model lineup moves fast. Verify the current options before committing to "always use X" — you may be missing a newer version.

## Opus — use when

- Architectural decisions or design discussions.
- Multi-file refactors where coherent reasoning matters.
- Long-context work (>200K relevant input).
- Debugging stubborn bugs where shallow guesses keep failing.
- High-stakes code (auth, payments, anything user-data-touching).
- First-time exploration of a complex codebase.

## Sonnet — use when

- Standard feature build sessions (most of your work).
- Bug fixes with clear root cause.
- Mechanical refactors.
- Routine prompting + iteration.
- Anything where Sonnet has handled similar tasks well before.

This is the default. Don't reach for Opus unless you need it.

## Haiku — use when

- Highly bounded, well-specified tasks ("rename this function across these files").
- Quick lookups, simple transformations.
- Anything where you'd be annoyed paying Opus prices.

For Claude Code interactive work, Haiku is often *too* shallow — use sparingly.

## Mental rule of thumb

> "Use the cheapest tool that can do the job correctly. Don't optimize cost over correctness — but don't waste budget on overkill either."

- Bug fix → Sonnet
- Architecture decision → Opus
- "Find every place this is used" → Subagent (Explore)
- "Why is this broken?" → Opus if you've already tried Sonnet and it's still stuck

## Plan-aware default

The defaults above assume reasonable Opus access. The user's Claude subscription shifts where the line sits — a Free user should default Sonnet harder than a Max 20× user, and a Max 20× user can default Opus on routine work that a Pro user would burn quota on.

Before recommending a model, read `~/.claude/claude-spine-profile.md → Subscription → Plan:` and apply the per-plan row in [`19f-subscription-aware.md`](../personalization/19f-subscription-aware.md) (lever 1 — default model recommendation). If the profile is missing, default to the Pro row.

## Related

- Plan mode and fast mode: [04b-plan-and-fast-mode.md](04b-plan-and-fast-mode.md)
- Context cost discipline and plan budgets: [04c-budget-and-cost.md](04c-budget-and-cost.md)
- Per-plan model + fan-out + loop defaults: [`19f-subscription-aware.md`](../personalization/19f-subscription-aware.md)
