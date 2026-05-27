# 08b — Brownfield safety patterns

After discovery ([08a-discovery-sequence.md](08a-discovery-sequence.md)), ease in. Don't open with a refactor.

## Pattern A — The smallest visible improvement

Pick a tiny, isolated change a user would notice. A copy fix. A spacing tweak. A clearer error message.

Goal: prove the build/deploy loop works *for you* before any real change.

If the smallest visible change fails (build broken, deploy creds expired, tests don't run), you've found that out cheaply — before staking a real feature on the same infrastructure.

## Pattern B — A test before a refactor

Found a function you want to clean up? Write a test for its current behavior first. Then refactor. The test catches regressions.

Even one assertion is better than zero.

## Pattern C — Comment, don't rewrite

You spot weird code. Tempted to "clean it up." Don't — not yet.

Instead: add a one-line comment with what you *think* it does and a question mark.

```ts
// Why is this filtered twice? Is the first .filter a leftover or load-bearing?
```

Now it's a documented question. Next session (or a quiet moment), come back, find out. Maybe ask Claude to explain. Then fix once you understand.

## Pattern D — Read commits before files

For an unfamiliar file, `git log -p <file>` shows its history. The commit messages tell you *why* it looks the way it does. Often more useful than reading the current code.

The diff history is the *story* of how the code got here. The current code is just the latest frame.

## When to break each pattern

Patterns A–D are defaults, not laws.

- **Skip Pattern A** if the smallest visible change *is* the work (a client asked for one copy tweak — just do it).
- **Skip Pattern B** if the function is genuinely trivial and you fully understand it. Two assertions for a one-line helper is bureaucracy.
- **Skip Pattern C** if the weird code is *obviously* a bug you can prove and reproduce. Then it's a normal fix, not a "what does this do" question.
- **Skip Pattern D** if `git log -p <file>` shows the file is brand new (one commit, "initial"). The history won't tell you anything.

The principle: in brownfield, default to *understanding before changing*. Break the default only when you can articulate why.

## TL;DR

- Don't refactor on first contact. Earn the right.
- Smallest visible change first, to verify the loop works.
- Test before refactor; comment before rewrite; commits before files.
