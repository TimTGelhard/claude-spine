---
description: Run the planning pass for a new project or a major new section. Walks brief → architecture → master plan → first section plan. Output is plan files only — no code.
---

You are running the **planning pass** for a plan-driven project. Follow the procedure in the `op-prepare` skill.

## What to do

1. **State the contract**: "This is a planning pass. Output will be plan files in `docs/`. No code this session. Continue?"

2. **Read the spine** to load the planning model:
   - `~/.claude-spine/chapters/workflow/05h-multi-session-planning.md`
   - `~/.claude-spine/chapters/workflow/05i-execution-plan-anatomy.md`
   - `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md`

3. **Check / establish the brief**:
   - If `docs/PROJECT_BRIEF.md` doesn't exist, ask the user for the brief. One big input covering what they're building, who for, constraints, success criteria.
   - Write `docs/PROJECT_BRIEF.md` from their input using `~/.claude-spine/templates/PROJECT_BRIEF.md` as scaffold.
   - If it exists, read it.

4. **Ask clarifying questions** — only the ones that change the plan structure. Cap at 5-7 questions. Surface 2-3 architectural choices with honest tradeoffs per global CLAUDE.md.

5. **Draft `docs/ARCHITECTURE.md`** from the template.

6. **Draft `docs/PROJECT_PLAN.md`** — ordered sections with dependencies. Use `~/.claude-spine/templates/PROJECT_PLAN.md`.

7. **Draft `docs/plans/<section-1>.md`** — the FIRST section only. Break into 2-5 sessions. Use `~/.claude-spine/templates/SECTION_PLAN.md`. Do NOT pre-plan sections 2..N in detail.

8. **Initialize `docs/PROGRESS.md`** — pointer at section 1, session 1. Use `~/.claude-spine/templates/PROGRESS.md`.

9. **Hand back** with a 5-line summary: what was drafted, total section count, session count for section 1, next step (user review, then `/session-start`).

## Argument variant

If invoked as `/prep <section-name>` (e.g., `/prep billing`), and `PROJECT_PLAN.md` already exists:

- Skip steps 3-6.
- Draft only `docs/plans/<section-name>.md` — for the named section.
- Don't initialize PROGRESS.md unless this is the first section.
- This is the just-in-time path: plan section N when section N is about to start.

## Hard rules

- **No code this session.** If the user asks you to start coding, refuse and explain. Plans only.
- **No pre-planning all sections in detail.** Master plan + first section only. Subsequent sections via `/prep <name>` when their turn comes.
- **Surface tradeoffs.** Per global CLAUDE.md, never silently pick architectural options.

When you're done, the user reviews. Then `/session-start` begins the first build session.
