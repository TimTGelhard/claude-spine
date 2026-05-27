> **DEPRECATED — v1 single-file chapter.**
> v2 atomic version: see [`chapters/subagents/`](chapters/subagents/) — split into smaller, independently-loadable files.
> Content here is preserved for cross-reference until v2 launch.

# 16 — Subagents: when to delegate, when to do it yourself

Subagents are the single biggest underused lever for keeping main-conversation context clean.

## What a subagent actually is

When you (or Claude) invoke the `Agent` tool, a fresh Claude instance spins up with:
- Its own independent context window.
- Its own tool access (most tools, depending on agent type).
- The prompt you gave it as its only "instructions."
- No memory of your conversation.

It does the work, returns a single text message, and disappears. From your main conversation's perspective, you spent 1 tool call and got back ~1-3K tokens of summarized result. From the subagent's perspective, it could have read 500K tokens of files to produce that summary.

**That's the trade.** You exchange a small text result for unlimited internal context.

## When delegating wins

1. **Broad codebase exploration.** "Find every place we call the Stripe API and tell me what they have in common." — would burn 100K+ in your main thread. Subagent does it, returns 2K of structured findings.
2. **Parallel independent work.** "Check if the auth flow works AND if the deploy is green AND audit dependencies." — three subagents in parallel, all results back in one turn.
3. **Disposable research.** "Find the right way to do X in Next.js 16." — you need the answer, not the search process.
4. **Audits and reviews.** Code review, security review, "what's broken." Independent perspective, no contamination from your own thinking.
5. **Long log analysis.** "Read this 5000-line log and tell me what went wrong." — subagent reads, you get the summary.

## When delegating loses

1. **Anything where the *thinking* matters.** A subagent returns the conclusion, not the reasoning trail. If you need to learn from the process, do it yourself.
2. **Anything you'll want to iterate on.** The subagent vanishes. If you'll want to ask follow-ups, do it in main.
3. **Anything that touches your active file edits.** Coordination between subagent and main thread is painful.
4. **Trivial work.** Spawning a subagent has overhead. For a 10-second task, just do it.
5. **When you don't know enough to write a good prompt.** Garbage in, garbage out, and you can't course-correct mid-run.

## The agent types available to you

From the Agent tool description, your useful options:

| Type | What for |
|------|----------|
| `general-purpose` | Default. Multi-step research and tasks. Has all tools. |
| `Explore` | Read-only search. Fast file-finding, grep, "where is X." Best when you just need to locate code. |
| `Plan` | Architectural planning. Returns a step-by-step plan. Good when you want options before building. |
| `code-reviewer` (if available) | Independent code review. |

For most of your work, `Explore` for "where is X" and `general-purpose` for "do this for me" cover 90%+ of cases.

## Writing a good subagent prompt

A subagent has no context. Your prompt must contain:

1. **What it's doing** — the goal.
2. **Why it matters** — so it can make judgment calls.
3. **What it should report back** — and how long.
4. **Any constraints** — what NOT to do (e.g., "report only, don't edit").

Bad subagent prompt:

> Find auth bugs

Good subagent prompt:

> Audit `app/api/**` for auth issues. Context: this is a Next.js + Supabase MVP. Look specifically for: (1) routes that don't check session, (2) service_role used outside `*.server.ts` files, (3) routes that accept user input without zod validation. Report findings as a punch list with file:line. Under 300 words. Don't edit anything.

The first one wastes the subagent's context on figuring out what you meant.

## Parallel subagents

When you have multiple *independent* tasks, fire them in parallel. In one assistant turn, multiple `Agent` tool calls run concurrently.

Use case: end-of-feature audit.

```
Agent 1: Code review the new auth flow (general-purpose)
Agent 2: Check RLS policies still pass two-session test (Explore)
Agent 3: Search for any TODOs/FIXMEs added this session (Explore)
```

All three return in one turn. Saves wall-clock time *and* keeps main context clean.

**Don't parallelize dependent tasks.** If agent 2's input depends on agent 1's output, do them sequentially.

## Background subagents

