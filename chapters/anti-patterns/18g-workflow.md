# 18g — Workflow anti-patterns

Stages exist because skipping them ships broken software. Each entry: the anti-pattern, why it fails, what to do instead.

## Skipping stage 0 (Decide) — going straight to building

**Fails because:** you build something you didn't actually want. Realizing it at stage 4 costs more than the whole stage 0 would have.
**Instead:** `PROJECT_BRIEF.md` filled in before any code. See [05a-stage-0-decide.md](../workflow/05a-stage-0-decide.md).

## Skipping stage 5 (Harden) — calling demoable "done"

**Fails because:** missing-state bugs (empty, loading, error, offline, dark mode, i18n, a11y) ship to users. Demoable means "the happy path works on your machine," not "users can use this."
**Instead:** dedicated hardening sessions for the full state matrix. See [05f-stage-5-harden.md](../workflow/05f-stage-5-harden.md).

## "I'll write the markdown files after the MVP works"

**Fails because:** in solo MVP and small-team work, you usually won't — and without them every session re-derives the project from scratch, which is the most expensive way to start a session. Teams using Linear / Jira / Notion as the source of truth get the same benefit without per-project markdown — that's a working substitute, not an exception.
**Instead:** if your tracker isn't already covering this, fill in the spine's templates during stages 0–2, before feature work starts. The cost is tiny up-front, enormous if deferred. See [12a-three-layers-overview.md](../persistence/12a-three-layers-overview.md).

## One big PR at the end (default — there are exceptions)

**Fails because:** huge diffs hide bugs, are hard to review carefully, and reviewers (including future-you) rubber-stamp because there's no other choice.
**Instead — for the contexts this spine targets (solo / MVP / small-team):** commit per feature. Per stage at the latest. See [18b-scope.md](18b-scope.md) on session bounding.
**When the rule doesn't fit:** some teams (long-lived feature branches, fork-and-merge mandates, regulated-industry change windows) deliberately ship one big PR at the end of a multi-week effort. That's a deliberate trade-off — small commits land *behind* the PR, not in main. The anti-pattern is *accidentally* shipping a giant un-reviewable diff, not the practice of single-PR merges from a long-lived branch.

## TL;DR

The workflow stages are a checklist for a reason: in plan-driven feature work each one catches a class of bug the next one can't. Skipping stage 0 ships the wrong thing. Skipping stage 5 ships a broken thing. Skipping persistent project context (whether spine templates, Linear, Notion, or a wiki) ships a thing nobody (including future-you) can maintain. Research / exploratory / one-off scripting work runs different math — the stage discipline still applies, but the artifacts can be lighter.
