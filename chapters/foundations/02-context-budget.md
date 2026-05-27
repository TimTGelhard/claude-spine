# 02 — The 1M context window: budget, not bandwidth

## What the number actually means

Opus 4.7 has a 1,000,000-token context window. That's roughly 750,000 English words, or ~2,500 pages of plain text. In code terms: 30-50 medium-sized source files comfortably, with room for back-and-forth.

But the window is a *ceiling*, not a working area. Attention degrades long before you hit it.

## The three zones

| Zone | Utilization | What happens |
|------|-------------|--------------|
| **Green** | 0 – 40% | Sharp reasoning, full recall of decisions made earlier in the session. This is where you want to live. |
| **Yellow** | 40 – 70% | Still capable, but specific details from the early conversation start drifting. Claude will sometimes "re-derive" things you already settled. Compaction may have already fired silently. |
| **Red** | 70 – 100% | Quality drop is visible. Forgets early constraints, hallucinates file paths it saw 60 messages ago, contradicts decisions. Compaction is firing repeatedly and losing fidelity each time. Start a fresh terminal. |

You usually can't see the utilization number directly. Use proxies:
- **Lots of file reads + tool output** = burning context fast.
- **Many big diffs in one session** = burning context fast.
- **Conversation feels "long" subjectively** = probably yellow already.

## The folklore vs the reality

> "After prompt 30 quality drops."

Not quite. **30 short prompts asking yes/no questions ≈ 1 prompt that pasted in a 200KB log file.** Prompt *count* doesn't matter. Token *load* does.

What's actually true:
- Long sessions with heavy file reads and big tool outputs degrade fastest.
- A "30 prompt" session of small back-and-forths is fine.
- A 5-prompt session where Claude read your whole codebase is already in yellow.

## What auto-compaction does (and destroys)

When Claude Code approaches the context limit, it summarizes older messages into a compressed snapshot and continues. The new context = summary + recent messages.

**What survives compaction:**
- High-level decisions ("we chose Supabase over Firebase")
- The current task and recent state
- Files you read very recently

**What gets lost or fuzzy:**
- Exact code from earlier in the session
- Specific edge cases you discussed but didn't act on
- Why you ruled out approach X 50 messages ago (Claude may re-suggest it)
- Subtle constraints from your CLAUDE.md if it didn't make it into the summary

**Heuristic:** if you've had compaction fire, treat anything Claude "remembers" from before it as uncertain. Re-state critical constraints if they matter.

## When to start a fresh terminal

Start fresh when:
- You're switching features (most common reason).
- You've finished a feature and are about to start another — don't carry old context forward.
- Claude starts referencing files that don't exist, or suggesting things you already rejected.
- The conversation has crossed ~40-50 substantive exchanges with file work.
- You've had to correct the same misunderstanding twice.

Don't start fresh when:
- You're mid-debug — losing the trail costs more than the context drift.
- You're 5 minutes into a session — even if it feels "long," it's not.

## How to maximize useful context

1. **Front-load orientation.** First message or two: have Claude read `CLAUDE.md`, `ARCHITECTURE.md`, `PROGRESS.md`, `package.json`, and a few key files. After that, it has the project model loaded and you don't need to repeat.
2. **Avoid `cat`-ing big files.** Use `Read` with `offset`/`limit`, or `grep` to pull only the lines that matter.
3. **Delegate big reads to subagents.** A subagent's 500KB exploration returns as a 2KB summary in your main thread. See [16a-when-to-delegate.md](../subagents/16a-when-to-delegate.md).
4. **Trim tool output.** When running tests, filter to failing tests. When grepping, scope tightly. Don't `npm install` with full verbose output if you can help it.
5. **Reference, don't paste.** Instead of pasting a 200-line file into the prompt, tell Claude "read `app/api/route.ts`" — it lands in context the same way, and Claude can re-read precisely the part it needs.

## The 1M context is for depth, not width

Resist the temptation to "load the whole project so Claude has full context." Two problems:
1. The whole project is mostly irrelevant to the current task. Attention dilution makes the relevant 5% harder to use.
2. You waste context on code Claude will never need to look at.

**Better:** load enough to understand the slice you're working on. Trust Claude to read more on demand.

## Practical sizing examples

| Session shape | Approx context used | Status |
|---------------|---------------------|--------|
| Project orientation (read CLAUDE.md + 5 files + git log) | ~30K tokens | Green |
| Building one feature end-to-end (5 file edits, 2 tests, 1 migration) | ~80-150K | Green/yellow |
| Heavy refactor across 15 files | ~200-400K | Yellow |
| Loaded whole codebase + did a feature | ~600K+ | Red, restart soon |
| Long debugging session with verbose test runs | ~300-500K | Yellow, watch carefully |

These are estimates from typical usage, not measured promises.

## TL;DR

- 1M is a budget, not a target. Stay under 40-50% utilization for serious work.
- Prompt count is irrelevant; token load is everything.
- Compaction loses fidelity — restate critical constraints if you cross it.
- Start fresh between features. Don't carry old context forward.
- Use the window for *depth* on one slice, not *breadth* across the project.
