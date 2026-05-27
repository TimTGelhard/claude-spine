---
description: Rescan ~/.claude-spine/bucket/skills/ and rebuild bucket/INDEX.md. Use after dropping a bucket skill in by hand (without going through op-add-skill), or to clean up stale rows.
---

Rebuild the bucket INDEX from what's actually on disk.

Steps:

1. List the entries directly under `~/.claude-spine/bucket/skills/`. For each entry:
   - Folder with a `SKILL.md` inside → that's a folder-form skill; the path to record is `skills/<name>/SKILL.md`.
   - Single `.md` file → single-file skill; path is `skills/<name>.md`.
   - Anything else (stray non-`.md` file, empty folder, `.gitkeep`) → skip.
2. For each found skill, parse the frontmatter `description:` field — the trigger summary for the INDEX row.
3. Read the current `~/.claude-spine/bucket/INDEX.md` to get the existing rows (for `Added` dates — preserve them; don't reset to today if the row already exists).
4. Rewrite `~/.claude-spine/bucket/INDEX.md`:
   - Keep the file header, the "How files are organized" section, and the `<!-- op-add-skill appends rows above this comment. -->` marker line — these are static.
   - Replace the table body. One row per found skill: `| <trigger summary, condensed if >120 chars> | <path from bucket/> | <YYYY-MM-DD added — preserved or today's date if new> |`.
   - If no skills exist, restore the empty-marker row (`_(no skills yet — use ...)_`).
5. Show the user a unified diff of what changed before saving. Bail if they say no.
6. After save, tell the user: count of skills indexed, any stale rows removed, any new rows added.

Rules:

- **Read-only on `chapters/` and `skills/core/`.** This command only touches `bucket/INDEX.md`.
- **Don't invent rows.** If the frontmatter description is missing or malformed, list the skill in the output but don't add a row — tell the user to fix it.
- **Don't delete the user's bucket skills.** Stale-row cleanup means removing INDEX entries that point at missing files. The actual files are never touched.
