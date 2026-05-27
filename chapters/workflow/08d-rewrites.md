# 08d — When to suggest a rewrite vs continue

Sometimes the right brownfield answer is "this should be rebuilt." Most of the time, it isn't.

## Signs a rewrite might be right

- Core architecture decisions are wrong for current needs (e.g. monolithic file that should be modular).
- Dependencies are >2 major versions behind, with breaking changes between them.
- No tests + complex business logic = high-risk to change.
- The codebase is small enough that a rewrite is days, not weeks.

## Signs the rewrite urge is wrong

Most "this should be rewritten" feelings are because *you don't understand it yet*. Before deciding:

- Have you run the full discovery sequence ([08a-discovery-sequence.md](08a-discovery-sequence.md))?
- Have you traced one critical data flow end-to-end?
- Have you read the commit history of the worst-looking files? They often have reasons.
- Can you articulate the *specific* architectural decision that's wrong, not just "this feels bad"?

If you can't answer those, the rewrite urge is probably premature.

## If the rewrite is real

Plan it as a project (the greenfield workflow — [05-overview.md](05-overview.md)). Don't try to "rewrite incrementally" — that path usually produces a broken mix of old and new.

Treat the old codebase as the spec. The new one inherits the *behavior*, not the *code*.

## Brownfield anti-patterns

- **Refactoring on first contact.** You don't know enough yet.
- **Updating dependencies in bulk.** Each is a separate risk.
- **Removing "dead code" you found.** It might be load-bearing in a non-obvious way. Comment it as suspected dead, leave for a follow-up.
- **Rewriting to your current preferences.** Conventions exist for reasons; matching them keeps the codebase coherent.
- **Skipping the smoke baseline.** Then you can't tell what you broke.
- **Trusting `CLAUDE.md` without verifying.** Old `CLAUDE.md` may not reflect current code. Spot-check.

## A real brownfield session, end to end

For a client landing site you built 8 months ago, asked to add a new service page:

1. Open Claude Code, fresh terminal.
2. Use Prompt E from `SESSION_STARTER.md`.
3. Claude reads `CLAUDE.md`, `ARCHITECTURE.md` (if it exists), recent commits, key files. Reports back.
4. You verify the site still builds: `npm install && npm run build && npm run dev`.
5. You walk the live site smoke tests — does the existing site work?
6. *Now* discuss the new service page. Match existing patterns. Match existing copy style.
7. Build the page.
8. Smoke tests again — does everything still work?
9. Lighthouse — did you regress perf?
10. Commit, deploy.
11. Update `PROGRESS.md` with what shipped + the date (so future-you knows when this last touched).

If you skipped 1–5 and went straight to building, you'd ship the new page just fine. But you wouldn't notice that you broke the contact form because a dependency drifted. That's the brownfield cost of skipping discovery.

## TL;DR

- The rewrite urge is usually premature. Run discovery first.
- If the rewrite is real, plan it greenfield. No incremental mixed-codebase path.
- Brownfield anti-patterns are mostly variants of "I changed it before I understood it."
