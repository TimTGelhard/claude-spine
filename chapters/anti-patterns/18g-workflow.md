# 18g — Workflow anti-patterns

Stages exist because skipping them ships broken software. Each entry: the anti-pattern, why it fails, what to do instead.

## Skipping stage 0 (Decide) — going straight to building

**Fails because:** you build something you didn't actually want. Realizing it at stage 4 costs more than the whole stage 0 would have.
**Instead:** `PROJECT_BRIEF.md` filled in before any code. See [05a-stage-0-decide.md](../workflow/05a-stage-0-decide.md).

## Skipping stage 1 (Prep) — "I'll set up tooling as I need it"

**Fails because:** scaffolding decisions made under feature pressure are worse than scaffolding decisions made deliberately. You'll pick the first option that unblocks the current task and live with it for the rest of the project (env handling, linter config, test runner, CI shape). Sunk-cost lock-in is real.
**Instead:** stage 1 picks the stack, lays down `CLAUDE.md` + templates, runs the first migration, ships the first deploy. Even rough versions of these decisions are better than ad-hoc ones. See [05b-stage-1-prep.md](../workflow/05b-stage-1-prep.md).

## Skipping stage 2 (Architect) — "let's just start coding"

**Fails because:** without `ARCHITECTURE.md`, every session re-derives the data model and route shape. Decisions drift across sessions because there's no source of truth. You end up with `users`, `Users`, `accounts`, and `profiles` all meaning the same thing in different files.
**Instead:** even a 60-line `ARCHITECTURE.md` (stack, data model, route shape, auth, deployment) pays for itself the second session. Use planner mode to draft it; argue with Claude until the trade-offs are explicit. See [05c-stage-2-architect.md](../workflow/05c-stage-2-architect.md).

## Skipping stage 4 (Integrate) — "ship feature, ship next feature, never test boundaries"

**Fails because:** features that work in isolation break at their seams. Auth + a feature that uses auth. Two features writing to the same table. A new route that overlaps an existing redirect. Integration bugs hide until a real user walks the full path.
**Instead:** every 3–5 features, run a dedicated integration session — walk the full user journey, exercise the seams. Regressions caught here are 10× cheaper than regressions caught in production. See [05e-stage-4-integrate.md](../workflow/05e-stage-4-integrate.md).

## Skipping stage 5 (Harden) — calling demoable "done"

**Fails because:** missing-state bugs (empty, loading, error, offline, dark mode, i18n, a11y) ship to users. Demoable means "the happy path works on your machine," not "users can use this."
**Instead:** dedicated hardening sessions for the full state matrix. See [05f-stage-5-harden.md](../workflow/05f-stage-5-harden.md).

## Skipping stage 6 (Ship) — pushing to prod and "dealing with issues as users report them"

**Fails because:** the deploy sequence (local smoke → security review → dep audit → deploy → prod smoke → handover) catches deployment-environment-specific bugs that didn't exist in dev. Skipping it means users find them first, and by then your reputation cost has already been paid.
**Instead:** treat the ship as a defined sequence, not "just push." Five minutes of post-deploy smoke testing in the real environment is the cheapest insurance you'll ever buy. See [05g-stage-6-ship.md](../workflow/05g-stage-6-ship.md).

## "I'll write the markdown files after the MVP works"

**Fails because:** in solo MVP and small-team work, you usually won't — and without them every session re-derives the project from scratch, which is the most expensive way to start a session. Teams using Linear / Jira / Notion as the source of truth get the same benefit without per-project markdown — that's a working substitute, not an exception.
**Instead:** if your tracker isn't already covering this, fill in the spine's templates during stages 0–2, before feature work starts. The cost is tiny up-front, enormous if deferred. See [12a-three-layers-overview.md](../persistence/12a-three-layers-overview.md).

## One big {{PR_OR_MR}} at the end (default — there are exceptions)

**Fails because:** huge diffs hide bugs, are hard to review carefully, and reviewers (including future-you) rubber-stamp because there's no other choice.
**Instead — for the contexts this spine targets (solo / MVP / small-team):** commit per feature. Per stage at the latest. See [18b-scope.md](18b-scope.md) on session bounding.
**When the rule doesn't fit:** some teams (long-lived feature branches, fork-and-merge mandates, regulated-industry change windows) deliberately ship one big {{PR_OR_MR}} at the end of a multi-week effort. That's a deliberate trade-off — small commits land *behind* the {{PR_OR_MR}}, not in main. The anti-pattern is *accidentally* shipping a giant un-reviewable diff, not the practice of single-{{PR_OR_MR}} merges from a long-lived branch.

## TL;DR

The workflow stages are a checklist for a reason: in plan-driven feature work each one catches a class of bug the next one can't. Skipping stage 0 ships the wrong thing. Skipping stage 5 ships a broken thing. Skipping persistent project context (whether spine templates, Linear, Notion, or a wiki) ships a thing nobody (including future-you) can maintain. Research / exploratory / one-off scripting work runs different math — the stage discipline still applies, but the artifacts can be lighter.
