---
description: Run the planning pass for a new project or a major new section. Walks brief → architecture → master plan → first section plan. Output is plan files only — no code.
---

You are running the **planning pass** for a plan-driven project. Follow the procedure in the `op-prepare` skill — `~/.claude-spine/skills/core/op-prepare/SKILL.md` for the router, `~/.claude-spine/skills/core/op-prepare/procedure.md` for the step-by-step body.

## What to do

0. **Scaffold if needed.** If `docs/` doesn't exist in the cwd, run `~/.claude-spine/init.sh .` first to scaffold project docs from spine templates. `init.sh` is idempotent — it won't overwrite existing files, so it's safe to run even on partial setups. Skip this step only if `docs/` already exists.

1. **State the contract**: "This is a planning pass. Output will be plan files in `docs/`. No code this session. Continue?"

2. **Read the spine** to load the planning model:
   - `~/.claude-spine/chapters/workflow/05h-multi-session-planning.md`
   - `~/.claude-spine/chapters/workflow/05i-execution-plan-anatomy.md`
   - `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md`

3. **Check / establish the brief**:
   - If `docs/PROJECT_BRIEF.md` doesn't exist, ask the user for the brief. One big input covering what they're building, who for, constraints, success criteria.
   - **Quality bar:** if the answer is a one-liner with no audience, no platform, no v1 cut, do NOT write the file yet. Go to step 4 (product shape) first. Per `op-prepare`'s anti-patterns: writing the brief from a category-word produces an architecture shaped for the wrong product.
   - Once you can fill the template's required fields (audience, the one outcome, scope-IN, scope-OUT, constraints), write `docs/PROJECT_BRIEF.md` using `~/.claude-spine/templates/PROJECT_BRIEF.md`.
   - If it exists, read it. If big product-shape questions remain open, still run step 4.

4. **Product shape questions** (Step 2.5 in `op-prepare`) — before any stack questions. Ask in one round: audience (specific persona), platform (mobile / web / desktop / CLI / local file / extension), primary v1 user journey, top 3 v1 features, top 3 explicit deferrals, single- vs multi-user, online- vs offline-first. Cap at these 7. Update `PROJECT_BRIEF.md` if answers contradict the original input.

5. **Architecture clarifying questions** — only the ones that *still* change the plan structure after step 4. Cap at 5-7. Surface 2-3 architectural choices with honest tradeoffs per global CLAUDE.md.

6. **Draft `docs/ARCHITECTURE.md`** from the template.

7. **Draft `docs/PROJECT_PLAN.md`** — ordered sections with dependencies. Use `~/.claude-spine/templates/PROJECT_PLAN.md`.

8. **Draft `docs/plans/<section-1>.md`** — the FIRST section only. Break into 2-5 sessions. Use `~/.claude-spine/templates/SECTION_PLAN.md`. Do NOT pre-plan sections 2..N in detail.

9. **Initialize `docs/PROGRESS.md`** — pointer at section 1, session 1. Use `~/.claude-spine/templates/PROGRESS.md`.

10. **Hand back** with a 5-line summary: what was drafted, total section count, session count for section 1, next step (user reviews the plan; opening Claude in the project will auto-load scope via `op-spine-active`).

## Argument variant

If invoked as `/prep <section-name>` (e.g., `/prep billing`), and `PROJECT_PLAN.md` already exists:

- Skip steps 3-7.
- Draft only `docs/plans/<section-name>.md` — for the named section.
- Don't initialize PROGRESS.md unless this is the first section.
- This is the just-in-time path: plan section N when section N is about to start.

## Hard rules

- **No code this session.** If the user asks you to start coding, refuse and explain. Plans only.
- **No pre-planning all sections in detail.** Master plan + first section only. Subsequent sections via `/prep <name>` when their turn comes.
- **Surface tradeoffs.** Per global CLAUDE.md, never silently pick architectural options.
- **Product shape before stack.** Never ask "which library / dependency?" while the platform (mobile / web / desktop / CLI / local file) is still ambiguous. Step 4 first.

When you're done, the user reviews. Then they just open Claude in the project — the `op-spine-active` skill auto-loads scope and begins the first build session.
