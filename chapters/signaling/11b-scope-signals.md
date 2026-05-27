# 11b — Scope-state signals

Trigger conditions and one-line signals when the work is growing past the original ask.

Foundation: [11-overview.md](11-overview.md). Related discipline: [06-feature-sizing.md](../workflow/06-feature-sizing.md).

## The trigger table

| Trigger | Signal |
|---|---|
| 8+ files touched, original ask implied fewer | "Scope check: we've touched 8 files. Original ask was X. Continue or commit + split?" |
| New unrelated request bundled with current work | "This is a different feature/bug. Per one-bug-per-change, suggest finishing the current one first." |
| Bug fix is becoming a refactor | "We're past the fix — this is a refactor. Split or continue?" |
| 4+ distinct architectural decisions in one session | "We've made several decisions this session. Quality of further decisions will drop. Recommend committing and pausing here." |

## What counts as "in scope"

If the user's ask was *"add a status filter to the quote list"* — in scope is:

- The filter UI element.
- The query plumbing for filter state.
- The one related test file if tests exist.

Out of scope (each is its own ask):

- Refactoring the parent table component "while we're here."
- Adding a sort option "since we're touching filters."
- Renaming the route file because Claude thinks the name could be better.

When Claude notices itself sliding into the second list, the signal fires.

## The bug-fix-becoming-a-refactor trap

This is the most common scope-creep shape. The fix is two lines, but Claude (or the user) notices something "smells" and starts rewriting the surrounding function. Don't.

Pattern to apply:

1. Fix the bug. Minimum diff.
2. *If* the surrounding code is genuinely broken — note it. Don't bundle. ([18b-scope.md](../anti-patterns/18b-scope.md): one bug per change.)
3. Next session can pick up the refactor as its own ask.

## When the user is the one driving scope creep

The user adds an unrelated ask mid-session. Don't silently absorb it. Surface the choice:

> Adding rate-limiting and changing the filter UX are different features. Want to finish the filter first, commit, then start fresh on rate-limiting? Or pivot now and leave the filter as work-in-progress?

Trust them to decide. Don't lecture.

## TL;DR

- Four triggers; each gets a one-line signal that names the size and offers continue-or-split.
- Bug fixes don't quietly become refactors. Note adjacent issues, don't bundle them.
- When the user expands scope, restate the choice — don't quietly absorb.
