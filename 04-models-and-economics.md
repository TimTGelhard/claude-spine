> **DEPRECATED** — v2 atomic version: [`chapters/foundations/`](chapters/foundations/). Full v1→v2 map: [`V1-CHAPTERS-DEPRECATED.md`](V1-CHAPTERS-DEPRECATED.md). Body kept for cross-reference.

# 04 — Models and economics

Picking the right model and mode for the task. Relevant because you're on Max 20x — generous, but not infinite, and quality varies meaningfully across models.

## The current Claude lineup (May 2026)

| Model | ID | Context | Strengths | Cost class |
|-------|-----|---------|-----------|------------|
| Opus 4.7 | `claude-opus-4-7` | 1M (with `[1m]`) / 200K default | Hardest reasoning, best long-context, best multi-file refactors | Highest |
| Sonnet 4.6 | `claude-sonnet-4-6` | 200K | Workhorse — fast, capable, sufficient for most tasks | Mid |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | 200K | Fast and cheap for narrow, well-specified tasks | Low |

You're currently in this session on Opus 4.7 with 1M context. That's the top of the stack.

Note: the model lineup moves fast. Verify the current options before committing to "always use X" — you may be missing a newer version.

## Picking a model for the task

### Opus 4.7 — use when
- Architectural decisions or design discussions.
- Multi-file refactors where coherent reasoning matters.
- Long-context work (>200K relevant input).
- Debugging stubborn bugs where shallow guesses keep failing.
- High-stakes code (auth, payments, anything user-data-touching).
- First-time exploration of a complex codebase.

### Sonnet 4.6 — use when
- Standard feature build sessions (most of your work).
- Bug fixes with clear root cause.
- Mechanical refactors.
- Routine prompting + iteration.
- Anything where Sonnet has handled similar tasks well before.

This is the default. Don't reach for Opus unless you need it.

### Haiku 4.5 — use when
- Highly bounded, well-specified tasks ("rename this function across these files").
- Quick lookups, simple transformations.
- Anything where you'd be annoyed paying Opus prices.

For Claude Code interactive work, Haiku is often *too* shallow — use sparingly.

## Plan mode — the highest-leverage feature you probably underuse

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

## Context cost discipline

Beyond model choice, the biggest cost is *how much context you load*. Reminder:

- Every `Read` puts the file in context for the rest of the session.
- Every `Bash` output puts the output in context (filtered if you piped to head/tail).
- Subagents return summaries, not full content — they're a context-cost-reduction tool.

**A 1M-context Opus session using only 30K tokens is dirt cheap. A 200K-context Sonnet session using all 200K is more expensive than the Opus one.** The lever isn't only model choice — it's load discipline.

## Max 20x plan — what you actually have

The Max 20x plan gives you 20x the standard Claude Pro usage. In practice:

- More tokens per week than you'll exhaust on solo MVP work — *if* you spend them well.
- Generous but not infinite. Heavy daily Opus + 1M-context use can still hit limits.
- Limits reset weekly. You'll feel a hard wall, not a soft slowdown.

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
- **Key never reaches the browser or device.** Server-only. See your global CLAUDE.md security rules.

(Your global CLAUDE.md already covers this. Cross-referenced here so the manual is self-contained.)

## Mental rule of thumb

> "Use the cheapest tool that can do the job correctly. Don't optimize cost over correctness — but don't waste budget on overkill either."

- Bug fix → Sonnet
- Architecture decision → Opus
- "Find every place this is used" → Subagent (Explore)
- "Why is this broken?" → Opus if you've already tried Sonnet and it's still stuck

## TL;DR

- Default: Sonnet 4.6. Reach for Opus when the task needs it.
- Plan mode for anything non-trivial — friction up front saves rework.
- Context discipline matters more than model choice for cost.
- Max 20x is generous but finite — trim context, use subagents, restart between features.
- Use other tools (sed, your editor, the terminal directly) for what they're good at. Don't channel everything through Claude.
