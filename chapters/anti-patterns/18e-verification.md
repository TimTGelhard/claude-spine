# 18e — Verification anti-patterns

"Done" requires evidence. Each entry: the anti-pattern, why it fails, what to do instead.

## "It compiled, ship it"

**Fails because:** type-check ≠ correct behavior. Compilers verify shape, not intent.
**Instead:** also run the app and walk the smoke test.

## Trusting Claude's claim that "tests pass" without checking

**Fails because:** Claude might be misreading test output, running the wrong tests, or summarizing a partial pass.
**Instead:** read the test output yourself. Especially for security and auth tests.

## Skipping the two-session auth/RLS check

**Fails because:** the failure mode that leaks one user's data to another is the worst possible bug. Compiles fine. Doesn't show up in single-session testing.
**Instead:** for ANY auth-touching change, two-session check — owner and non-owner. No exceptions. See also [17c-high-stakes-cases.md](../recovery/17c-high-stakes-cases.md).

## Declaring a UI feature done without running it in a browser

**Fails because:** Claude has no eyes. Compiled UI can be broken UI. Screenshots Claude generated from a mock don't reflect the live render.
**Instead:** run the dev server, walk it manually, on desktop AND mobile. See [17b-recovery-moves.md](../recovery/17b-recovery-moves.md) Move G for the full browser-verification pattern.

## Merging diffs you didn't read

**Fails because:** you become a rubber stamp. Bugs slip through. Eventually you can't maintain your own code.
**Instead:** read every diff. If too big to read carefully, the diff is too big — split it.

## TL;DR

Verification skipping is the failure mode that ships bugs to users. Compile-pass, test-pass, and Claude-says-pass are all weaker than you-saw-it-work. The two-session auth check is the single most-important verification ritual — never skip it.
