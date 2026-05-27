# Session Starter — <PROJECT NAME>

> The literal prompts to paste at the beginning of every Claude Code session.
> Copy the relevant one. Don't retype from memory.

## Why this exists

Every session, Claude starts fresh. It doesn't remember last session's decisions or current state. A good opening prompt loads the project model in one shot and saves you 5-10 minutes of re-explaining.

These prompts are *budget-aware* — they cost ~15-30K tokens up front, but they pay back by preventing wrong assumptions and tool-call ping-pong later.

---

## Plan-driven projects: the ambient flow handles cold-start

If this project has been planned with `/prep` (i.e. `docs/PROJECT_PLAN.md`, `docs/plans/<section>.md`, and a populated `docs/PROGRESS.md` exist), **the paste-prompts below aren't needed** — just open Claude Code:

- The `op-spine-active` skill auto-loads `PROGRESS.md` + the active session entry (~1-2K tokens, not 15-30K), announces scope in 3-4 lines, and proceeds to build. No command to type.
- The Stop hook `spine-writeback.sh` logs a per-turn heartbeat in the section file as you work.
- `/done` walks the verify list, rolls up heartbeats, updates the section plan + `PROGRESS.md`, stages changes, suggests a commit message.

For safety-critical sessions wanting a hard code-gate, use Claude Code's built-in plan mode (Shift+Tab Tab).

The paste-prompts below are still the right tool for:

- Projects that pre-date the plan-driven workflow (no `docs/plans/`).
- One-off bug fixes or design sessions where a full plan would be overkill.
- Resuming an old project where you need a wide orient before doing anything.

If in doubt: if `docs/plans/` exists with files in it, the ambient skill has you covered. Otherwise, pick a prompt below.

---

## Prompt A — New feature session (most common)

```
Read these files in order:
- CLAUDE.md
- docs/ARCHITECTURE.md
- docs/PROGRESS.md
- docs/FEATURES.md
- package.json

Then check the last 3 commits with `git log --oneline -3`.

Tell me in 4 bullets:
1. What this project is.
2. Where we are (current phase, what just shipped).
3. What I'm probably here to do today (best guess from PROGRESS.md + FEATURES.md).
4. Anything that looks blocked or risky right now.

Don't write any code yet. We'll agree on scope first.
```

When to use: starting work on a feature from FEATURES.md.

---

## Prompt B — Bug fix session

```
Read CLAUDE.md and docs/ARCHITECTURE.md for orientation.

I have a bug to fix:
- Where: <route/file>
- Expected: <what should happen>
- Actual: <what happens>
- Steps to reproduce: <how to trigger>
- What I've tried: <attempts so far, or "nothing yet">

Find the root cause before proposing a fix. Don't refactor anything unrelated. One bug per change.
```

When to use: a specific known bug.

---

## Prompt C — Architecture / design session (no code)

```
Read CLAUDE.md, docs/ARCHITECTURE.md, and docs/DECISIONS.md.

I want to think through: <the decision to make>.

Give me 2-3 genuinely different options with honest tradeoffs (name the downside, don't sell them as equal). I'll pick or push back. Don't build anything this session — we're deciding.

Constraints I already have: <list>.
```

When to use: stage 2 of a project, or any non-trivial mid-project decision.

---

## Prompt D — Hardening / cross-cutting concern

```
Read CLAUDE.md, docs/ARCHITECTURE.md, docs/SMOKE_TESTS.md.

This session is focused on <concern>: <empty/loading/error states | dark mode | i18n | accessibility | perf | security>.

Scan the app surface for issues. Report a punch list, then we'll fix in priority order. Don't bundle other improvements — stay on this concern only.
```

When to use: stage 5 of the workflow.

---

## Prompt E — Resuming a project after weeks/months away

```
Read in order:
- CLAUDE.md
- docs/PROJECT_BRIEF.md
- docs/ARCHITECTURE.md
- docs/PROGRESS.md
- docs/FEATURES.md
- docs/DECISIONS.md (skim, especially the most recent entries)

Also: `git log --oneline -20` for recent activity.

Tell me:
1. What state the project is in.
2. What was being worked on most recently.
3. Anything that looks half-finished or broken.
4. Suggested next move.

Don't act yet — I want to re-orient first.
```

When to use: coming back to an old project. Crucial — without this, you'll act on a stale mental model and break things.

---

## Prompt F — Pre-deploy review

```
Read docs/SMOKE_TESTS.md and docs/DEPLOY.md.

We're about to deploy <commit / branch> to production. Walk through:
1. Pre-deploy checklist — which items can you verify, which need me?
2. Migrations to apply — list them.
3. New env vars needed — list them.
4. Risks: what could break?

Don't deploy. Don't run anything destructive. This is a dry-run review.
```

When to use: end of stage 5, before stage 6.

---

## End-of-session prompt

Paste this when you're done, before closing the terminal:

```
We're wrapping up. Do these in order:
1. Update docs/PROGRESS.md: what shipped this session, what's in progress, what's next.
2. If we made any non-obvious decision, add an entry to docs/DECISIONS.md.
3. If we discovered new features or bugs, add them to docs/FEATURES.md or the bugs list.
4. Stage the changes (don't commit yet — I'll review the diff).
5. Suggest a one-line commit message.
```

This is the bit everyone skips that makes the next session 10x smoother.

---

## Adapting the prompts

If your project doesn't have all these files yet (early stage), drop the ones that don't exist. The prompts are templates — edit them for the project's actual state.

If you've added project-specific docs (e.g. `docs/API.md`, `docs/STYLE_GUIDE.md`), add them to the relevant prompts.

---

Updated: YYYY-MM-DD
