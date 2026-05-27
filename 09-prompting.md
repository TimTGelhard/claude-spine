> **DEPRECATED — v1 single-file chapter.**
> v2 atomic version: see [`chapters/prompting/`](chapters/prompting/) — split into smaller, independently-loadable files.
> Content here is preserved for cross-reference until v2 launch.

# 09 — Prompting: getting good output the first time

The lever with the highest ROI for output quality. A 2-minute investment in a better prompt regularly saves 30 minutes of rework.

## The core principles

1. **State the goal, not the steps.** Claude is smart enough to pick steps. It is not psychic about goals.
2. **Show, don't describe.** Example > paragraph every time.
3. **Give the constraints up front.** Not at the end as "oh by the way."
4. **Match prompt to scope.** Tiny tasks get tiny prompts. Complex tasks get structured prompts.
5. **One ask per prompt.** Bundling two unrelated asks halves the quality of both.

## The structure that consistently works

For non-trivial work:

```
[CONTEXT]   — what project, where we are, why this matters
[TASK]      — what you want, concretely
[CONSTRAINTS] — what NOT to do, what MUST be true
[EXAMPLES]  — what good looks like (optional but powerful)
[OUTPUT]    — what shape the response should take
```

Real example:

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

This prompt has the same information as a 200-word paragraph but is parseable in 5 seconds.

## Good vs bad prompts (real comparisons)

### Bad
> add login

What's wrong: no auth provider mentioned, no UX shape (modal? page? OAuth?), no constraints (RLS, session storage). Claude will pick reasonable defaults — but you won't know what it picked until you see the diff.

### Good
> Add email + Google login. Supabase auth. Use a `/login` page (not modal). After login redirect to `/dashboard`. Session via Supabase's SSR helper, cookies (not localStorage). RLS already enabled on `users`. Follow the auth pattern in CLAUDE.md if there is one.

### Bad
> fix the bug

What's wrong: which bug? what's the expected behavior? what have you tried?

### Good
> The `/quotes` page shows duplicate rows when filter is applied. Reproduce: load `/quotes?status=draft` — should show 3, shows 6. I suspect the join is the cause but haven't confirmed. Find the root cause and fix it. Don't refactor anything unrelated.

### Bad
> make it look better

What's wrong: subjective with no reference. Claude will guess and you'll iterate 5 times.

### Good
> Make the quote table look closer to Linear's table style: tighter row height, monospace numbers, subtle border between rows, status as a small pill on the right. Keep current functionality. Tailwind only.

## High-leverage patterns

### The "challenge me" preamble
For non-trivial decisions:

> Before we build, I'm thinking we should use X. Challenge that — give me one alternative and the honest tradeoff. If X is actually right, say so plainly.

This unlocks Claude as a thinking partner instead of order-taker, which is what your global CLAUDE.md asks for anyway.

### The orientation prompt (start of every session)
First message of a new terminal:

> Read CLAUDE.md, ARCHITECTURE.md, PROGRESS.md, and `package.json`. Tell me in 3 bullets: what project this is, where we are, and what I asked you to do last session if you can tell.

This loads the project model in one shot, costs ~15K tokens, and saves you re-explaining for the rest of the session.

### The "small fix" prompt
For genuinely small things:

> Bug in `app/quotes/page.tsx:42` — `amount` is rendering as cents not euros. Fix.

That's it. Don't ceremony a 2-line fix.

### The "what's broken" prompt
When stuck:

> I expected X, got Y. Here's what I tried: [...]. Find the actual cause, don't just patch the symptom.

### The "explain it to me" prompt
For learning, not building:

> Walk me through how Supabase RLS evaluates this policy: [paste]. What happens if a user has multiple roles? Give me a worked example.

## Things that *waste* tokens

Stop doing these:

- **"Please"** and **"thank you"** — fine for tone, but unnecessary. Claude isn't offended by direct requests.
- **Restating the obvious.** "As you know, this is a Next.js project..." — yes, Claude saw `package.json`.
- **Apologizing for being unclear** — just be clear. Skip the meta-commentary.
- **Pasting whole files** when you could say `read app/quotes/page.tsx`. Same effect, less context burned.
- **Asking Claude to summarize what it just did.** You can see the diff. (This is in your global CLAUDE.md already.)

## Iterative prompting

When the first output isn't right:

1. **Be specific about what's wrong.** Not "this isn't right" — "the badge color logic doesn't handle the `archived` state."
2. **Don't restart from scratch.** "Modify what you have — keep the table structure, just fix the badge."
3. **One issue at a time.** If there are three problems, fix them in three turns, not one giant correction.

## Multi-turn prompting strategy

Within a session:

| Turn | Goal |
|------|------|
| 1 | Orient (read project files) |
| 2 | Discuss approach, push back |
| 3-N | Build in chunks, verify each |
| Last | Commit + update PROGRESS.md |

Each turn should produce *something concrete* — a decision, an edit, a verified fact. If a turn produces just talk, you wasted it.

## When to use plan mode

Plan mode (Claude proposes, you approve, then it builds) is right when:
- The task touches >3 files.
- There's an architectural choice involved.
- The cost of "Claude picks wrong" is high (auth, payments, schema).

Skip plan mode when:
- You already know what you want.
- The fix is one file, one obvious change.

## Using visuals in prompts

See [10-visuals.md](10-visuals.md). Quick version: paste screenshots of:
- The broken UI (when reporting bugs).
- The reference design (when matching style).
- The error message (when debugging) — but text > screenshot if you can paste text.

## TL;DR

- Structure: context, task, constraints, examples, output shape.
- Show don't describe. Examples > paragraphs.
- One ask per prompt.
- First message of a session = orientation prompt.
- "Challenge me" preamble for non-trivial decisions.
- Be specific about what's wrong when iterating.
