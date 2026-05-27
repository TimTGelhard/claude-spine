# 09c — Examples and anti-examples

The principles ([09a](09a-five-principles.md)) and the structure ([09b](09b-prompt-structure.md)) are abstract until you see the same task prompted badly and well.

## Bad vs good — real comparisons

### Bad
> add login

What's wrong: no auth provider, no UX shape (modal? page? OAuth?), no constraints (RLS, session storage). Claude picks defaults — you won't know which until you see the diff.

### Good
> Add email + Google login. Supabase auth. Use a `/login` page (not modal). After login redirect to `/dashboard`. Session via Supabase's SSR helper, cookies (not localStorage). RLS already enabled on `users`. Follow the auth pattern in CLAUDE.md if there is one.

### Bad
> fix the bug

What's wrong: which bug? expected behavior? what have you tried?

### Good
> The `/quotes` page shows duplicate rows when filter is applied. Reproduce: load `/quotes?status=draft` — should show 3, shows 6. I suspect the join is the cause but haven't confirmed. Find the root cause and fix it. Don't refactor anything unrelated.

### Bad
> make it look better

What's wrong: subjective with no reference. Claude will guess and you'll iterate 5 times.

### Good
> Make the quote table look closer to Linear's table style: tighter row height, monospace numbers, subtle border between rows, status as a small pill on the right. Keep current functionality. Tailwind only.

## High-leverage prompt patterns

These are templates that earn their place across sessions.

### The orientation prompt (first message of every new terminal)

> Read CLAUDE.md, ARCHITECTURE.md, PROGRESS.md, and `package.json`. Tell me in 3 bullets: what project this is, where we are, and what I asked you to do last session if you can tell.

Loads the project model in one shot, ~15K tokens, saves re-explaining for the rest of the session.

### The "challenge me" preamble (for non-trivial decisions)

> Before we build, I'm thinking we should use X. Challenge that — give me one alternative and the honest tradeoff. If X is actually right, say so plainly.

Unlocks Claude as a thinking partner instead of order-taker.

### The "small fix" prompt

> Bug in `app/quotes/page.tsx:42` — `amount` is rendering as cents not euros. Fix.

That's it. Don't ceremony a 2-line fix. (Principle 4: match prompt to scope.)

### The "what's broken" prompt (when stuck)

> I expected X, got Y. Here's what I tried: [...]. Find the actual cause, don't just patch the symptom.

### The "explain it to me" prompt (for learning, not building)

> Walk me through how Supabase RLS evaluates this policy: [paste]. What happens if a user has multiple roles? Give me a worked example.

This is explainer-mode prompting — see [07c-explainer-mode.md](../workflow/07c-explainer-mode.md).

## Visuals — when to add an image

See [10-visuals.md](10-visuals.md) for the full pattern. Quick version: paste screenshots of:
- The broken UI (when reporting bugs).
- The reference design (when matching style).
- The error message *only if you can't paste it as text* — text beats screenshot for anything copy-pasteable.

## TL;DR

- The same task badly vs well-prompted produces visibly different output. Notice the gap.
- Five patterns earn their place: orientation, challenge-me, small-fix, what's-broken, explain-it-to-me.
- Pair with a visual only when the problem is visual.
