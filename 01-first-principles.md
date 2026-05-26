# 01 — First principles

> Read this once and re-read when you feel like you're flailing.
> The rest of the manual is mechanics. This is the worldview.

## What Claude Code actually is

A loop:

```
Your prompt → LLM thinks → LLM picks tools → tools run → results return → LLM thinks → ...
```

The LLM is stateless within a single response and only knows what's in its context window. The "memory" is the conversation, the loaded files, and whatever you've put in `CLAUDE.md` / skills / memory. There's no hidden state. There's no "Claude learning your project over time."

This has two consequences that drive everything else:

1. **Quality is a function of context.** Garbage in, garbage out. Curated in, sharp out.
2. **Every tool call costs context.** A 5,000-line file read isn't free — it lives in context for the rest of the session.

If you internalize only one thing: **context is the budget, not the bandwidth.**

## The three levers

You only have three levers on output quality. Everything in this manual is an application of one of them.

### Lever 1 — Context curation
What's in the window. What's not. What's loaded at the start vs on-demand.

Maximizing: `CLAUDE.md` quality, project docs, `Read` with `offset`/`limit`, subagent delegation, fresh sessions.

### Lever 2 — Scope sizing
How much you're asking for in one session, one prompt, one decision.

Maximizing: one session = one feature, plan mode for non-trivial work, one bug per change.

### Lever 3 — Verification
Whether you confirm reality matches what Claude told you.

Maximizing: smoke tests, two-session RLS checks, reading the diff, running the app.

**Failure mode of beginners:** ignore all three. Paste a vague prompt, hope.
**Failure mode of intermediates:** apply one (usually scope). Get burned by the other two.
**Advanced operator:** all three, every session, as discipline.

## The three failure modes Claude exhibits

When output quality drops, it's almost always one of these:

### Drift
Claude forgets earlier decisions and contradicts them.

Cause: long session, context filled with noise, compaction has fired.

Fix: fresh terminal, explicit re-state of constraints, write decisions to `DECISIONS.md` so they survive sessions.

### Dilution
Claude has the relevant info in context but can't focus on it through the noise.

Cause: loaded too much, attention spread thin. Often after dumping multiple big files.

Fix: don't load the whole project. Load the slice. Use subagents for exploration.

### Hallucination
Claude confidently invents file paths, function names, library APIs, version-specific syntax.

Cause: trained-knowledge cutoff + confident generation. Worst on recent framework changes.

Fix: verify before accepting. Have Claude check that a function exists. Cross-reference with `package.json` versions. Catch confident wrong answers before they become commits.

Knowing *which* failure is happening tells you what to fix. Drift = restart. Dilution = trim context. Hallucination = verify the specific claim.

## The advanced operator's mindset

What separates intermediate from advanced isn't more tools — it's discipline applied automatically.

### 1. Treat context like cash
You have a budget. Spending it on irrelevant file reads is wasted money. Track utilization mentally even when not displayed.

### 2. Plan sessions, not just prompts
Before opening Claude Code, know: what's the one feature, what's out of scope, what does "done" look like, which files matter. The prompt is the last thing — the planning happens before.

### 3. Delegate without losing trust
A subagent's summary saves context but discards reasoning. Use delegation when the *answer* matters, not when the *thinking* matters. Verify the parts that warrant verification.

### 4. Verify deterministically
"It compiled" is not "it works." Build the habit: every claim Claude makes about correctness gets checked against reality before you trust it.

### 5. Persist what matters, forget what doesn't
Decisions, constraints, domain knowledge → files. State, progress, immediate tasks → also files (PROGRESS.md). Random session chatter → let it die when the terminal closes.

### 6. Recognize failure early
Two corrections of the same misunderstanding = restart. Hallucinated file path = verify everything else from this session. Diff is bigger than the change should be = stop and read it line by line.

### 7. Stay in the loop
You ship what Claude produces. Don't accept code you couldn't re-implement. Don't merge diffs you didn't read. AI-heavy workflows fail when the operator becomes a rubber-stamp.

## The asymmetric cost of mistakes

Correctness > speed > cost. Reordering this is the most common failure mode of AI-heavy workflows.

- A bug in shipped code costs hours-to-days to fix, plus user trust.
- A 30-minute slower session costs 30 minutes.
- An extra Opus call costs cents.

When tempted to skip verification "to save time," remember: the time you save is one-tenth the time the bug will cost. Always verify.

## The manual's structure

The manual is six parts. Each chapter applies one of the three levers to a specific concern.

| Part | # | Chapter |
|------|---|---------|
| **I. Foundation** | 01 | First principles (this file) |
| | 02 | Context window truth |
| | 03 | Limits |
| | 04 | Models and economics |
| **II. Process** | 05 | Workflow |
| | 06 | Feature sizing |
| | 07 | Collaboration modes |
| | 08 | Brownfield |
| **III. Communication** | 09 | Prompting |
| | 10 | Visuals |
| | 11 | Proactive signaling |
| **IV. Persistence** | 12 | Skills, memory, CLAUDE.md |
| | 13 | Custom skills |
| | 14 | Hooks and automation |
| **V. Tactics** | 15 | Tool palette |
| | 16 | Subagents |
| **VI. Failure** | 17 | Recovery playbook |
| | 18 | Anti-patterns |

`templates/` is separate — those are the *working files* you fill in per project. This manual is *read-only reference*.

## Read this manual when

- Starting a new project (skim 05, 04, then templates).
- Stuck mid-project (17).
- Quality dropping (02, 06).
- Considering a big architectural decision (05, 16, 04).
- Onboarding yourself back into a project you haven't touched in months (08).
- Before recommending Claude Code to someone else.

The manual is calibrated to the current Claude Code (Opus 4.7, 1M context, skills + memory + subagents). When the platform changes meaningfully, the manual changes with it.

## TL;DR

- Context is a budget. Spend it deliberately.
- Three levers: curation, scope, verification. Apply all three, always.
- Three failure modes: drift, dilution, hallucination. Diagnose before fixing.
- The advanced operator's edge isn't knowing more tools — it's applying discipline automatically.
- You ship what Claude produces. Stay in the loop.
