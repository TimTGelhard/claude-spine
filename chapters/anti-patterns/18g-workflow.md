# 18g — Workflow anti-patterns

Stages exist because skipping them ships broken software. Each entry: the anti-pattern, why it fails, what to do instead.

## Skipping stage 0 (Decide) — going straight to building

**Fails because:** you build something you didn't actually want. Realizing it at stage 4 costs more than the whole stage 0 would have.
**Instead:** `PROJECT_BRIEF.md` filled in before any code. See [05a-stage-0-decide.md](../workflow/05a-stage-0-decide.md).

## Skipping stage 5 (Harden) — calling demoable "done"

**Fails because:** missing-state bugs (empty, loading, error, offline, dark mode, i18n, a11y) ship to users. Demoable means "the happy path works on your machine," not "users can use this."
**Instead:** dedicated hardening sessions for the full state matrix. See [05f-stage-5-harden.md](../workflow/05f-stage-5-harden.md).

## "I'll write the markdown files after the MVP works"

**Fails because:** you won't. And without them every session re-derives the project from scratch, which is the most expensive way to start a session.
**Instead:** templates filled in during stages 0–2, before feature work starts. The cost is tiny up-front, enormous if deferred. See [12a-three-layers-overview.md](../persistence/12a-three-layers-overview.md).

## One big PR at the end

**Fails because:** huge diffs hide bugs. You can't review them carefully. Reviewers (including future-you) rubber-stamp because there's no other choice.
**Instead:** commit per feature. Per stage at the latest. See [18b-scope.md](18b-scope.md) on session bounding.

## TL;DR

The workflow stages are a checklist for a reason: each one catches a class of bug the next one can't. Skipping stage 0 ships the wrong thing. Skipping stage 5 ships a broken thing. Skipping docs ships a thing nobody (including you) can maintain.
