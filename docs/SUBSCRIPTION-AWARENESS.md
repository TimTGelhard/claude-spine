# Subscription-aware adjustments — planning doc

> **Status:** All three sessions done. Personalization payload closed.
>
> - **Session 1 (2026-05-27).** `chapters/personalization/19f-subscription-aware.md` shipped (8 levers × 4 plan-rows + Cost sensitivity modifier + Pro fallback). Four routing skills wired to read it (`op-foundations`, `op-tools`, `op-subagents`, `op-signaling`).
> - **Session 2 (2026-05-28).** Five chapters cross-reference 19f: `04a-model-tiers` ("Plan-aware default" subsection + related-link), `04b-plan-and-fast-mode` (fast-mode framing note), `04c-budget-and-cost` ("Plan budgets" pointer paragraph), `16c-parallel-and-background` ("Plan-aware fan-out budget" subsection + TL;DR bullet), `11-overview` ("Cost / quota signals" cross-cutting subsection). Bidirectional linking complete.
> - **Session 3 (2026-05-28).** Read-through verification across all four plan tiers (Free / Pro / Max 5× / Max 20×) — no cross-reference drift found. `09c-examples-and-anti-examples.md` gains a "The subscription line — read from your profile, not your prompt" section that shows the same `/code-review ultra` question producing different answers per profile. `19f` wording clarified — the `code-review` / `loop` / `schedule` slash commands are external plugin skills (not routing skills); the per-plan branch reaches them indirectly via `op-tools` and `op-signaling`. CHANGELOG and FIXES swept; no re-onboard runs needed since the read-through caught the same drift the re-onboard simulation would have.
> - **Skills caveat.** The `code-review` / `loop` / `schedule` skills listed in the Session 2 plan are **external plugin skills** (not in this repo). The realistic injection path is the op-* routers wired in Session 1 — `op-tools` and `op-signaling` both point at 19f when those slash commands come up.

## Why

The new `Subscription` section in `~/.claude/claude-spine-profile.md` captures:

- `Plan:` (Free / Pro / Max 5× / Max 20× / Other)
- `Daily usage:` (Lightly / Moderately / Heavily / All day) — from deep mode
- `Cost sensitivity:` (Very careful / Balanced / Don't worry about it) — from deep mode

Capturing it is useless if no chapter or skill actually reads it. Today every recommendation assumes a Max-tier user with cheap Opus access. That's wrong for the Free / Pro segment, and it under-uses what Max users could be doing.

## What "adjusting to the subscription" means concretely

Each row is a candidate change. Not all of these need to ship together — pick by impact.

| Lever | Free / Pro behavior | Max 5×–20× behavior | Where it lives today |
|---|---|---|---|
| Default model recommendation | Steer toward Sonnet for most work; flag Opus as a deliberate choice | Default to Opus unless task is trivial | `chapters/foundations/04a-model-tiers.md`, chapter 03 |
| Ultra-review (`/code-review ultra`) | Warn that it's billable + heavy; suggest cheaper effort levels first | Suggest it freely on PRs | `code-review` skill, chapter 16 |
| Parallel subagents | Caution against fanning out 4+ agents — burns the daily limit | Encourage parallel agents for breadth | chapter 16 (subagents) |
| Fast mode | Mention as occasional treat | Mention as default for long sessions | chapter 03 |
| Long autonomous loops (`/loop`, `/schedule`) | Strongly flag cost / limit risk before starting | Treat as a normal tool | `loop` / `schedule` skills |
| Fresh-terminal cadence | Push earlier — every ~30% context use | Allow longer sessions | chapter 02, chapter 11 |
| Multi-agent review at session end | Frame as opt-in, paid | Frame as default verify | chapter 11, `verify` |
| Long-context (1M) workflows | Don't assume access | Treat as available | chapter 02 |

## Sketch of the implementation

**Session 1 — wire the read path.**
- Decide *where* the subscription gets consulted. Two options:
  1. A new `op-subscription` router skill that other skills can read from.
  2. A flat reference: `chapters/personalization/19f-subscription-aware.md` that the existing `op-foundations` and `op-tools` routers point to.
- Pick option (2) for simplicity unless we hit a routing problem.
- Write the chapter. Mirror the table above with concrete prose.
- Update `INDEX.md` and the routing skills that should now reference it (`op-foundations`, `op-tools`, `op-signaling`, `op-subagents`).

**Session 2 — adjust the high-leverage chapters.**
- `04-models-and-economics` (chapters/foundations/04*) — add a "By plan" subsection mapping plan → default model recommendation.
- `chapter 16` (subagents) — add a guardrail block "Before fanning out N agents, check the user's plan".
- `chapter 11` (signaling) — add a signal "we're about to burn meaningful quota; confirm".
- The `code-review`, `loop`, `schedule` skills — read the profile and adjust their opening framing.

**Session 3 — verify + document.**
- Re-onboard as each plan tier (Free, Pro, Max 5×, Max 20×) and confirm the tone shifts in each chapter.
- Update CHANGELOG.
- Update `09-prompting` / examples to show the subscription line being referenced.

## Open questions

- Do we need a separate `Cost sensitivity` lever at all, or does `Plan` carry enough signal? (Hypothesis: yes, because an API/pay-go user on heavy spend wants the cheapest viable option even with high "plan" tier.)
- For "Other" plans (Team / Enterprise / API), what's the default behavior? Probably: treat like Max 20× unless `Cost sensitivity = Very careful`.
- Should the deep-mode `Daily usage` field decay over time, or do we just re-prompt on `/onboard --deep`? (Leave as static for now.)

## What NOT to do

- Don't bake plan-specific magic numbers into every chapter — keep a single mapping in `19f-subscription-aware.md` and have other chapters reference it.
- Don't auto-detect the plan. Anthropic's CLI doesn't expose it; we'd be guessing. Stick with the captured profile field.
- Don't gate features. The spine is advice, not enforcement. Always describe what's *available*; the recommendation just shifts.
