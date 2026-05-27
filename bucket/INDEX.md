# Bucket INDEX — personal skill library router

**Purpose:** topic → bucket-skill map. Read by `op-bucket-router` when no core `op-*` skill matches the user's task. Lists *your* personal skills (the ones you've written via `op-add-skill` or dropped in by hand).

**Status:** empty by design. The bucket ships with no skills. You add them as you go.

**How to use this file (as Claude):**

1. Loaded only when `op-bucket-router` fires (i.e. no core skill matched).
2. Scan the table. If a row's "Trigger / question" matches the user's task, read the listed file and act on it.
3. If nothing matches, tell the user there's no bucket skill for this — don't invent one. Offer `op-add-skill` if the user wants to write one.

**Maintenance:**

- `op-add-skill` (the core skill) appends a new row here automatically when it writes a new bucket skill.
- If you dropped a skill into `bucket/skills/` by hand, run `/refresh-bucket` to rescan and rebuild this table.
- Manual edits are fine — this is plain markdown.

---

## How files are organized

- `bucket/skills/<name>/SKILL.md` — one folder per skill (matches the core-skill shape). Adjacent files (templates, question banks, anything content-heavy) live in the same folder and are loaded on-demand by the SKILL.md body.
- Single-file skills (`bucket/skills/<name>.md`) are also fine — use the folder form when the skill needs adjacent files.

---

## Skills

| Trigger / question | Skill file | Added |
|---|---|---|
| _(no skills yet — use `op-add-skill` or `/op-add-skill` to add one)_ | — | — |

<!-- op-add-skill appends rows above this comment. Don't move this marker. -->

---

## Fallback

If `op-bucket-router` reads this and finds no matching row, it returns control to Claude with a brief "no bucket skill matched — propose writing one with `op-add-skill`, or proceed without one" message. Bucket skills are personal — Claude doesn't invent one on the fly.