The `run_in_background: true` option lets you fire-and-forget. Useful when:
- The task takes minutes (running a full test suite via subagent).
- You want to continue working while it runs.

You get notified when it completes. **Don't poll.** Just keep working.

## Custom subagents — only when narrow and repeated

You can define custom subagents in `~/.claude/agents/<name>.md` with their own system prompt, allowed tools, and model. Treat them as a way to bake a *repeated narrow task* into a callable, not as a roster of always-on specialists.

### Write a custom subagent when

- You've manually written the same delegation prompt 3+ times.
- The task is bounded and well-defined ("fix the linter," "write the migration following our naming convention," "run the deploy checklist").
- It saves real context vs typing the prompt fresh each time.

Examples that earn their keep:
- A "lint-fixer" that only runs `npm run lint --fix` and reports the diff.
- A "migration-writer" that knows your naming convention and RLS-in-same-file rule.
- A "client-site-deploy-checker" that runs Lighthouse + accessibility + JSON-LD validation.

### Don't write custom subagents for

- **"A specialist for each domain" (frontend-specialist, backend-engineer, etc.).** This pattern is what the internet's been hyping — orchestrator + 6-7 specialists working in parallel. It's expensive and overkill for solo MVP work. A single feature run through that pattern can cost 800K-1M tokens. The same feature with one focused subagent for one specific sub-task costs 50-100K. 10x difference.
- **General-purpose tasks.** The built-in `general-purpose` and `Explore` agents already cover broad work.
- **Things that should be CLAUDE.md instructions.** If it's "always behave this way," it's CLAUDE.md, not an agent.
- **Things that should be hooks.** If it's "always run this command after X," it's a hook (chapter 14).

### The orchestrator-with-specialists trap

You'll see screenshots online: `master-orchestrator → 7 specialists in parallel → final review`. Each specialist call: 80-200K tokens. Total per feature: ~900K tokens. On Max 20x, that's a non-trivial fraction of weekly budget for one feature.

The pattern is real, but it's calibrated for: enterprise teams with no token budget concerns, demos that look impressive on social media, or genuinely massive multi-week projects.

For solo MVP / client-site work, the lightweight pattern wins on every dimension:
- **One focused subagent for one specific task** = ~50-100K tokens.
- **Same end result** for an MVP feature.
- **No coordination overhead** — you're the orchestrator.
- **Re-callable** — invoke when needed, don't pre-define the world.

Use the heavy pattern only if you can articulate why your specific feature genuinely needs it. Default to lightweight.

### Designing a good narrow subagent

Frontmatter:
- `name`: kebab-case, used as `subagent_type`.
- `description`: when this should fire. Specific triggers — keywords, scenarios. Not "a helper for X."
- `model`: `sonnet` by default. `opus` only if the task needs deeper reasoning.
- `tools` (optional): restrict if it should be read-only or limited.

Body:
- One paragraph: what it does.
- Operating rules: what it always does (5-10 bullets max).
- Output format: what it returns (so the main thread can use the result).
- When NOT to invoke: clarify the scope.

Use the `skill-creator` skill (you have it) to author these — it knows the current Claude Code schema.

## Anti-patterns

- **"Just spawn a subagent to do the whole feature."** Subagents are bad at multi-decision work because you can't course-correct. They're for bounded tasks.
- **Subagent doing what TaskCreate could do.** Tracking progress within your own session isn't subagent work.
- **Re-reading the subagent's findings yourself anyway.** If you don't trust the summary, the delegation didn't save you context.
- **Spawning a subagent inside another subagent.** They can, but it's almost always a sign you should restructure.

## Mental model

Think of it like hiring a contractor for one specific job:
- Write a clear brief (the prompt).
- They go away.
- They come back with a deliverable (the summary).
- You can't follow them around while they work.
- You'd never hire one to "build the whole product" — but for "audit the foundation," they're perfect.

## TL;DR

- Delegate broad research, audits, parallel independent work.
- Don't delegate when the *thinking* matters or you'll iterate.
- Write the brief like the agent has no context — because it doesn't.
- Use `Explore` for finding code, `general-purpose` for doing tasks.
- Parallel independent agents = single turn, multiple wins.
