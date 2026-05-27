# Bucket INDEX — personal library router

**Purpose:** topic → bucket-file map. Read by `op-bucket-router` when no core `op-*` skill matches the user's task. Lists *your* personal skills and chapters (the ones you've written via `op-add-skill` / `op-curate`, or dropped in by hand).

**Status:** empty by design. The bucket ships with no skills and no chapters. You add them as you go.

**How to use this file (as Claude):**

1. Loaded only when `op-bucket-router` fires (i.e. no core skill matched).
2. Scan the **Skills** table first — if a row's "Trigger / question" matches the user's task and the task is procedural (do these steps), read the listed file and act on it.
3. If nothing fires there, scan the **Chapters** table — if the task is a reference question (how does X work, when do I use Y) and a row matches, read the listed file for context. Don't "fire" a chapter; load it as content.
4. If nothing matches in either table, tell the user there's no bucket file for this — don't invent one. Offer `op-add-skill` if the user wants a recurring procedure captured.

**Maintenance:**

- `op-add-skill` appends a new row to **Skills** automatically when it writes a new bucket skill.
- `op-curate` appends a new row to **Skills** or **Chapters** automatically when applying a `new-skill` or `new-chapter` suggestion.
- If you dropped a file into `bucket/skills/` or `bucket/chapters/` by hand, run `/refresh-bucket` to rescan both folders and rebuild the tables.
- Manual edits are fine — this is plain markdown.

---

## How files are organized

- `bucket/skills/<name>/SKILL.md` — one folder per skill (matches the core-skill shape). Adjacent files (templates, question banks, anything content-heavy) live in the same folder and are loaded on-demand by the SKILL.md body.
- Single-file skills (`bucket/skills/<name>.md`) are also fine — use the folder form when the skill needs adjacent files.
- `bucket/chapters/<slug>.md` — flat markdown chapters, one concept per file, ≤150 lines (same atomic-file cap as the core). No numbering convention; the bucket is a flat namespace.

---

## Skills

Procedures Claude fires when the trigger matches. Routed to by `op-bucket-router`.

| Trigger / question | Skill file | Added |
|---|---|---|
| _(no skills yet — use `op-add-skill` or `/add-skill` to add one)_ | — | — |

<!-- op-add-skill appends rows above this comment. Don't move this marker. -->

---

## Chapters

References Claude loads as content when the topic matches. Not "fired" — loaded for reading.

| Topic / question | Chapter file | Added |
|---|---|---|
| _(no chapters yet — chapters land via `op-curate` applying a `new-chapter` suggestion, or by hand-drop + `/refresh-bucket`)_ | — | — |

<!-- op-curate appends chapter rows above this comment. Don't move this marker. -->

---

## Fallback

If `op-bucket-router` reads this and finds no matching row in either table, it returns control to Claude with a brief "no bucket file matched — propose writing a skill with `op-add-skill`, or proceed without one" message. Bucket content is personal — Claude doesn't invent it on the fly.
