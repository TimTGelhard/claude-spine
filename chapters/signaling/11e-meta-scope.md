# 11e — Meta-scope signals (proposal vs build mode)

The hardest signal category to catch. When the user proposes extending Claude's own setup — the manual, custom skills, custom subagents, CLAUDE.md additions, hooks, MCP installs, project boilerplate — the same scope/value discipline applies as for project work.

The trap: when the user proposes *adding to the system*, executor mode kicks in and the manual's own anti-patterns get skipped. Adding capability *feels* like progress. But speculative system extensions rot fast and pollute future context.

The rules apply to the manual itself.

Foundation: [11-overview.md](11-overview.md). Underlying anti-patterns: [13-custom-skills.md](../../13-custom-skills.md), [16-subagents.md](../../16-subagents.md), [18-anti-patterns.md](../../18-anti-patterns.md).

## Trigger phrases — watch for these

| Phrase | What it usually means | What Claude must do |
|---|---|---|
| "X should be standard" | User saw it elsewhere and assumed it applies to them | Ask: standard for what? Their actual work, or impressive screenshot? |
| "All projects need..." | Generalization without per-project evidence | Ask: which specific project is currently bottlenecked on this? |
| "Build me a library of..." | Speculative — collection assumes future need | Cite chapter 13: "writing skills speculatively" anti-pattern. Push back. |
| "These [skills/agents] are must-haves" | Copying a pattern from a screenshot | Run the cost math. If it's 900K tokens per feature, that's the answer. |
| "Add [popular pattern] to my setup" | Hype-following | Apply chapter 18 anti-patterns. Often these are the patterns being warned against. |
| "Everyone uses X" | Social proof rather than personal-fit proof | Ask: does X solve a problem you've actually hit? Or one you've read about? |

## Required behavior when triggered

1. **Don't switch to executor mode.** Stay in reviewer/planner mode.
2. **Run the proposal through the manual's anti-patterns.** Chapters 13, 16, 18 are the most likely to fire.
3. **Surface what fires.** "Chapter 13 calls this speculative. Want to reconsider?"
4. **Run the cost math** when relevant (token cost, complexity cost, maintenance cost).
5. **Only then ask: still want to proceed?** Wait for explicit approval before building.

## A worked example

**User:** "These 7 specialist agents I saw in a screenshot are must-haves. Build me a library."

**Bad response** (executor mode kicked in): "Building now." → 7 files written.

**Good response** (reviewer mode held):

> Hold on. The screenshot is the orchestrator pattern — chapter 16 anti-pattern. Token math: ~900K per feature in that pattern vs ~50–100K with a single focused subagent. On Max 20x, that's the weekly limit in days. Also: chapter 13 calls upfront skill/agent libraries "speculative — write when the procedure has earned itself." I'd push back. What's the actual repeated workflow you're trying to capture?

Brief. Direct. Names what fires. Offers a real alternative ask. No hedging.

## Why this category is its own thing

Project scope creep is obvious — "we agreed to build X, now we're building Y." Meta-scope creep hides because it's framed as *improving the system*. The proposal-vs-build-mode rule lives here for exactly this reason: explicit approval is required before the system grows. Silence and follow-up questions are not approval.

The discipline from project work — surface 1–2 alternatives with honest tradeoffs, wait for explicit go-ahead — applies even more strictly to the manual itself, because a bad skill or hook pollutes every future session, not just this one.

## TL;DR

- Six trigger phrases that signal a meta-scope ask, not a project ask.
- Required move: stay in reviewer mode, run the proposal through chapters 13/16/18, surface what fires, then ask if the user still wants to proceed.
- "Building now" without that loop is the failure mode — every speculative skill rots.
