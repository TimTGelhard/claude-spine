# 07c — Explainer mode

You point Claude at code (yours, library, framework) and ask for understanding.

## When it's right

- About to modify code you didn't write or don't remember.
- Learning a new library / framework you're using.
- Debugging — understanding the actual behavior before guessing fixes.
- Onboarding back into an old project (see also [08a-discovery-sequence.md](08a-discovery-sequence.md)).

## Prompting pattern — explaining a file

```
Walk me through `app/api/webhooks/stripe/route.ts` like I'm new to the project.

For each section:
- What does it do?
- What does it depend on (other files, env vars, Stripe state)?
- What invariants does it assume?
- What would break it?

Be specific. I'd rather you say "I don't know" than guess.
```

## Prompting pattern — explaining a concept

```
Explain Supabase RLS like I understand Postgres but not the
Supabase-specific layer. What's the actual security model?
Where does it fail open? Where does it fail closed?
Give me a worked example with a misconfigured policy.
```

## The trick

Ask for **invariants and failure modes**, not just "what it does." That's where understanding lives. "What it does" you can read. "What breaks it" is the model Claude needs to teach you.

## Failure modes

- **Treating Claude's explanation as ground truth without verifying.** It can confidently misexplain — hallucination on code it didn't read carefully, or on framework versions whose APIs shifted. See [01c-failure-modes.md](../foundations/01c-failure-modes.md).
- **Skipping explainer mode and jumping to "fix it."** Fixing without understanding is gambling. Two-strike rule: if the same fix idea fails twice, you needed explainer first.
- **One-shot explanations without follow-up questions.** The first answer is the surface — the next 2–3 questions are where the real understanding shows up.

## Verifying an explanation

When the stakes are high (security model, async behavior, transaction semantics), cross-check Claude's explanation against:

- The actual code Claude is describing — read the file yourself.
- The official docs for the relevant framework version.
- A small test that should fail if Claude's mental model is wrong.

## TL;DR

- Explainer before modifying unfamiliar code. Five minutes saves hours.
- Ask for invariants and failure modes, not just "what it does."
- Verify the explanation — confident wrong explanations are common.
