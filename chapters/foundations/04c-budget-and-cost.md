# 04c — Budget, plan limits, and when not to use Claude Code

Model choice is one cost lever. Context discipline is a bigger one. And sometimes Claude Code is the wrong tool entirely.

## Context cost discipline

Beyond model choice, the biggest cost is *how much context you load*.

- Every `Read` puts the file in context for the rest of the session.
- Every `Bash` output puts the output in context (filtered if you piped to head/tail).
- Subagents return summaries, not full content — they're a context-cost-reduction tool.

**A 1M-context Opus session using only 30K tokens is dirt cheap. A 200K-context Sonnet session using all 200K is more expensive than the Opus one.** The lever isn't only model choice — it's load discipline.

## Plan budgets — what you actually have

Whether you're on Pro, Max, Max 20x, or Team, the shape is the same: generous but not infinite. Heavy daily Opus + 1M-context use can still hit limits. Limits reset on a fixed cadence (usually weekly). You'll feel a hard wall, not a soft slowdown.

The eight per-plan recommendation rows (default model, ultra-review, fan-out, fast mode, loops, restart cadence, end-of-session verify, 1M-context) live in [`19f-subscription-aware.md`](../personalization/19f-subscription-aware.md). When the recommendation in this chapter feels generic, that's where the per-plan version lives.

### Stretching the budget

1. **Default to Sonnet.** Save Opus for the cases that need it.
2. **Trim context.** Bigger context = more tokens per call.
3. **Use subagents** for big reads (they have their own budgets but return small summaries).
4. **Commit and start fresh** between features — long sessions waste tokens re-loading context implicitly.
5. **Don't ask Claude to re-summarize work it just did.** You can read the diff.

### Knowing your limits

Tracking usage is the gap between "comfortable" and "hit the wall Thursday." Three layers, increasing in precision:

**1. In-client.** Run `/usage` (if your client supports it) — current session plus recent activity. Fastest signal, no tab switch.

**2. Anthropic console.** Plan utilization at console.anthropic.com. Authoritative, refreshes more slowly than the client. Check at least once a week — more during heavy build stretches.

**3. Behavioral heuristics when you can't see numbers.**
- A normal feature session (5-10 file edits, smoke tests): small fraction of weekly budget.
- "Whole codebase loaded for context" sessions: meaningfully more — a handful mid-week add up.
- Daily heavy Opus + 1M-context use: will hit the wall before the week resets.

What to do when trending hot:
- Default to Sonnet for routine work. Opus only when reasoning actually needs it.
- Trim context — smaller per-call use multiplies into many more calls per week.
- Subagents for big reads (their budget, your summary).
- Skip "let me also..." additions. Every "while we're at it" costs.

Trend > absolute. 60% by Tuesday means adjust now, not Friday at midnight.

## When NOT to use Claude Code

Sometimes another tool is right.

- **Bulk text edits with a known regex** → `sed` / `rg --replace` is faster and free.
- **Running tests** → the CLI directly is fine; you don't need Claude to wrap it.
- **Looking at a file** → your editor. Don't waste a Claude turn on `Read` if you can just open the file.
- **Asking general knowledge questions** → claude.ai (web) or another LLM is fine; Claude Code is for tasks with tools.
- **Quick CLI lookups** → man pages, `tldr`, just typing the command.

The instinct to "do everything in Claude Code" wastes tokens. Use the tool where it has unique leverage (tools + context + reasoning combined).

## The Anthropic API for app development (different from Claude Code)

If you're building an app that *calls Claude*, that's the API, not Claude Code. Different sizing:

- **Default model for app code: Sonnet 4.6.** Don't ship Opus unless the task genuinely needs it — cost adds up.
- **Use prompt caching** for any prompt re-sent 3+ times. Massive savings.
- **Set `max_tokens` explicitly.** Don't let runaway responses burn tokens.
- **System prompts for role**, user messages for input. Don't mash everything into user.
- **Key never reaches the browser or device.** Server-only. See chapter 18f (security anti-patterns) for the full catalog.

## TL;DR

- Context discipline matters more than model choice for cost.
- Plan budgets are generous but finite — trim context, use subagents, restart between features.
- Use other tools (sed, your editor, the terminal directly) for what they're good at. Don't channel everything through Claude.
