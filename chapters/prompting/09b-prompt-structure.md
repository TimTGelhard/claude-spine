# 09b — Prompt structure: CONTEXT / TASK / CONSTRAINTS / EXAMPLES / OUTPUT

The structure that consistently works for non-trivial prompts. For one-line fixes, skip it — see [09a-five-principles.md](09a-five-principles.md) (principle 4: match prompt to scope).

## The shape

```
[CONTEXT]     — what project, where we are, why this matters
[TASK]        — what you want, concretely
[CONSTRAINTS] — what NOT to do, what MUST be true
[EXAMPLES]    — what good looks like (optional but powerful)
[OUTPUT]      — what shape the response should take
```

## A real one

```
[CONTEXT] We're building the quote list page. Schema is in
ARCHITECTURE.md. There's already a /api/quotes route that
returns an array of Quote.

[TASK] Build the QuoteList component at app/quotes/page.tsx.
Fetches the list server-side, renders a table with columns:
Customer, Amount, Status, Created. Status is a colored badge.

[CONSTRAINTS]
- Server component, no "use client".
- Tailwind only, no extra deps.
- Handle empty list and error.
- Amount displayed using the project's locale formatter.

[EXAMPLES]
Look at app/invoices/page.tsx — same pattern.

[OUTPUT]
Edit the file. Don't add tests this session.
```

Same information as a 200-word paragraph, but parseable in 5 seconds.

## Why each section earns its place

- **CONTEXT** prevents Claude from re-deriving project facts. The cheapest tokens you'll ever spend.
- **TASK** is the goal (principle 1). One sentence if possible.
- **CONSTRAINTS** is the highest-leverage section — most reworks happen because a constraint was implied, not stated.
- **EXAMPLES** is a pointer ("look at file X") or a small literal example. Pointers are cheaper.
- **OUTPUT** stops Claude from over-delivering: when you don't say "no tests," you sometimes get tests.

## Iterative prompting

When the first output isn't right:

1. **Be specific about what's wrong.** Not "this isn't right" — "the badge color logic doesn't handle the `archived` state."
2. **Don't restart from scratch.** "Modify what you have — keep the table structure, just fix the badge."
3. **One issue at a time.** Three problems → three turns, not one giant correction.

## Multi-turn cadence inside a session

| Turn | Goal |
|------|------|
| 1 | Orient (read project files) |
| 2 | Discuss approach, push back |
| 3-N | Build in chunks, verify each |
| Last | Commit + update PROGRESS.md |

Each turn should produce *something concrete* — a decision, an edit, a verified fact. If a turn produces just talk, it was wasted.

## When to add plan mode

Plan mode (Claude proposes, you approve, then it builds) is right when:
- The task touches >3 files.
- There's an architectural choice involved.
- The cost of "Claude picks wrong" is high (auth, payments, schema).

Skip plan mode when you already know what you want and the fix is one file. See [04b-plan-and-fast-mode.md](../foundations/04b-plan-and-fast-mode.md).

## TL;DR

- Five sections for non-trivial work; skip them for tiny tasks.
- CONSTRAINTS earns its place every time — most rework comes from unstated constraints.
- Iterate by narrowing on the specific bug, not by restarting.
- Plan mode when >3 files or architectural — otherwise just prompt directly.
