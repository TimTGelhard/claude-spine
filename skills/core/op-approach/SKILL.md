---
name: op-approach
description: Use BEFORE starting any non-trivial multi-domain or multi-session work. Fires on phrases like "audit X", "review X", "refactor X", "migrate X", "investigate X", "clean up X", "improve the project", "tackle this big thing", "the project has grown", "where do I start", "how should we approach", "step by step over multiple sessions". Identifies the work shape (Build / Audit / Refactor / Migration / Investigation / Research / Cleanup) and surfaces its default phase structure, hard rule, and common traps from the catalog in `chapters/workflow/05k-work-shapes.md`. ALWAYS fires before `op-prepare` for any work that isn't obviously a single-feature build. Skip for one-line edits or single-file changes — overhead exceeds payoff.
---

# op-approach — assess approach before tackling

Big work fails when it starts in the wrong shape. An audit run as audit-and-apply produces incoherent findings. A refactor that smuggles in feature work bloats the diff and breaks both. A migration without a cutover plan leaves orphan data. A spike that quietly becomes production decays for years. All the same family — **work-shape-blindness**.

This skill is the meta-step *before* planning. Identify the shape, name the phases, name the traps. Then `op-prepare` runs the planning walk informed by the shape.

## When to fire

- User uses any of the trigger phrases listed in the `description:` above.
- User describes work that touches **>1 surface across >1 session**, or names a multi-domain change.
- Before `op-prepare` runs, for any work that isn't obviously a single-feature build.
- Whenever the user signals scale — *"the project has grown"*, *"step by step over multiple sessions"*, *"a big project"*.

## When NOT to fire

- One-line edits or single-file feature work — overhead exceeds payoff.
- A simple "I want to build X" where X is small and clearly build-shaped — `op-prepare` directly is fine.
- The work has already been shape-assessed in this conversation and the user is now executing — don't re-fire.
- Mid-session, when the user is in flow on Stage 3 Build — defer until the section is done.

## What to do

A short walk — six steps, kept tight. Output is a 5–6 line approach assessment, not a document.

1. **Identify work shape**. Build / Audit / Refactor / Migration / Investigation / Research / Cleanup. Infer from phrasing when clear. Ask one short question if genuinely ambiguous — don't guess wrong, a refactor mistaken for a build silently smuggles feature work in.
2. **Name what this leaves behind in 6 months**. One sentence. A new feature shipped, a cleaner architecture, a system migrated, a bug root-caused, a lesson learned, dead code removed. This is the *long-term framing* check — answers the user's underlying *"how will this work impact the project?"* question.
3. **Load the catalog row** for the identified shape from [`chapters/workflow/05k-work-shapes.md`](../../../chapters/workflow/05k-work-shapes.md). The chapter holds the meat: default phase order, the hard rule, common traps.
4. **Apply the hard rule to the plan**. Audit-shape ⇒ no apply between audits. Refactor-shape ⇒ no feature work mixed in. Migration-shape ⇒ don't leave partial state. Investigation-shape ⇒ fix root cause, not symptom. Research-shape ⇒ throw away spike code. Cleanup-shape ⇒ don't delete what isn't confirmed dead. If the user's stated plan violates the rule, flag it before `op-prepare` runs.
5. **Surface 2–3 traps** specific to this shape from the catalog. Brief, not exhaustive.
6. **Hand off**:
   - Build → `op-prepare` runs the standard brief → architecture → master plan walk.
   - Audit / Refactor / Migration / Investigation / Research / Cleanup → `op-prepare` still drafts the plan, but informed by this approach assessment (the shape's phase order becomes `PROJECT_PLAN.md` section structure).
   - Trivially small work → no planning pass needed; proceed.

## Output shape

A short block the user sees before any planning starts:

```
Shape: <one word>
Leaves behind: <one sentence>
Phases: <ordered phase list>
Hard rule: <the load-bearing rule for this shape>
Traps: <2–3 from the catalog>
Next: <op-prepare | proceed | one short question>
```

If the user overrides the shape or skips the discipline, fine — surface the trade-off once, log the deviation, defer.

## What NOT to do

- Don't pad. The catalog carries the rationale; the SKILL output cites it, doesn't restate it.
- Don't replace `op-prepare`. This skill runs *before* the planning walk, not instead of it.
- Don't run for every prompt. Trigger description is specific on purpose.
- Don't ask 20 clarifying questions. One, if shape is genuinely ambiguous; otherwise infer.

## Sibling skills

- After this fires: `op-prepare` runs the brief → architecture → master plan → first section pass.
- Per-session execution: `op-workflow` (chapter 05d) — what each session does inside its scope.
- Brownfield discovery first: `op-brownfield` — discover before shape-assess on inherited codebases.
- Collaboration mode (executor / reviewer / explainer / planner): `op-collaboration-modes` — orthogonal to work shape.

## See also

- [`chapters/workflow/05k-work-shapes.md`](../../../chapters/workflow/05k-work-shapes.md) — the catalog this skill routes to.
- [`chapters/workflow/05h-multi-session-planning.md`](../../../chapters/workflow/05h-multi-session-planning.md) — the planning hierarchy that runs after this.
- [`chapters/workflow/05i-execution-plan-anatomy.md`](../../../chapters/workflow/05i-execution-plan-anatomy.md) — what each plan file should contain.

## TL;DR

- Fires before `op-prepare` for any non-build multi-session work.
- Identifies work shape, names its phases + hard rule + traps from the [05k catalog](../../../chapters/workflow/05k-work-shapes.md).
- Output is a 5–6 line approach block, not a document.
- Hands off to `op-prepare` informed by the shape.
