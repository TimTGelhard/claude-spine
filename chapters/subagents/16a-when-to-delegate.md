# 16a — When to delegate, when to do it yourself

Subagents are the single biggest underused lever for keeping main-conversation context clean.

## What a subagent actually is

When you invoke the `Agent` tool, a fresh Claude spins up with:

- Its own independent context window.
- Its own tool access (most tools, depending on agent type).
- The prompt you gave it as its only "instructions."
- No memory of your conversation.

It does the work, returns a single text message, and disappears. From your main thread: you spent 1 tool call and got back ~1–3K tokens. From the subagent: it could have read 500K tokens of files to produce that summary.

**That's the trade.** A small text result for unlimited internal context.

## When delegating wins

1. **Broad codebase exploration.** "Find every place we call the Stripe API and tell me what they have in common." Would burn 100K+ in your main thread; subagent returns 2K of structured findings.
2. **Parallel independent work.** "Check auth flow AND deploy status AND audit dependencies." Three subagents in parallel, all results in one turn.
3. **Disposable research.** "Find the right way to do X in Next.js 16." You need the answer, not the search process.
4. **Audits and reviews.** Independent perspective, no contamination from your own thinking.
5. **Long log analysis.** "Read this 5000-line log and tell me what went wrong."

## When delegating loses

1. **Anything where the *thinking* matters.** A subagent returns the conclusion, not the reasoning trail. If you need to learn from the process, do it yourself.
2. **Anything you'll want to iterate on.** The subagent vanishes. Follow-ups can't reach it.
3. **Anything touching your active file edits.** Coordination is painful.
4. **Trivial work.** Spawning has overhead. For a 10-second task, just do it.
5. **When you don't know enough to write a good prompt.** Garbage in, garbage out, no mid-run course correction.

## Writing a good subagent prompt

A subagent has no context. The prompt must contain:

1. **What it's doing** — the goal.
2. **Why it matters** — so it can make judgment calls.
3. **What it should report back** — and how long.
4. **Any constraints** — e.g., "report only, don't edit."

Bad:

> Find auth bugs

Good:

> Audit `app/api/**` for auth issues. Context: Next.js + Supabase MVP. Look for: (1) routes without session check, (2) service_role outside `*.server.ts`, (3) routes accepting user input without zod validation. Report findings as a punch list with file:line. Under 300 words. Don't edit anything.

The first wastes the subagent's context figuring out what you meant.

## Mental model

Hiring a contractor for one specific job:

- Write a clear brief (the prompt).
- They go away.
- They come back with a deliverable (the summary).
- You can't follow them around while they work.
- You'd never hire one to "build the whole product" — but for "audit the foundation," they're perfect.

## TL;DR

- Delegate broad research, audits, parallel independent work.
- Don't delegate when the *thinking* matters or you'll iterate.
- Write the brief like the agent has no context — because it doesn't.
- Subagents are contractors, not specialists on retainer.
