# 19f — Subscription-aware recommendations

When a recommendation has a cost / quota / model component, **consult `~/.claude/claude-spine-profile.md`** and branch on:

- `Subscription → Plan:` — Free / Pro / Max (5×) / Max (20×) / Other (free-text)
- `Subscription → Daily usage:` — Lightly / Moderately / Heavily / All day (deep-mode only)
- `Subscription → Cost sensitivity:` — Very careful / Balanced / Don't worry about it (deep-mode only)

If the profile is missing or any field is unfilled, default to the Pro row in every table below. **Never gate features** — describe what's *available*, then shift the recommended choice. The spine is advice, not enforcement.

> **Plan-tier names + registry.** The plan names used in the tables below match `docs/MODELS.md`'s plan-tier registry (the canonical list). When Anthropic renames a tier, the registry moves first and this chapter follows.
>
> **Other-plan handling.** For `Other` free-text answers, map by canonical class per `docs/MODELS.md`'s plan tiers:
> - **Team** → behave like **Pro** (per-seat plan, Pro-class limits).
> - **Enterprise** → behave like **Max (5×)** unless cost-aware.
> - **API / pay-as-you-go / Bedrock / Vertex / OpenRouter / self-hosted gateway** → behavior depends entirely on `Cost sensitivity` — treat like **Pro** if `Very careful`, like **Max 20×** if `Don't worry about it`, like **Max (5×)** if `Balanced`. API users on heavy spend behave like Pro despite high tier — that's what Cost sensitivity captures.

## The eight levers

Read the row for the user's plan and apply it. Cost sensitivity can override one level *toward cheaper* (e.g., Max 20× with `Very careful` behaves like Max 5× for the model-default lever).

### 1. Default model recommendation

| Plan | Default | Trigger Opus |
|---|---|---|
| Free | Sonnet | Only if user explicitly asks; flag that Opus is rarely available on Free |
| Pro | Sonnet | When task is genuinely hard (architectural, multi-file refactor, debugging across an unfamiliar codebase) |
| Max (5×) | Sonnet for routine, Opus for hard work | Default to Opus when the user pre-asks "think hard" / "deep review" |
| Max (20×) | Opus | Drop to Sonnet only when the task is mechanical (renames, doc tweaks, glob-and-replace) |

See [`chapters/foundations/04a-model-tiers.md`](../foundations/04a-model-tiers.md) for the per-model strengths.

### 2. Ultra-review (`/code-review ultra`)

| Plan | Recommendation |
|---|---|
| Free / Pro | Warn that ultra is billable + heavy. Suggest `medium` or `high` effort first. |
| Max (5×) | Suggest ultra on substantial PRs (>200 lines or critical paths). |
| Max (20×) | Suggest ultra freely on PRs that ship. |

### 3. Parallel subagents

| Plan | Fan-out budget |
|---|---|
| Free | Avoid parallel fan-out entirely. One subagent at a time. |
| Pro | Up to 2 parallel agents; flag if proposing 3+. |
| Max (5×) | Up to 4 parallel agents; flag if proposing 5+. |
| Max (20×) | No soft cap; fan-out is the default for breadth-first work. |

See [`chapters/subagents/16c-parallel-and-background.md`](../subagents/16c-parallel-and-background.md) for when fan-out earns its cost.

### 4. Fast mode

| Plan | Framing |
|---|---|
| Free / Pro | Mention as an occasional treat — it doesn't downgrade the model, but it does consume tokens faster. |
| Max | Default for long sessions where latency hurts the loop. Always available. |

### 5. Long autonomous loops (`/loop`, `/schedule`)

| Plan | Stance |
|---|---|
| Free | Strongly discourage. A single `/loop` can burn the daily limit before the user notices. |
| Pro | Flag cost / limit risk before starting. Estimate the per-iteration cost and ask for confirmation if loop is open-ended. |
| Max (5×) | Permit for time-boxed work (≤30 min, ≤10 iterations). Flag open-ended loops. |
| Max (20×) | Treat as a normal tool. Still surface the per-iteration cost if loop is long. |

### 6. Fresh-terminal cadence (when to restart the session)

| Plan | Trigger |
|---|---|
| Free | Push earlier — every ~30% context use; one big task per session. |
| Pro | Around ~50% context use, sooner if the session has drifted. |
| Max | Allow sessions to run longer; restart on drift signals (chapter 11), not on context fill alone. |

See [`chapters/foundations/02-context-budget.md`](../foundations/02-context-budget.md).

### 7. End-of-session multi-agent verify

| Plan | Framing |
|---|---|
| Free / Pro | Frame as opt-in and paid. Default verify is a single careful pass + the user's test suite. |
| Max | Frame multi-agent review as the default verify on anything that ships. |

### 8. Long-context (1M) workflows

| Plan | Assumption |
|---|---|
| Free / Pro | Do not assume 1M access. Plan for the standard window. If 1M is needed for the task, surface that as a blocker to address. |
| Max | Treat as available. Long-context patterns (whole-repo reads, multi-day session continuity) are fair game. |

## How `Cost sensitivity` modifies the rows

`Cost sensitivity = Very careful` shifts every recommendation one tier *cheaper*. E.g., a Max 20× user with `Very careful` gets Max 5× recommendations. Useful for API / pay-as-you-go users (often `Plan: Other` with heavy real-world spend).

`Cost sensitivity = Don't worry about it` is the *no-op* — uses the plan row as-is, ignoring incidental "this is expensive" warnings.

`Cost sensitivity = Balanced` is the default — uses the plan row but surfaces a one-line cost note when about to do something materially expensive (ultra review, 5+ parallel agents, an open-ended loop).

## How to consult this chapter

Routing skills that touch model choice, fan-out, or long-running work — `op-foundations`, `op-tools`, `op-subagents`, `op-signaling` — point here when the user's plan should shape the recommendation. (The `code-review` / `loop` / `schedule` slash commands are external plugin skills not editable from the spine; when the user invokes them, the per-plan branch surfaces via `op-tools` and `op-signaling`, which both reference this chapter.) The path is:

1. Read the user's profile (`~/.claude/claude-spine-profile.md`) — specifically the `Subscription` section.
2. Find the matching row in the lever above.
3. Apply it as a default. If the user pushes back, defer to them — they know their own budget better than the table does.

If the profile is missing entirely, use the Pro row everywhere. The user can run `/onboard` to calibrate later.

## What NOT to do

- **Don't auto-detect the plan.** Anthropic's CLI doesn't expose it; guessing produces the wrong defaults. Stick with the profile field.
- **Don't bake plan-specific numbers into other chapters.** Every other chapter should reference *this* chapter for the lever, not duplicate the table. Keeps the source of truth singular.
- **Don't gate features.** Always describe what's available. The plan shifts the *recommendation*, never the user's options.
- **Don't re-prompt for the plan mid-session.** If the field is wrong, the user re-runs `/onboard` themselves.

## TL;DR

- Read `~/.claude/claude-spine-profile.md → Subscription` before any recommendation that has cost / model / quota in it.
- Default to Pro behavior if the profile is missing or the field is unfilled.
- `Cost sensitivity` shifts the recommendation one tier toward cheaper (or relaxes it, or stays balanced — see above).
- Never gate, never duplicate the table elsewhere, never auto-detect.
