# 01a — The LLM loop

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

## The asymmetric cost of mistakes

Correctness > speed > cost. Reordering this is the most common failure mode of AI-heavy workflows.

- A bug in shipped code costs hours-to-days to fix, plus user trust.
- A 30-minute slower session costs 30 minutes.
- An extra Opus call costs cents.

When tempted to skip verification "to save time," remember: the time you save is one-tenth the time the bug will cost. Always verify.

## What this implies

You only have three levers on output quality, and three failure modes when quality drops. The rest of the foundations chapter unpacks both:

- [01b-three-levers.md](01b-three-levers.md) — context curation, scope sizing, verification.
- [01c-failure-modes.md](01c-failure-modes.md) — drift, dilution, hallucination.

Everything else in the manual is an application of these.
