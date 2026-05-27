---
name: op-bucket-router
description: Use as the fallback router when the user's task isn't covered by any other core `op-*` skill — checks the user's personal bucket library (`~/.claude-spine/bucket/INDEX.md`) for a matching skill and loads only the matched file. Fires when: another router would normally handle the task but no core chapter covers it (project-specific recipe, stack-specific pattern, user's personal convention); the user says "do this the way I usually do" / "use my X skill" / "check my bucket"; or any task that smells like a learned personal pattern rather than a universal one. Never invents bucket skills — only routes to existing ones.
---

# op-bucket-router — personal library fallback

The bucket holds the user's *personal* skill library — patterns they've collected for their own work, written via `op-add-skill` or dropped in by hand. This skill is the router into that library. Core skills always win — this fires only when none of them matched.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to your home directory (`$HOME`) before reading. `install.sh` ensures `~/.claude-spine` resolves to the spine clone.

## When this fires

- No core `op-*` skill matched the user's task **and** the task looks like it could be a learned pattern (project recipe, stack-specific deploy, user's personal review style, etc.).
- The user explicitly says: "use my bucket," "do this the way I usually do," "check my X skill," "is there a skill for this?"
- Before recommending a new skill to a user, check whether one already exists in their bucket.

## When NOT to fire

- A core router fits — let it fire instead. The bucket is the *fallback*, not the front door.
- The task is one-off / experimental — don't reach for the bucket for things that won't recur.
- The user hasn't added any bucket skills yet (`bucket/INDEX.md` shows the empty marker) — say so and move on; don't invent a skill.

## How to route

1. Read `~/.claude-spine/bucket/INDEX.md`.
2. Scan the skills table for a row whose "Trigger / question" matches the user's task.
3. **If matched:** read the listed file (e.g. `~/.claude-spine/bucket/skills/<name>/SKILL.md`) and follow it. Load adjacent files only if the SKILL.md routes to them.
4. **If no match:** tell the user there's no bucket skill for this. Offer `op-add-skill` if it feels like a recurring pattern. Otherwise proceed without a skill.

## Rules

- **Never invent a bucket skill.** If the table is empty or doesn't match, the answer is "no bucket skill" — not a freshly-imagined one.
- **One row at a time.** Don't load multiple bucket skills unless the user's task is genuinely cross-cutting and the rows obviously go together.
- **Don't modify the bucket.** Writing or editing bucket files is `op-add-skill`'s job — this skill only reads.
- **Stale rows happen.** If the listed file is missing, tell the user; suggest `/refresh-bucket` to rescan and rebuild the INDEX.

## Sibling skills

- Writing a new bucket skill → `op-add-skill`.
- Auditing or rebuilding the bucket INDEX → `/refresh-bucket` slash command.
- "Where should this go — bucket / core / project doc?" → `op-persistence` (13a + 13d).
