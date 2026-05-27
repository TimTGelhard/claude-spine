# 15d — Planning: plan mode and TaskCreate

## EnterPlanMode / ExitPlanMode

**Use when:**

- Task touches >3 files OR >2 layers.
- Architectural decision involved.
- Security boundary changing.
- You're unsure of the right approach.

**Skip when:**

- One-file bug fix with obvious cause.
- Mechanical edit (rename, copy change).

**How it works:** Claude proposes a plan, you approve or push back, then Claude executes. Catches "Claude is about to do something wrong" before it's done.

**Anti-pattern:** planning everything. For simple tasks it's friction. For complex ones it's gold.

## TaskCreate / TaskUpdate / TaskList

**Use for:** tracking progress on multi-step work *within the current session*.

- Set `in_progress` when starting a task, `completed` when done.
- Mark tasks completed *immediately* when done — don't batch.
- Use for *meaningful units of work*, not every keystroke.

**Anti-patterns:**

- Using tasks for what should be in `PROGRESS.md`. Tasks die at session end. PROGRESS.md persists.
- Creating one task per tiny action. Tasks are for meaningful chunks.
- Forgetting to update — stale task lists make later signals worse.

## When to use plan mode vs TaskCreate

| Situation | Use |
|---|---|
| About to start a multi-file change | Plan mode (approve before code) |
| Mid-execution of an approved plan | TaskCreate to track progress |
| Tracking a small in-session todo list | TaskCreate |
| Designing architecture for next 4 hours | Plan mode + TaskCreate to track once approved |

Plan mode = "should I do this?" TaskCreate = "where am I in doing it?"

## TL;DR

- Plan mode for non-trivial changes; skip for trivial.
- TaskCreate for in-session progress tracking; don't use for cross-session persistence.
- Update tasks as you go — don't batch.
