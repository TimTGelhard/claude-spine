# 01b — Three levers: context, scope, verification

You only have three levers on output quality. Everything in this manual is an application of one of them.

## Lever 1 — Context curation

What's in the window. What's not. What's loaded at the start vs on-demand.

Maximizing: `CLAUDE.md` quality, project docs, `Read` with `offset`/`limit`, subagent delegation, fresh sessions.

## Lever 2 — Scope sizing

How much you're asking for in one session, one prompt, one decision.

Maximizing: one session = one feature, plan mode for non-trivial work, one bug per change.

## Lever 3 — Verification

Whether you confirm reality matches what Claude told you.

Maximizing: smoke tests, two-session RLS checks, reading the diff, running the app.

## The maturity curve

- **Beginners:** ignore all three. Paste a vague prompt, hope.
- **Intermediates:** apply one (usually scope). Get burned by the other two.
- **Advanced operator:** all three, every session, as discipline.

What separates intermediate from advanced isn't more tools — it's discipline applied automatically.

## Applying the levers as discipline

### 1. Treat context like cash
You have a budget. Spending it on irrelevant file reads is wasted money. Track utilization mentally even when not displayed.

### 2. Plan sessions, not just prompts
Before opening Claude Code, know: what's the one feature, what's out of scope, what does "done" look like, which files matter. The prompt is the last thing — the planning happens before.

### 3. Delegate without losing trust
A subagent's summary saves context but discards reasoning. Use delegation when the *answer* matters, not when the *thinking* matters. Verify the parts that warrant verification.

### 4. Verify deterministically
"It compiled" is not "it works." Build the habit: every claim Claude makes about correctness gets checked against reality before you trust it.

### 5. Persist what matters, forget what doesn't
Decisions, constraints, domain knowledge → files. State, progress, immediate tasks → also files (`PROGRESS.md`). Random session chatter → let it die when the terminal closes.

### 6. Stay in the loop
You ship what Claude produces. Don't accept code you couldn't re-implement. Don't merge diffs you didn't read. AI-heavy workflows fail when the operator becomes a rubber-stamp.

## TL;DR

- Three levers: curation, scope, verification. Apply all three, always.
- The edge isn't knowing more tools — it's applying discipline automatically.
- You ship what Claude produces. Stay in the loop.
